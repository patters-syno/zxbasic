#!/usr/bin/env python
# -*- coding: utf-8 -*-

from .code_emitter import CodeEmitter

from .binary import BinaryEmitter
from .obj import ObjEmitter
from .tzx import TZX
from .tap import TAP


EMITTERS = {
    'bin': BinaryEmitter,
    'obj': ObjEmitter,
    'tzx': TZX,
    'tap': TAP
}

__all__ = [
    'CodeEmitter',
    'BinaryEmitter',
    'ObjEmitter',
    'TZX',
    'TAP',
]
