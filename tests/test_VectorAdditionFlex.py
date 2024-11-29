import random

import cocotb
import numpy as np
from cocotb.clock import Clock
from cocotb.triggers import Timer

import utils
import test_VectorAddition


class VectorAdditionFlexTest(test_VectorAddition.VectorAdditionTest):
    def __init__(self, dut, A, B):
        super().__init__(dut, A, B)
        self.clk = Clock(self.dut.clk, 1, units="ns")
        assert len(A) == len(B)
        self.l = len(A)

    def assign_input(self):
        # clk is already assigned
        # Assigns A and B
        super().assign_input()
        self.dut.l.value = self.l

    async def exec_test(self):
        self.assign_input()

        await Timer(1, "ns")
        await cocotb.start(self.clk.start())

        await Timer(self.l + 1, "ns")

        assert (self.dut.done.value, 1)

        # x bits should be resolved to 0, since the Flex module creates vectors bigger than actually filled
        # export COCOTB_RESOLVE_X=ZEROS
        self.assign_output(width=self.l)
        self.assert_result()


@cocotb.test()
async def test_vector_addition_flex_basic(dut):
    a = np.array([1, 2, 3])
    b = np.array([2, 3, 4])

    await VectorAdditionFlexTest(dut, a, b).exec_test()


@cocotb.test()
async def test_vector_addition_flex_random_simple(dut):
    test = VectorAdditionFlexTest(dut, [], [])
    max_val = 100

    for i in range(1000):
        # 128 is the maximum width addable by VectorAdditionFlex, as of writing the test
        length = random.randint(0, 128)
        test.A = utils.sample_array(-max_val, max_val, length)
        test.B = utils.sample_array(-max_val, max_val, length)
        await test.exec_test()


@cocotb.test()
async def test_vector_addition_flex_random_full_range(dut):
    test = VectorAdditionFlexTest(dut, [], [])
    max_val = utils.IEEE754_MAX_VAL / 2

    for i in range(1000):
        # see comment above regarding why 128
        length = random.randint(1, 128)
        test.A = utils.sample_array(-max_val, max_val, length)
        test.B = utils.sample_array(-max_val, max_val, length)
        await test.exec_test()
