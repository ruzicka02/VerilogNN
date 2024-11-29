import math

import cocotb
import numpy as np

import utils
import test_types


class VectorMultiplicationParTest(test_types.VectorBaseTest):
    def assert_result(self):
        expected = self.A @ self.B
        # not sure about this
        tolerance = utils.get_dot_product_tolerance(self.A, self.B)

        assert abs(self.result - expected) < tolerance, \
            f"Mismatch: {
                self.A} @ {self.B} = {self.result} (expected: {expected}; tolerance: {tolerance})"

    def assign_output(self):
        self.result = utils.ieee754_to_float(self.dut.result.value)


@cocotb.test()
async def test_vector_multiplication_par(dut):
    test = VectorMultiplicationParTest(dut, [1.0, 2.0, 3.0], [1.0, 2.0, 3.0])
    await test.exec_test()


# TODO make this dynamic
STATIC_ARRAY_WIDTH = 3


@cocotb.test()
async def test_vector_multiplication_par_basic(dut):
    a = np.array([1, 2, 3])
    b = np.array([2, 3, 4])

    await VectorMultiplicationParTest(dut, a, b).exec_test()


@cocotb.test()
async def test_vector_multiplication_par_random_simple(dut):
    test = VectorMultiplicationParTest(dut, None, None)
    max_val = 100

    for i in range(1000):
        test.A = utils.sample_array(-max_val, max_val, STATIC_ARRAY_WIDTH)
        test.B = utils.sample_array(-max_val, max_val, STATIC_ARRAY_WIDTH)
        await test.exec_test()


@cocotb.test()
async def test_vector_multiplication_par_random_full_range(dut):
    test = VectorMultiplicationParTest(dut, None, None)
    # / 10 because, there can be problems when mutliplying 2 arrays with multiple values close to max
    max_val = math.sqrt(utils.IEEE754_MAX_VAL) / 10

    for i in range(1000):
        test.A = utils.sample_array(-max_val, max_val, STATIC_ARRAY_WIDTH)
        test.B = utils.sample_array(-max_val, max_val, STATIC_ARRAY_WIDTH)
        await test.exec_test()
