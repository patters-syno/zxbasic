# -*- coding: utf-8 -*-


from typing import NamedTuple
from typing import Any


class Container(NamedTuple):
    """ Single class container
    """
    item: Any
    lineno: int
