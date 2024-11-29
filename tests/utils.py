import math
import random
import struct

import numpy as np


IEEE754_MAX_VAL = 3.4028235e38
BASIC_VALUES = [-1.0, -0.5, 0.0, 0.5, 1.0]


def float_to_ieee754(value: float) -> int:
    """Convert float to IEEE-754 single-precision binary (represented as an integer)."""
    return struct.unpack('>I', struct.pack('>f', value))[0]


def ieee754_to_float(value):
    """Convert IEEE-754 single-precision binary (represented as an integer) to float"""
    # Convert BinaryValue to integer
    return struct.unpack('>f', struct.pack('>I', value))[0]


def get_tolerance(value):
    """Calculate the tolerance for a value, considering that 6 digits can be represented precisely."""
    if value == 0:
        n_digits = 1
    else:
        n_digits = math.floor(math.log10(abs(value))) + 1

    return 10 ** (-6 + n_digits)


def get_dot_product_tolerance(a, b):
    """Calculate the tolerance for a dot product a @ b"""
    vectorized_get_tolerance = np.vectorize(get_tolerance)
    return max(
        # max tolerance for any value in a * b
        max(vectorized_get_tolerance(a * b)),
        # max tolerance for any value in a
        max(vectorized_get_tolerance(a)),
        # max tolerance for any value in b
        max(vectorized_get_tolerance(b))
    )


def assert_convertibility(x):
    """Asserts whether x is convertible to IEEE-754."""
    tolerance = get_tolerance(x)
    assert abs(x - ieee754_to_float(float_to_ieee754(x))
               ) < tolerance, f"Value {x} not convertible"


async def sample_and_run_fct(dut, min_val, max_val, fct):
    """Sample 2 numbers between min_val and max_val and run fct with them.

    Args:
        dut: The device under test.
        min_val: The lower limit of sampling.
        max_val: The upper limit of sampling.
        fct: An async function, called with the sampled values.
    """
    a = random.uniform(min_val, max_val)
    b = random.uniform(min_val, max_val)

    await fct(dut, a, b)


def sample_a_and_b(min_val, max_val):
    a = random.uniform(min_val, max_val)
    b = random.uniform(min_val, max_val)
    return a, b


def sample_array(min_val, max_val, width):
    arr = []
    for _ in range(width):
        arr.append(random.uniform(min_val, max_val))

    return np.array(arr)


async def pairwise_run_fct(dut, vals, fct):
    """Runs the passed fct for each pair of values in vals.

    Args:
        dut: The device under test.
        vals: A list of values.
        fct: An async function which takes as parameter the dut and 2 values from vals.
    """
    for val_1 in vals:
        for val_2 in vals:
            await fct(dut, val_1, val_2)


# TODO docstrings for the following functions
def array_to_ieee754_array(array):
    """Generate vector from the given array. Assumes 1-dimensional array."""
    return [float_to_ieee754(x) for x in array]


def ieee754_array_to_array(ieee754_array):
    return np.array([ieee754_to_float(x) for x in ieee754_array])


def pack_ieee754_array(ieee754_array):
    """Pack list of 32-bit values into single value, which can be assigned to a wire"""
    result = 0
    for i, val in enumerate(ieee754_array):
        result |= (val << (32 * i))
    return result


def unpack_ieee754_array(packed_ieee754_array, width):
    """Unpack single value into list of 32-bit values"""
    mask = (1 << 32) - 1
    return [(packed_ieee754_array >> (32 * i)) & mask for i in range(width)]
