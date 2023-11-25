# ----------------------------------------------------------------------------
# University of Central Florida
# COP3402 - Fall 2017
# Program Authors: Jonah Yonker, Jorge B Nunez
# Instructor: Euripedes Montagne
# ----------------------------------------------------------------------------
#   pm0.py
#
# 	This is a P-machine, which is a stack machine with two memory stores: the
# 	"stack," which is organized as a stack and contains the data to be used by
# 	the CPU, and the "code," which is organized as a list and contains the
# 	instructions for the machine. The PM/0 CPU has four registers to handle
# 	the stack and code segments: the base pointer, the stack pointer, the
# 	program counter, and the instruction register. The machine also has a
# 	register file with eight registers.

import os
import csv

MAX_LEXI_LEVELS = 3
MAX_CODE_LENGTH = 500
MAX_STACK_HEIGHT = 2000
MAX_REGISTERS = 8

"""
Execution and File I/O
"""

mapping = {
    1: "LIT",
    2: "RTN",
    3: "LOD",
    4: "STO",
    5: "CAL",
    6: "INC",
    7: "JMP",
    8: "JPC",
    9: "SIO",
    10: "NEG",
    11: "ADD",
    12: "SUB",
    13: "MUL",
    14: "DIV",
    15: "ODD",
    16: "MOD",
    17: "EQL",
    18: "NEQ",
    19: "LSS",
    20: "LEQ",
    21: "GTR",
    22: "GEQ",
}


class Instruction:

    def __init__(self, op, r, l, m):
        self.op = op
        self.r = r
        self.l = l
        self.m = m

    def getOpString(self):
        return mapping.get(int(self.op), "UNK")

    def __str__(self):
        items = [self.getOpString(), self.r, self.l, self.m]
        return " ".join(items)


class Cpu:

    def __init__(self, code):
        self.code = code
        self.programCounter = 0
        self.pcPrevious = 0
        self.basePointer = 1
        self.stackPointer = 0
        self.haltFlag = 0
        self.instructionRegister = [0]*4
        self.stack = [0]*MAX_STACK_HEIGHT
        self.callTrace = [-1]*MAX_LEXI_LEVELS
        self.registerFile = [0]*MAX_REGISTERS

# Helper function provided by homework documentation.


def _base(bl, l, stack):
    while l > 0:
        val = stack[bl+l]
        l -= 1
    return val


def _readFile(fileName):

    scriptDirectory = os.path.dirname(__file__)

    filePath = os.path.join(scriptDirectory, fileName)

    with open(filePath, 'r', encoding='utf-8') as file:
        reader = csv.reader(file, delimiter=',')
        data = []
        for row in reader:
            data.append(row)

    return data

    # data = []
    # for line in lines:
    #    data.append(line.replace('\n', ''))
    # return data


def main():

    inputFileName = "input.csv"

    inputData = _readFile(inputFileName)

    instructions = []

    for row in inputData:
        instructions.append(Instruction(row[0], row[1], row[2], row[3]))

    cpu = Cpu(instructions)


if __name__ == "__main__":
    main()
