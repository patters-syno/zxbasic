	org 32768
__START_PROGRAM:
	di
	push ix
	push iy
	exx
	push hl
	exx
	ld hl, 0
	add hl, sp
	ld (__CALL_BACK__), hl
	ei
	jp __MAIN_PROGRAM__
__CALL_BACK__:
	DEFW 0
ZXBASIC_USER_DATA:
	; Defines USER DATA Length in bytes
ZXBASIC_USER_DATA_LEN EQU ZXBASIC_USER_DATA_END - ZXBASIC_USER_DATA
	.__LABEL__.ZXBASIC_USER_DATA_LEN EQU ZXBASIC_USER_DATA_LEN
	.__LABEL__.ZXBASIC_USER_DATA EQU ZXBASIC_USER_DATA
_Map:
	DEFB 00, 00
_MapPtr:
	DEFW (_Map) + (2)
ZXBASIC_USER_DATA_END:
__MAIN_PROGRAM__:
	ld hl, 0
	ld b, h
	ld c, l
__END_PROGRAM:
	di
	ld hl, (__CALL_BACK__)
	ld sp, hl
	exx
	pop hl
	exx
	pop iy
	pop ix
	ei
	ret
_p:
	push ix
	ld ix, 0
	add ix, sp
	ld hl, 0
	push hl
	push ix
	pop hl
	ld bc, -2
	add hl, bc
	ex de, hl
	ld hl, __LABEL0
	ld bc, 2
	ldir
_p__leave:
	ld sp, ix
	pop ix
	ret
	;; --- end of user code ---
__LABEL0:
	DEFW _Map
	END
