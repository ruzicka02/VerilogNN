from abc import ABC, abstractmethod

import numpy as np
from cocotb.triggers import Timer

import utils


class BaseTest(ABC):
    @abstractmethod
    def __init__(self, dut, *args):
        pass

    async def exec_test(self):
        self.assign_input()

        await Timer(1)

        self.assign_output()
        self.assert_result()

    @abstractmethod
    def assign_input(self):
        pass

    @abstractmethod
    def assign_output(self):
        pass

    @abstractmethod
    def assert_result(self):
        pass


class FloatingPointBaseTest(BaseTest):
    def __init__(self, dut, A, B):
        self.dut = dut
        self.A = A
        self.B = B
        self.result = None

    def assign_input(self):
        self.dut.A.value = utils.float_to_ieee754(self.A)
        self.dut.B.value = utils.float_to_ieee754(self.B)

    def assign_output(self):
        self.result = utils.ieee754_to_float(self.dut.result.value)


class VectorBaseTest(BaseTest):
    def __init__(self, dut, A, B):
        self.dut = dut
        self.A = np.array(A)
        self.B = np.array(B)
        self.result = None

    def assign_input(self):
        self.dut.A.value = utils.pack_ieee754_array(
            utils.array_to_ieee754_array(self.A))
        self.dut.B.value = utils.pack_ieee754_array(
            utils.array_to_ieee754_array(self.B))

    def assign_output(self, width=3):
        # TODO dynamic width
        temp = utils.unpack_ieee754_array(self.dut.result.value, width)
        self.result = utils.ieee754_array_to_array(temp)
