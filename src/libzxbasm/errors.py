from src.api.errors import Error


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
