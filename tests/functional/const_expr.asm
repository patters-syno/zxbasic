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
_f:
	DEFB 00
ZXBASIC_USER_DATA_END:
__MAIN_PROGRAM__:
	ld a, 6
	ld (_f), a
	ld a, 4
	ld (_f), a
	ld a, 5
	ld (_f), a
	ld a, 5
	ld (_f), a
	ld a, 6
	ld (_f), a
	ld a, 252
	ld (_f), a
	ld a, 5
	ld (_f), a
	xor a
	ld (_f), a
	ld a, 2
	ld (_f), a
	xor a
	ld (_f), a
	ld a, 1
	ld (_f), a
	ld a, 1
	ld (_f), a
	ld a, 1
	ld (_f), a
	ld a, 5
	ld (_f), a
	ld a, 53
	ld (_f), a
	ld a, 1
	ld (_f), a
	ld a, 5
	ld (_f), a
	ld a, 5
	ld (_f), a
	ld a, 5
	ld (_f), a
	ld a, 1
	ld (_f), a
	ld a, 5
	ld (_f), a
	ld a, 1
	ld (_f), a
	ld a, 1
	ld (_f), a
	ld a, 1
	ld (_f), a
	ld a, 1
	ld (_f), a
	ld a, 1
	ld (_f), a
	xor a
	ld (_f), a
	xor a
	ld (_f), a
	ld a, 1
	ld (_f), a
	xor a
	ld (_f), a
	xor a
	ld (_f), a
	ld a, 1
	ld (_f), a
	xor a
	ld (_f), a
	xor a
	ld (_f), a
	ld a, 1
	ld (_f), a
	xor a
	ld (_f), a
	xor a
	ld (_f), a
	ld a, 1
	ld (_f), a
	xor a
	ld (_f), a
	xor a
	ld (_f), a
	ld a, 1
	ld (_f), a
	xor a
	ld (_f), a
	ld a, 1
	ld (_f), a
	ld a, 1
	ld (_f), a
	ld a, 1
	ld (_f), a
	ld a, 1
	ld (_f), a
	xor a
	ld (_f), a
	ld a, 1
	ld (_f), a
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
