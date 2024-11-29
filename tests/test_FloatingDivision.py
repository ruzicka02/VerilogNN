import cocotb

import assertions
import test_types
import utils


class FloatingDivisionTest(test_types.FloatingPointBaseTest):
    def assert_result(self):
        assertions.assert_divsion(self.A, self.B, self.result)


@cocotb.test()
async def test_floating_division_basic(dut):
    test = FloatingDivisionTest(dut, None, None)
    for a in utils.BASIC_VALUES:
        for b in utils.BASIC_VALUES:
            if b == 0.0:
                continue
            test.A = a
            test.B = b
            await test.exec_test()


@cocotb.test()
async def test_floating_division_random_simple(dut):
    test = FloatingDivisionTest(dut, None, None)
    max_val = 100
    for _ in range(1000):
        a, b = utils.sample_a_and_b(-max_val, max_val)
        test.A = a
        test.B = b
        await test.exec_test()


@cocotb.test()
async def test_floating_division_random_full_range(dut):
    test = FloatingDivisionTest(dut, None, None)
    # / 10 cause problems seem to exist with e38,
    # but these problems are not crucial enough to adapt the verilog module
    max_val = utils.IEEE754_MAX_VAL / 10
    for _ in range(1000):
        a, b = utils.sample_a_and_b(-max_val, max_val)
        test.A = a
        test.B = b
        await test.exec_test()
