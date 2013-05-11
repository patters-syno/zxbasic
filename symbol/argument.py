#!/usr/bin/python
# -*- coding: utf-8 -*-
# vim: ts=4:et:sw=4:

# ----------------------------------------------------------------------
# Copyleft (K), Jose M. Rodriguez-Rosa (a.k.a. Boriel)
#
# This program is Free Software and is released under the terms of
#                    the GNU General License
# ----------------------------------------------------------------------

from api.constants import TYPE_SIZES
from symbol import Symbol
from typecast import SymbolTYPECAST


class SymbolARGUMENT(Symbol):
    ''' Defines an argument in a function call
    '''
    def __init__(self, value, byref, lineno):
        ''' Initializes the argument data. Byref must be set
        to True if this Argument is passed by reference.
        '''
        Symbol.__init__(self, value)
        self.lineno = lineno
        self.byref = byref
        
    @property
    def type_(self):
        return self.value.type_

    @property
    def size(self):
        return TYPE_SIZES[self.type_]

    def typecast(self, type_):
        ''' Apply type casting to the argument expression.
        Returns True on success.
        '''
        self.value = SymbolTYPECAST.make_typecast(type_, self.value, self.lineno)
        return self.value is not None
