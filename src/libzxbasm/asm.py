#!/usr/bin/env python
# -*- coding: utf-8 -*-
# vim: ts=4:et:sw=4

import re

from src.api import global_ as gl
from src.api.errmsg import error
from src.api.errors import Error

from .container import Container
from .expr import Expr
from .z80 import Opcode
from .z80 import Z80SET


# Reg. Exp. for counting N args in an asm mnemonic
ARGre = re.compile(r'\bN+\b')

Z80_re = {}  # Reg. Expr dictionary to cache them

Z80_8REGS = ('A', 'B', 'C', 'D', 'E', 'H', 'L',
             'IXh', 'IYh', 'IXl', 'IYl', 'I', 'R')

Z80_16REGS = {'AF': ('A', 'F'), 'BC': ('B', 'C'), 'DE': ('D', 'E'),
              'HL': ('H', 'L'), 'SP': (),
              'IX': ('IXh', 'IXl'), 'IY': ('IYh', 'IYl')
              }


def num2bytes(x, bytes_):
    """ Returns x converted to a little-endian t-uple of bytes.
    E.g. num2bytes(255, 4) = (255, 0, 0, 0)
    """
    if not isinstance(x, int):  # If it is another "thing", just return ZEROs
        return tuple([0] * bytes_)

    x = x & ((2 << (bytes_ * 8)) - 1)  # mask the initial value
    result = ()

    for i in range(bytes_):
        result += (x & 0xFF,)
        x >>= 8

    return result


class InvalidMnemonicError(Error):
    """ Exception raised when an invalid Mnemonic has been emitted.
    """

    def __init__(self, mnemo):
        self.msg = "Invalid mnemonic '%s'" % mnemo
        self.mnemo = mnemo


class InvalidArgError(Error):
    """ Exception raised when an invalid argument has been emitted.
    """

    def __init__(self, arg):
        self.msg = "Invalid argument '%s'. It must be an integer." % str(arg)
        self.mnemo = arg


class InternalMismatchSizeError(Error):
    """ Exception raised when an invalid instruction length has been emitted.
    """

    def __init__(self, current_size, asm):
        a = '' if current_size == 1 else 's'
        b = '' if asm.size == 1 else 's'

        self.msg = ("Invalid instruction [%s] size (%i byte%s). "
                    "It should be %i byte%s." % (asm.asm, current_size, a,
                                                 asm.size, b))
        self.current_size = current_size
        self.asm = asm


class AsmInstruction(Opcode):
    """ Derives from Opcode. This one checks for opcode validity.
    """
    def __init__(self, asm, arg=None):
        """ Parses the given asm instruction and validates
        it against the Z80SET table. Raises InvalidMnemonicError
        if not valid.

        It uses the Z80SET global dictionary. Args is an optional
        argument (it can be a Label object or a value)
        """
        if isinstance(arg, list):
            arg = tuple(arg)

        if arg is None:
            arg = ()

        if arg is not None and not isinstance(arg, tuple):
            arg = (arg,)

        asm = asm.split(';', 1)  # Try to get comments out, if any
        if len(asm) > 1:
            self.comments = ';' + asm[1]
        else:
            self.comments = ''

        asm = asm[0]
        self.mnemo = asm.upper()

        if self.mnemo not in Z80SET.keys():
            raise InvalidMnemonicError(asm)

        Z80 = Z80SET[self.mnemo]

        super().__init__(asm=asm, time=Z80.T, size=Z80.size, opcode=Z80.opcode)
        self.argbytes = tuple([len(x) for x in ARGre.findall(asm)])
        self.arg = arg
        self.arg_num = len(ARGre.findall(asm))

    def argval(self):
        """ Returns the value of the arg (if any) or None.
        If the arg. is not an integer, an error be triggered.
        """
        if self.arg is None or any(x is None for x in self.arg):
            return None

        for x in self.arg:
            if not isinstance(x, int):
                raise InvalidArgError(self.arg)

        return self.arg

    def bytes(self):
        """ Returns a t-uple with instruction bytes (integers)
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
    """ Class extension to AsmInstruction with a short name :-P
    and will trap some exceptions and convert them to error msgs.

    It will also record source line
    """

    def __init__(self, lineno, asm, arg=None):
        self.lineno = lineno

        if asm not in ('DEFB', 'DEFS', 'DEFW'):
            try:
                super(Asm, self).__init__(asm, arg)
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
                self.arg = tuple([Expr(Container(ord(x), lineno)) for x in arg])
            else:
                self.arg = arg

            self.arg_num = len(self.arg)

    def bytes(self):
        """ Returns opcodes
        """
        if self.asm not in ('DEFB', 'DEFS', 'DEFW'):
            if self.pending:
                tmp = self.arg  # Saves current arg temporarily
                self.arg = tuple([0] * self.arg_num)
                result = super(Asm, self).bytes()
                self.arg = tmp  # And recovers it

                return result

            return super(Asm, self).bytes()

        if self.asm == 'DEFB':
            if self.pending:
                return tuple([0] * self.arg_num)

            return tuple(x & 0xFF for x in self.argval())

        if self.asm == 'DEFS':
            if self.pending:
                N = self.arg[0]
                if isinstance(N, Expr):
                    N = N.eval()
                return tuple([0] * N)  # ??

            args = self.argval()
            num = args[1] & 0xFF
            return tuple([num] * args[0])

        if self.pending:  # DEFW
            return tuple([0] * 2 * self.arg_num)

        result = ()
        for i in self.argval():
            x = i & 0xFFFF
            result += (x & 0xFF, x >> 8)

        return result

    def argval(self):
        """ Solve args values or raise errors if not
        defined yet
        """
        if gl.has_errors:
            return [None]

        if self.asm in ('DEFB', 'DEFS', 'DEFW'):
            return tuple([x.eval() if isinstance(x, Expr) else x for x in self.arg])

        self.arg = tuple([x if not isinstance(x, Expr) else x.eval() for x in self.arg])
        if gl.has_errors:
            return [None]

        if self.asm.split(' ')[0] in ('JR', 'DJNZ'):  # A relative jump?
            if self.arg[0] < -128 or self.arg[0] > 127:
                error(self.lineno, 'Relative jump out of range')
                return [None]

        return super().argval()
