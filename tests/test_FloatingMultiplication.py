import math

import cocotb

import assertions
import test_types
import utils


class FloatingMultiplicationTest(test_types.FloatingPointBaseTest):
    def assert_result(self):
        assertions.assert_multiplication(self.A, self.B, self.result)


@cocotb.test()
async def test_floating_multiplication_basic(dut):
    test = FloatingMultiplicationTest(dut, None, None)
    for a in utils.BASIC_VALUES:
        for b in utils.BASIC_VALUES:
            test.A = a
            test.B = b
            await test.exec_test()


@cocotb.test()
async def test_floating_multiplication_random_simple(dut):
    test = FloatingMultiplicationTest(dut, None, None)
    max_val = 100
    for _ in range(1000):
        a, b = utils.sample_a_and_b(-max_val, max_val)
        test.A = a
        test.B = b
        await test.exec_test()


@cocotb.test()
async def test_floating_multiplication_random_full_range(dut):
    test = FloatingMultiplicationTest(dut, None, None)
    max_val = math.sqrt(utils.IEEE754_MAX_VAL)
    for _ in range(1000):
        a, b = utils.sample_a_and_b(-max_val, max_val)
        test.A = a
        test.B = b
        await test.exec_test()
