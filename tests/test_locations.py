import json
import typing as t

from pathlib import Path

import pytest

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
    # Prehistory  | Dark Ages
    # Middle Ages | Present
    # Future      | End of Time
    'All Eras (Vertical)': {
        'Prehistory': (0, 0),
        'Dark Ages': (1536, 0),
        'Middle Ages': (0, 1024),
        'Present': (1536, 1024),
        'Future': (0, 2048),
        'End Of Time': (1536, 2048),
    },
}


def get_all_locations():
    """Flattened list of all locations in locations.json"""
    locations_json = Path(Path(__file__).resolve().parent, "..", "locations/locations.json")
    data = json.loads(locations_json.read_text())

    # recursively generate flat list of all locations, recursing down childre
    def gen_locations(item):
        for child in item["children"]:
            if isinstance(child, t.Mapping) and "children" in child:
                for loc in gen_locations(child):
                    yield loc
            else:
                yield child

    return [loc for item in data for loc in gen_locations(item)]


ALL_LOCATIONS = get_all_locations()

# TESTS ######################################################################


@pytest.mark.parametrize("loc", ALL_LOCATIONS, ids=lambda loc: loc["name"])
def test_locations_coordinates(loc):
    """Test all locations era-relative coordinates have matching absolute coords."""
    # for loc in all_locations:
    map_locations = loc["map_locations"]
    abs_maps = MAP_OFFSETS.keys()
    spots = [spot for spot in map_locations if spot["map"] not in abs_maps]

    for abs_map, era in MAP_OFFSETS.items():
        abs_spots = [(spot["x"], spot["y"]) for spot in map_locations if spot["map"] == abs_map]

        # check that an absolute location exists
        assert abs_spots, f"No '{abs_map}' map location for {loc['name']}"

        # check that same number of absolute and era-relative locations
        assert len(spots) == len(
            abs_spots
        ), f"Inequal number of era-relative and '{abs_map}' map locations for {loc['name']}"

        # check each spot has corresponding absolute spot with correct offset
        for spot in spots:
            offset_x, offset_y = MAP_OFFSETS[abs_map][spot["map"]]
            expected = (spot["x"] + offset_x, spot["y"] + offset_y)
            assert expected in abs_spots, (
                f"Missing expected '{abs_map}' spot relative to '{spot['map']}' "
                f"for {loc['name']} with coords {expected}"
            )
