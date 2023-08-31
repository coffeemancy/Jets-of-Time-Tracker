#!/usr/bin/env python
import argparse
import copy
import json
import typing as t

from pathlib import Path

MAP_OFFSETS: t.Dict[str, t.Tuple[int, int]] = {
    # Prehistory | Middle Ages | Future
    # Dark Ages  | Present     | End of Time
    'All Eras': {
        'Prehistory': (0, 0),
        'Dark Ages': (0, 1024),
        'Middle Ages': (1536, 0),
        'Present': (1536, 1024),
        'Future': (3072, 0),
        'End Of Time': (3072, 1024),
    },
}


def gen_coordinates(location: t.Dict[str, t.Any], explain: bool = False) -> t.Dict[str, t.Any]:
    '''Yield era-relative and absolute ('All Eras') locations.'''
    map_locations = location['map_locations']
    eras = [era for era in map_locations if era['map'] not in ['All Eras', 'All Eras (Vertical)']]

    for era in eras:
        yield era

        for absolute_map, era_offsets in MAP_OFFSETS.items():
            offset_x, offset_y = era_offsets[era['map']]
            absolute = {'map': absolute_map, 'x': era['x'] + offset_x, 'y': era['y'] + offset_y}

            if explain and absolute not in map_locations:
                print(f"Updating '{location['name']}' -> {absolute}")

            yield absolute


def update_coordinates(location, explain: bool = False):
    if 'children' in location:
        for child in location['children']:
            update_coordinates(child, explain=explain)
    else:
        location.update({'map_locations': [loc for loc in gen_coordinates(location, explain=explain)]})


def update_locations(data, explain: bool = False) -> t.List[t.Dict[str, t.Any]]:
    updated = copy.deepcopy(data)
    for item in updated:
        update_coordinates(item, explain=explain)
    return updated


def main(args: argparse.Namespace):
    data = json.loads(Path(args.locations_file).read_text())
    updated = [item for item in update_locations(data, explain=args.explain)]
    if not args.explain:
        print(json.dumps(updated, indent=2))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        prog='normalize-locations.py',
        description='Normalize absolute map locations based on era in locations.json',
    )
    parser.add_argument('locations_file')
    parser.add_argument('-x', '--explain', help='Explain adjustments to be made', action='store_true')
    args = parser.parse_args()
    main(args)
