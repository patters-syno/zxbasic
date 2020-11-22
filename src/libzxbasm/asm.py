#!/usr/bin/env python
# -*- coding: utf-8 -*-
# vim: ts=4:et:sw=4

import re
import collections

from typing import List
from typing import Any
from typing import Optional
from typing import Iterable

from src.api import global_ as gl
from src.api.errmsg import error
from src.api.errors import Error

from .container import Container
from .errors import InvalidMnemonicError
from .errors import InvalidArgError
from .errors import InternalMismatchSizeError
from .expr import Expr
from .z80 import Opcode
from .z80 import Z80SET

from .asmlex import Token

# ------------------------------------------------
#  Constants
# ------------------------------------------------

# Reg. Exp. for counting N args in an asm mnemonic
ARGre = re.compile(r'\bN+\b')

# Relative jumps
RELATIVE_JUMPS = ('JR', 'DJNZ')

# DEFS
DEFB = Token.DEFB
DEFS = Token.DEFS
DEFW = Token.DEFW

DEF_TOKENS = {DEFB, DEFS, DEFW}


def num2bytes(x: Any, length: int) -> List[int]:
    """ Returns x converted to a little-endian t-uple of bytes.
    E.g. num2bytes(255, 4) = (255, 0, 0, 0)
    """
    if not isinstance(x, int):  # If it is another "thing", just return ZEROs
        return [0] * length

    x = x & ((2 << (length * 8)) - 1)  # mask the initial value
    result = []

    for i in range(length):
        result.append(x & 0xFF)
        x >>= 8

    return result


class AsmInstruction(Opcode):
    """ Derives from Opcode. This one checks for opcode validity.
    """
    def __init__(self, asm, arg: Optional[Iterable[Any]] = None):
        """ Parses the given asm instruction and validates
        it against the Z80SET table. Raises InvalidMnemonicError
        if not valid.

        It uses the Z80SET global dictionary. Args is an optional
        argument (it can be a Label object or a value)
        """
        asm = asm.split(';', 1)  # Try to get comments out, if any
        if len(asm) > 1:
            self.comments = ';' + asm[1]
        else:
            self.comments = ''

        asm = asm[0]
        self.mnemo: str = asm.upper()

        if self.mnemo not in Z80SET.keys():
            raise InvalidMnemonicError(asm)

        Z80 = Z80SET[self.mnemo]

        super().__init__(asm=asm, time=Z80.T, size=Z80.size, opcode=Z80.opcode)
        self.argbytes = tuple([len(x) for x in ARGre.findall(asm)])
        self.arg_num: int = len(ARGre.findall(asm))

        if arg is None:
            arg = []
        elif not isinstance(arg, collections.Iterable):
            arg = [arg]
        else:
            arg = list(arg)

        self.arg = arg

    @property
    def arg(self) -> List[Any]:
        """ The arguments of the instruction as a list of integers or Expr objects
        """
        return self._arg

    @arg.setter
    def arg(self, value: Optional[Iterable[Any]]):
        self._arg = list(value) if value is not None else []

    def argval(self) -> Optional[List[int]]:
        """ Returns the value of the arg (if any) or None.
        If the arg. is not an integer, an error be triggered.
        """
        if self.arg is None or any(x is None for x in self.arg):
            return None

        if not all(isinstance(x, int) for x in self.arg):
            raise InvalidArgError(self.arg)

        return self.arg

    def bytes(self) -> List[int]:
        """ Returns a list with instruction bytes (integers)
        """
        result = []
        op = self.opcode.split(' ')
        argi = 0

        while op:
            q = op.pop(0)

            if q == 'XX':
                for k in range(self.argbytes[argi] - 1):
                    op.pop(0)

                result.extend(num2bytes(self.argval()[argi], self.argbytes[argi]))
                argi += 1
            else:
                result.append(int(q, 16))  # Add opcode

        if len(result) != self.size:
            raise InternalMismatchSizeError(len(result), self)

        return result

    def __str__(self):
        return self.asm


class Asm(AsmInstruction):
    """ Class extension to AsmInstruction which allows also DEFB, DEFW, DEFS
    as pseudo-opcodes. These opcodes allow more than 1 argument (list of bytes defined).
    It will also trap some exceptions and convert them to error msgs and also records
    source lineno.
    """
    def __init__(self, lineno: int, asm, arg=None):
        self.lineno = lineno
        self.original_args = arg

        if asm not in DEF_TOKENS:
            try:
                super().__init__(asm, arg)
            except Error as v:
                error(lineno, v.msg)
                return

            self.pending = len([x for x in self.arg if isinstance(x, Expr) and x.try_eval() is None]) > 0

            if not self.pending:
                self.arg = self.argval()
        else:
            self.asm = asm
            self.pending = True

            if isinstance(arg, str):
                self.arg = [Expr(Container(ord(x), lineno)) for x in arg]
            else:
                self.arg = arg

            self.arg_num = len(self.arg)

    def bytes(self) -> List[int]:
        """ Returns opcodes
        """
        if self.asm not in DEF_TOKENS:
            if self.pending:
                tmp = self.arg  # Saves current arg temporarily
                self.arg = [0] * self.arg_num
                result = super().bytes()
                self.arg = tmp  # And recovers it

                return result

            return super().bytes()

        if self.asm == DEFB:
            if self.pending:
                return [0] * self.arg_num

            return [x & 0xFF for x in self.argval()]

        if self.asm == DEFS:
            if self.pending:
                n = self.arg[0]
                if isinstance(n, Expr):
                    n = n.eval()
                return [0] * n

            args = self.argval()
            num = args[1] & 0xFF
            return [num] * args[0]

        if self.pending:  # DEFW
            return [0] * 2 * self.arg_num

        result = []
        for i in self.argval():
            x = i & 0xFFFF
            result.extend([x & 0xFF, x >> 8])

        return result

    def argval(self):
        """ Solve args values or raise errors if not defined yet
        """
        if gl.has_errors:
            return [None]

        if self.asm in DEF_TOKENS:
            return tuple([x.eval() if isinstance(x, Expr) else x for x in self.arg])

        self.arg = tuple([x if not isinstance(x, Expr) else x.eval() for x in self.arg])
        if gl.has_errors:
            return [None]

        if self.asm.split(' ')[0] in RELATIVE_JUMPS:  # A relative jump?
            if self.arg[0] < -128 or self.arg[0] > 127:
                error(self.lineno, 'Relative jump out of range')
                return [None]

        return super().argval()
