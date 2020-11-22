# -*- coding: utf-8 -*-
from typing import Optional, Any

from src.api.errmsg import error
from src.ast import Ast
from src.ast.tree import NotAnAstError


class Expr(Ast):
    """ A class derived from AST that will
    recursively parse its nodes and return the value
    """
    ignore = True  # Class flag
    funct = {
        '-': lambda x, y: x - y,
        '+': lambda x, y: x + y,
        '*': lambda x, y: x * y,
        '/': lambda x, y: x // y,
        '^': lambda x, y: x ** y,
        '%': lambda x, y: x % y,
        '&': lambda x, y: x & y,
        '|': lambda x, y: x | y,
        '~': lambda x, y: x ^ y,
        '<<': lambda x, y: x << y,
        '>>': lambda x, y: x >> y
    }

    def __init__(self, symbol=None):
        """ Initializes ancestor attributes, and
        ignore flags.
        """
        Ast.__init__(self)
        self.symbol = symbol

    @property
    def left(self):
        if self.children:
            return self.children[0]

    @left.setter
    def left(self, value):
        if self.children:
            self.children[0] = value
        else:
            self.children.append(value)

    @property
    def right(self):
        if len(self.children) > 1:
            return self.children[1]

    @right.setter
    def right(self, value):
        if len(self.children) > 1:
            self.children[1] = value
        elif self.children:
            self.children.append(value)
        else:
            self.children = [None, value]

    def eval(self):
        """ Recursively evals the node. Exits with an
        error if not resolved.
        """
        Expr.ignore = False
        result = self.try_eval()
        Expr.ignore = True

        return result

    def try_eval(self):
        """ Recursively evals the node. Returns None
        if it is still unresolved.
        """
        item = self.symbol.item

        if isinstance(item, int):
            return item

        if isinstance(item, Label):
            if item.defined:
                if isinstance(item.value, Expr):
                    return item.value.try_eval()
                else:
                    return item.value
            else:
                if Expr.ignore:
                    return None

                # Try to resolve into the global namespace
                error(self.symbol.lineno, "Undefined label '%s'" % item.name)
                return None

        try:
            if isinstance(item, tuple):
                return tuple(x.try_eval() for x in item)

            if isinstance(item, list):
                return [x.try_eval() for x in item]

            if item == '-' and len(self.children) == 1:
                return -self.left.try_eval()

            if item == '+' and len(self.children) == 1:
                return self.left.try_eval()

            try:
                return self.funct[item](self.left.try_eval(), self.right.try_eval())
            except ZeroDivisionError:
                error(self.symbol.lineno, 'Division by 0')
            except KeyError:
                pass

        except TypeError:
            pass

        return None

    def as_rpn(self):
        """ Returns a list of a stack-machine code representation of the Expression
        (Reverse Polish Notation)
        """
        item = self.symbol.item
        if isinstance(item, int):
            return [item]

        if isinstance(item, Label):
            return [item.name]

        if isinstance(item, tuple):
            return tuple(x.as_rpn() for x in item)

        if isinstance(item, list):
            return list(x.as_rpn() for x in item)

        if item == '-' and len(self.children) == 1:
            return self.left.as_rpn() + ['%NEG']

        if item == '+' and len(self.children) == 1:
            return self.left.as_rpn()

        return self.left.as_rpn() + self.right.as_rpn() + [f"%{item}"]


    @classmethod
    def makenode(cls, symbol, *nexts):
        """ Stores the symbol in an AST instance,
        and left and right to the given ones
        """
        result = cls(symbol)
        for i in nexts:
            if i is None:
                continue
            if not isinstance(i, cls):
                raise NotAnAstError(i)
            result.appendChild(i)

        return result


class Label:
    """ A class to store Label information (NAME, line number and Address)
    """
    def __init__(
            self,
            name: str,
            lineno: int,
            current_namespace: str,
            value: Optional[Any] = None,
            local: bool = False,
            namespace: str = None,
            is_address: bool = False
    ):
        """ Defines a Label object:
                - name : The label name. e.g. __LOOP
                - lineno : Where was this label defined.
                - address : Memory address or numeric value this label refers
                            to (None if undefined yet)
                - local : whether this is a local label or a global one
                - namespace: If the label is DECLARED (not accessed), this is
                        its prefixed namespace
                - is_address: Whether this label refers to a memory address (declared without EQU)
        """
        self._name = name
        self.lineno = lineno
        self.value = value
        self.local = local
        self.namespace = namespace
        self.current_namespace = current_namespace  # Namespace under which the label was referenced (not declared)
        self.is_address = is_address

    @property
    def defined(self):
        """ Returns whether it has a value already or not.
        """
        return self.value is not None

    def define(self, value, lineno: int, namespace: str):
        """ Defines label value. It can be anything. Even an AST
        """
        if self.defined:
            error(lineno, "label '%s' already defined at line %i" % (self.name, self.lineno))

        self.value = value
        self.lineno = lineno
        self.namespace = namespace

    def resolve(self, lineno):
        """ Evaluates label value. Exits with error (unresolved) if value is none
        """
        if not self.defined:
            error(lineno, "Undeclared label '%s'" % self.name)

        if isinstance(self.value, Expr):
            return self.value.eval()

        return self.value

    @property
    def name(self):
        return self._name
