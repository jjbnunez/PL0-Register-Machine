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

MAX_LEXI_LEVELS = 3
MAX_CODE_LENGTH = 500
MAX_STACK_HEIGHT = 2000
MAX_REGISTERS = 8

"""
Execution and File I/O
"""


def _readFile(fileName):
    scriptDirectory = os.path.dirname(__file__)
    filePath = os.path.join(scriptDirectory, fileName)
    with open(filePath, 'r', encoding='utf-8') as file:
        lines = file.readlines()
    data = []
    for line in lines:
        data.append(line.replace('\n', ''))
    return data


def main():
    inputFileName = "input.csv"
    inputData = _readFile(inputFileName)
    print(inputFileName)


if __name__ == "__main__":
    main()
