import cocotb

import test_types
import utils


class FloatingCompareTest(test_types.FloatingPointBaseTest):
    def assign_output(self):
        self.result = self.dut.result.value

    def assert_result(self):
        expected = 1 if self.A >= self.B else 0

        assert self.result == expected, \
            f"Mismatch: {self.A} >= {self.B} = {
                self.result} (expected {expected})"


@cocotb.test()
async def test_floating_compare_basic(dut):
    test = FloatingCompareTest(dut, None, None)
    for a in utils.BASIC_VALUES:
        for b in utils.BASIC_VALUES:
            test.A = a
            test.B = b
            await test.exec_test()


@cocotb.test()
async def test_floating_compare_random_simple(dut):
    test = FloatingCompareTest(dut, None, None)
    max_val = 100
    for _ in range(1000):
        a, b = utils.sample_a_and_b(-max_val, max_val)
        test.A = a
        test.B = b
        await test.exec_test()


@cocotb.test()
async def test_floating_compare_random_full_range(dut):
    test = FloatingCompareTest(dut, None, None)
    max_val = utils.IEEE754_MAX_VAL
    for _ in range(1000):
        a, b = utils.sample_a_and_b(-max_val, max_val)
        test.A = a
        test.B = b
        await test.exec_test()
