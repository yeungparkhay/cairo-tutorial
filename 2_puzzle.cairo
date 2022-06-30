# Exercise 2 - 15 puzzle

# To compile: cairo-compile 2_puzzle.cairo --output 2_puzzle_compiled.json
# To run: cairo-run --program=2_puzzle_compiled.json --print_output --layout=small

from starkware.cairo.common.registers import get_fp_and_pc

# Define a struct that represents a tile location
struct Location:
    member row : felt
    member col : felt
end


# Checks validity of a given tile location
func verify_valid_location(loc : Location*):
    # Check that row is in the range 0-3.
    tempvar row = loc.row
    assert row * (row - 1) * (row - 2) * (row - 3) = 0

    # Check that col is in the range 0-3.
    tempvar col = loc.col
    assert col * (col - 1) * (col - 2) * (col - 3) = 0

    return ()
end


# Checks that two consecutive locations are adjacent
func verify_adjacent_locations(
        loc0 : Location*, loc1 : Location*):
    alloc_locals
    local row_diff = loc0.row - loc1.row
    local col_diff = loc0.col - loc1.col

    if row_diff == 0:
        # The row coordinate is the same. Make sure the difference
        # in col is 1 or -1.
        assert col_diff * col_diff = 1
        return ()
    else:
        # Verify the difference in row is 1 or -1.
        assert row_diff * row_diff = 1
        # Verify that the col coordinate is the same.
        assert col_diff = 0
        return ()
    end
end


# Checks that tile location is (3, 3)
func verify_last_location(loc : Location*):
    # Check that row is 3.
    tempvar row = loc.row
    assert row = 3

    # Check that col is 3.
    tempvar col = loc.col
    assert col = 3

    return ()
end


# Recursive function that checks whether a list of locations is valid
func verify_location_list(loc_list : Location*, n_steps):
    # Always verify that the location is valid, even if
    # n_steps = 0 (remember that there is always one more
    # location than steps).
    verify_valid_location(loc=loc_list)

    if n_steps == 0:
        verify_last_location(loc=loc_list)
        return ()
    end

    verify_adjacent_locations(
        loc0=loc_list, loc1=loc_list + Location.SIZE)

    # Call verify_location_list recursively.
    verify_location_list(
        loc_list=loc_list + Location.SIZE, n_steps=n_steps - 1)
    return ()
end


func main():
    alloc_locals

    local loc_tuple : (Location, Location, Location, Location, Location) = (
        Location(row=0, col=2),
        Location(row=1, col=2),
        Location(row=1, col=3),
        Location(row=2, col=3),
        Location(row=3, col=3),
        )

    # Get the value of the frame pointer register (fp) so that
    # we can use the address of loc_tuple.
    let (__fp__, _) = get_fp_and_pc()

    # Since the tuple elements are next to each other we can use the
    # address of loc_tuple as a pointer to the 5 locations.
    verify_location_list(
        loc_list=cast(&loc_tuple, Location*), n_steps=4)
    return ()
end
