import json
import re
import subprocess

from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, List, Set

import pytest


# FIXTURES ##################################################################


@pytest.fixture(scope='session')
def codes(items, luafunctions) -> Set[str]:
    '''Flattened set of all unique codes from items.json.'''
    codes: Set[str] = {f"${fn}" for fn in luafunctions}

    def _add_codes(item):
        if 'stages' in item:
            for stage in item['stages']:
                _add_codes(stage)
        else:
            for code in item.get('codes', '').split(','):
                codes.add(code.strip())

    for item in items:
        _add_codes(item)

    return codes


@pytest.fixture(scope='session')
def items(paths) -> Dict[str, Any]:
    items_json = Path(paths['root'], 'items/items.json')
    return json.loads(items_json.read_text())


@pytest.fixture(scope='session')
def locations_json(paths) -> Path:
    return Path(paths['root'], 'locations/locations.json')


@pytest.fixture(scope='session')
def luafiles(paths) -> List[Path]:
    return [path for path in paths['root'].rglob('*.lua') if not path.is_symlink()]


@pytest.fixture(scope='session')
def luafunctions(luafiles) -> Set[str]:
    '''Set of all global functions defined in pack lua scripts.'''
    fn_regex = re.compile(r'\s*function (.*)\s*\(')
    return {fn for file in luafiles for fn in fn_regex.findall(file.read_text())}


@dataclass
class LocationSection:
    name: str
    access_rules: List[str]
    visibility_rules: List[str]


@pytest.fixture(scope='session')
def location_sections(locations_json) -> List[LocationSection]:
    '''Flattened list of all parsed location sections from locations json.'''
    sections: List[LocationSection] = []

    def _create_section(child) -> LocationSection:
        access_rules = child.get('access_rules', [])
        visibility_rules = child.get('visibility_rules', [])
        return LocationSection(child['name'], access_rules, visibility_rules)

    data = json.loads(locations_json.read_text())
    for element in data:
        for child in element['children']:
            assert 'name' in child, 'Missing name for era!'
            era = _create_section(child)
            sections.append(era)
            for grandchild in child['children']:
                assert 'name' in grandchild, f"Missing name for era location in '{era.name}'"
                section = _create_section(grandchild)
                sections.append(section)

    return sections


# TESTS ######################################################################


def test_location_rules_codes_defined(codes, location_sections):
    '''Test all access/visibility rules use defined codes.'''
    assert codes, 'Failed to parse codes from items.json'
    assert location_sections, 'Failed to parse location sections from locations.json'

    def _get_codes(rule):
        for code in rule.split(','):
            # remove whitespace and ignore brackets
            yield code.strip().lstrip('[').rstrip(']')

    for section in location_sections:
        for rule in section.access_rules:
            for code in _get_codes(rule):
                assert code in codes, f"Undefined code '{code}' in access rule for '{section.name}'"
        for rule in section.visibility_rules:
            for code in _get_codes(rule):
                assert code in codes, f"Undefined code '{code}' in visibility rule for '{section.name}'"


def test_normalize_locations(paths, locations_json):
    '''Test all locations era-relative coordinates have matching absolute coords.'''
    tool = Path(paths['tools'], 'normalize-locations.py')
    args = [tool, '-xk', str(locations_json)]
    sp = subprocess.run(args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    stdout = sp.stdout.decode('utf-8')
    err = (
        f"normalize-locations.py indicates updates are required\n"
        f"Fix by updating with:\n"
        f"  ./tools/normalize-locations.py -xi {locations_json.relative_to(paths['root'])}\n\n"
    )
    assert sp.returncode == 0, f'{err}\n{stdout}'
