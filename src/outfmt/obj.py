#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# --------------------------------------------
# CopyLeft (K) 2008
# by Jose M. Rodriguez de la Rosa
#
# This program is licensed under the
# GNU Public License v.3.0
#
# The code emission interface.
# --------------------------------------------

from .code_emitter import CodeEmitter


class ObjEmitter(CodeEmitter):
    """ Writes compiled code as an OBJ file.
    OBJ file is an ASCII text file containing binary code and relocatable
    information.
    """
    def emit(self, output_filename, program_name, loader_bytes, entry_point,
             program_bytes, aux_bin_blocks, aux_headless_bin_blocks):
        """ Emits resulting obj file.
        """
        with open(output_filename, 'wt', encoding='utf-8') as f:
            f.write('a')
