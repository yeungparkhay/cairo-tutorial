# Exercise 1 - First function

# To compile: cairo-compile 1_intro.cairo --output 1_intro_compiled.json
# To run: cairo-run --program=1_intro_compiled.json --print_output --layout=small

%builtins output

from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.alloc import alloc

func array_prod_even(arr : felt*, size) -> (prod):
    if size == 0:
        return (prod=1)
    end

    # size is not zero.
    let (prod_of_rest) = array_prod_even(arr=arr + 2, size=size - 2)
    return (prod=[arr] * prod_of_rest)
end


func main{output_ptr : felt*}():
    let (arr) = alloc()
    assert [arr] = 2
    assert [arr + 1] = 3
    assert [arr + 2] = 4
    assert [arr + 3] = 5
    let (output) = array_prod_even(arr, size=4)
    serialize_word(output)
    return ()
end