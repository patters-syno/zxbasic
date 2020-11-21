# -*- coding: utf-8 -*-
# Some constants

# Constants
MAX_MEM = 65535  # Max memory limit
DOT = '.'  # NAMESPACE separator
GLOBAL_NAMESPACE = DOT

# Global variables
NAMESPACE = GLOBAL_NAMESPACE  # Current namespace (defaults to '.'). It's a prefix added to each global label


def init():
    global NAMESPACE
    global GLOBAL_NAMESPACE

    NAMESPACE = GLOBAL_NAMESPACE
