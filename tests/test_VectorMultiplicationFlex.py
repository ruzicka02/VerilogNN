import math
import random

import cocotb
import numpy as np
from cocotb.clock import Clock
from cocotb.triggers import Timer

import utils
import test_VectorMultiplicationPar


MOD_COUNT = 1


class VectorMultiplicationFlexTest(test_VectorMultiplicationPar.VectorMultiplicationParTest):
    def __init__(self, dut, A, B):
        super().__init__(dut, A, B)
        self.clk = Clock(self.dut.clk, 1, units="ns")
        assert len(A) == len(B)
        self.vlen = len(A)

    def assign_input(self):
        # clk is already assigned
        # Assigns A and B
        super().assign_input()
        self.dut.vlen.value = self.vlen

    async def exec_test(self):
        self.assign_input()

        await Timer(1, "ns")
        await cocotb.start(self.clk.start())

        counter = 0
        while (True):
            done = self.dut.done.value
            print(f"{counter:04} - Done: {done}")
            counter += 1
            if done:
                break

        print("Waiting for:", math.ceil(self.vlen / MOD_COUNT) + 1)

        # more MOD_COUNT means that it will be finished faster.
        # This has to be the same MOD_COUNT, which is used in the module
        await Timer(math.ceil(self.vlen / MOD_COUNT) + 1, "ns")

        assert self.dut.done.value == 1

        # x bits should be resolved to 0, since the Flex module creates vectors bigger than actually filled
        # export COCOTB_RESOLVE_X=ZEROS
        self.assign_output()
        self.assert_result()


@cocotb.test()
async def test_vector_multiplication_flex_basic(dut):
    a = np.array([1, 2, 3])
    b = np.array([2, 3, 4])

    await VectorMultiplicationFlexTest(dut, a, b).exec_test()


@cocotb.test()
async def test_vector_multiplication_flex_random_simple(dut):
    test = VectorMultiplicationFlexTest(dut, [], [])
    max_val = 100

    for i in range(1000):
        length = random.randint(1, 128)
        test.A = utils.sample_array(-max_val, max_val, length)
        test.B = utils.sample_array(-max_val, max_val, length)
        await test.exec_test()


@cocotb.test()
async def test_vector_multiplication_flex_random_full_range(dut):
    test = VectorMultiplicationFlexTest(dut, [], [])
    # / 10 because there can be problems when mutliplying 2 arrays with multiple values close to max
    max_val = math.sqrt(utils.IEEE754_MAX_VAL) / 10

    for i in range(1000):
        length = random.randint(1, 128)
        test.A = utils.sample_array(-max_val, max_val, length)
        test.B = utils.sample_array(-max_val, max_val, length)
        await test.exec_test()
