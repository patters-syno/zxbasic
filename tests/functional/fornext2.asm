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
_x:
	DEFB 00
ZXBASIC_USER_DATA_END:
__MAIN_PROGRAM__:
	xor a
	ld (_x), a
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
_test:
	push ix
	ld ix, 0
	add ix, sp
	ld a, 1
	ld (_x), a
	jp __LABEL0
__LABEL3:
__LABEL4:
	ld hl, _x
	inc (hl)
__LABEL0:
	ld a, 6
	ld hl, (_x - 1)
	cp h
	jp nc, __LABEL3
__LABEL2:
_test__leave:
	ld sp, ix
	pop ix
	ret
	;; --- end of user code ---
	END
