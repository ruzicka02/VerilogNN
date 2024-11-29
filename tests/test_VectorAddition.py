import cocotb
import numpy as np

import assertions
import utils
import test_types


class VectorAdditionTest(test_types.VectorBaseTest):
    def assert_result(self):
        for i in range(len(self.result)):
            assertions.assert_addition(self.A[i], self.B[i], self.result[i])


# TODO make this dynamic
STATIC_ARRAY_WIDTH = 3


@cocotb.test()
async def test_vector_add_basic(dut):
    a = np.array([1, 2, 3])
    b = np.array([2, 3, 4])

    await VectorAdditionTest(dut, a, b).exec_test()


@cocotb.test()
async def test_vector_addition_random_simple(dut):
    test = VectorAdditionTest(dut, None, None)
    max_val = 100

    for i in range(1000):
        test.A = utils.sample_array(-max_val, max_val, STATIC_ARRAY_WIDTH)
        test.B = utils.sample_array(-max_val, max_val, STATIC_ARRAY_WIDTH)
        await test.exec_test()


@cocotb.test()
async def test_vector_addition_random_full_range(dut):
    test = VectorAdditionTest(dut, None, None)
    max_val = utils.IEEE754_MAX_VAL / 2

    for i in range(1000):
        test.A = utils.sample_array(-max_val, max_val, STATIC_ARRAY_WIDTH)
        test.B = utils.sample_array(-max_val, max_val, STATIC_ARRAY_WIDTH)
        await test.exec_test()
