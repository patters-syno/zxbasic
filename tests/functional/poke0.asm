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
_i:
	DEFB 00h
	DEFB 40h
_j:
	DEFB 00
ZXBASIC_USER_DATA_END:
__MAIN_PROGRAM__:
	xor a
	ld (_j), a
	jp __LABEL0
__LABEL3:
	ld a, 185
	ld hl, (_i)
	ld (hl), a
	ld hl, (_i)
	inc hl
	ld (_i), hl
__LABEL4:
	ld hl, _j
	inc (hl)
__LABEL0:
	ld a, 250
	ld hl, (_j - 1)
	cp h
	jp nc, __LABEL3
__LABEL2:
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
	;; --- end of user code ---
	END
