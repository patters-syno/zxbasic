' TEST for Bitwise AND 32 bits

DIM a as ULong
DIM b as UByte

b = a bAND 0
b = a bAND 1
b = a bAND 0FFFFh
b = 0 bAND a
b = 1 bAND a
b = 0FFFFh bAND a
b = a bAND a

