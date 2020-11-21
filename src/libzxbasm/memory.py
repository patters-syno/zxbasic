# -*- coding: utf-8 -*-

from typing import Dict
from typing import List

from src.api import global_ as gl
from src.api.debug import __DEBUG__
from src.api.errmsg import error, warning

from . import common

from .common import DOT
from .common import GLOBAL_NAMESPACE
from .common import MAX_MEM

from .expr import Label
from .asm import Asm


class Memory:
    """ A class to describe assembled memory
    """

    def __init__(self, org=0):
        """ Initializes the origin of code.
        0 by default """
        self.index = org  # ORG address (can be changed on the fly)
        self.memory_bytes = {}  # An array (associative) containing memory bytes
        self.local_labels: List[Dict[str, Label]] = [{}]  # Local labels in the current memory scope
        self.global_labels: Dict[str, Label] = self.local_labels[0]  # Global memory labels
        self.orgs = {}  # Origins of code for asm mnemonics. This will store corresponding asm instructions
        self.ORG = org  # last ORG value set
        self.scopes = []

    def enter_proc(self, lineno):
        """ Enters (pushes) a new context
        """
        self.local_labels.append({})  # Add a new context
        self.scopes.append(lineno)
        __DEBUG__('Entering scope level %i at line %i' % (len(self.scopes), lineno))

    def set_org(self, value, lineno):
        """ Sets a new ORG value
        """
        if value < 0 or value > MAX_MEM:
            error(lineno, "Memory ORG out of range [0 .. 65535]. Current value: %i" % value)

        self.index = self.ORG = value

    @staticmethod
    def id_name(label: str, namespace: str = None):
        """ Given a name and a namespace, resolves
        returns the name as namespace + '.' + name. If namespace
        is none, the current NAMESPACE is used
        """
        if not label.startswith(DOT):
            if namespace is None:
                namespace = common.NAMESPACE
            ex_label = namespace + label  # The mangled namespace.label_name label
        else:
            if namespace is None:
                namespace = GLOBAL_NAMESPACE  # Global namespace
            ex_label = label

        return ex_label, namespace

    @property
    def org(self):
        """ Returns current ORG index
        """
        return self.index

    def __set_byte(self, byte: int, lineno: int):
        """ Sets a byte at the current location,
        and increments org in one. Raises an error if org > MAX_MEMORY
        """
        if byte < 0 or byte > 255:
            error(lineno, 'Invalid byte value %i' % byte)

        self.memory_bytes[self.org] = byte
        self.index += 1  # Increment current memory pointer

    def exit_proc(self, lineno: int):
        """ Exits current procedure. Local labels are transferred to global
        scope unless they have been marked as local ones.

        Raises an error if no current local context (stack underflow)
        """
        __DEBUG__('Exiting current scope from lineno %i' % lineno)

        if len(self.local_labels) <= 1:
            error(lineno, 'ENDP in global scope (with no PROC)')
            return

        for label in self.local_labels[-1].values():
            if label.local:
                if not label.defined:
                    error(lineno, "Undefined LOCAL label '%s'" % label.name)
                    return
                continue

            name = label.name
            _lineno = label.lineno
            value = label.value

            if name not in self.global_labels.keys():
                self.global_labels[name] = label
            else:
                self.global_labels[name].define(value, _lineno, namespace=common.NAMESPACE)

        self.local_labels.pop()  # Removes current context
        self.scopes.pop()

    def set_memory_slot(self):
        if self.org not in self.orgs.keys():
            self.orgs[self.org] = ()  # Declares an empty memory slot if not already done
            self.memory_bytes[self.org] = ()  # Declares an empty memory slot if not already done

    def add_instruction(self, instr):
        """ This will insert an asm instruction at the current memory position
        in a t-uple as (mnemonic, params).

        It will also insert the opcodes at the memory_bytes
        """
        if gl.has_errors:
            return

        __DEBUG__('%04Xh [%04Xh] ASM: %s' % (self.org, self.org - self.ORG, instr.asm))
        self.set_memory_slot()
        self.orgs[self.org] += (instr,)

        for byte in instr.bytes():
            self.__set_byte(byte, instr.lineno)

    def dump(self):
        """ Returns a tuple containing code ORG (origin address), and a list of bytes (OUTPUT)
        """
        org = min(self.memory_bytes.keys())  # Org is the lowest one
        OUTPUT = []
        align = []

        for label in self.global_labels.values():
            if not label.defined:
                error(label.lineno, "Undefined GLOBAL label '%s'" % label.name)

        for i in range(org, max(self.memory_bytes.keys()) + 1):
            if gl.has_errors:
                return org, OUTPUT

            try:
                try:
                    a = [x for x in self.orgs[i] if isinstance(x, Asm)]  # search for asm instructions

                    if not a:
                        align.append(0)  # Fill with ZEROes not used memory regions
                        continue

                    OUTPUT += align
                    align = []
                    a = a[0]
                    if a.pending:
                        a.arg = a.argval()
                        a.pending = False
                        tmp = a.bytes()

                        for r in range(len(tmp)):
                            self.memory_bytes[i + r] = tmp[r]
                except KeyError:
                    pass

                OUTPUT.append(self.memory_bytes[i])

            except KeyError:
                OUTPUT.append(0)  # Fill with ZEROes not used memory regions

        return org, OUTPUT

    def declare_label(self, label: str, lineno: int, value=None, local: bool = False, namespace: str = None):
        """ Sets a label with the given value or with the current address (org)
        if no value is passed.

        Exits with error if label already set,
        otherwise return the label object
        """
        ex_label, namespace = Memory.id_name(label, namespace)

        is_address = value is None
        if value is None:
            value = self.org

        if ex_label in self.local_labels[-1].keys():
            self.local_labels[-1][ex_label].define(value, lineno, namespace=common.NAMESPACE)
            self.local_labels[-1][ex_label].is_address = is_address
        else:
            self.local_labels[-1][ex_label] = Label(ex_label, lineno, common.NAMESPACE, value, local, namespace,
                                                    is_address)

        self.set_memory_slot()

        return self.local_labels[-1][ex_label]

    def get_label(self, label: str, lineno: int):
        """ Returns a label in the current context or in the global one.
        If the label does not exists, creates a new one and returns it.
        """
        ex_label, namespace = Memory.id_name(label)

        for i in range(len(self.local_labels) - 1, -1, -1):  # Downstep
            result = self.local_labels[i].get(ex_label, None)
            if result is not None:
                return result

        result = Label(ex_label, lineno, current_namespace=common.NAMESPACE, namespace=namespace)
        self.local_labels[-1][ex_label] = result  # HINT: no namespace

        return result

    def set_label(self, label: str, lineno: int, local: bool = False):
        """ Sets a label, lineno and local flag in the current scope
        (even if it exist in previous scopes). If the label exist in
        the current scope, changes it flags.

        The resulting label is returned.
        """
        ex_label, namespace = Memory.id_name(label)

        if ex_label in self.local_labels[-1].keys():
            result = self.local_labels[-1][ex_label]
            result.lineno = lineno
        else:
            result = self.local_labels[-1][ex_label] = Label(ex_label, lineno, current_namespace=common.NAMESPACE,
                                                             namespace=common.NAMESPACE)

        if result.local == local:
            warning(lineno, "label '%s' already declared as LOCAL" % label)

        result.local = local

        return result

    @property
    def memory_map(self):
        """ Returns a (very long) string containing a memory map
            hex address: label
        """
        return '\n'.join(sorted("%04X: %s" % (x.value, x.name) for x in self.global_labels.values() if x.is_address))
