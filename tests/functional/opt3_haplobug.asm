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
_dataSprite:
	DEFB 00, 00
ZXBASIC_USER_DATA_END:
__MAIN_PROGRAM__:
	ld hl, (_dataSprite)
	ld de, 26
	add hl, de
	ld de, 0
	ld (hl), e
	inc hl
	ld (hl), d
	ld hl, (_dataSprite)
	ld de, 11
	add hl, de
	push hl
	ld hl, (_dataSprite)
	ld de, 28
	add hl, de
	ld a, (hl)
	pop hl
	ld (hl), a
	ld hl, (_dataSprite)
	ld de, 12
	add hl, de
	push hl
	ld hl, (_dataSprite)
	ld de, 29
	add hl, de
	ld a, (hl)
	pop hl
	ld (hl), a
	ld hl, (_dataSprite)
	inc de
	add hl, de
	xor a
	ld (hl), a
	ld bc, 0
__END_PROGRAM:
	di
	ld hl, (__CALL_BACK__)
	ld sp, hl
	exx
	pop hl
	pop iy
	pop ix
	exx
	ei
	ret
	;; --- end of user code ---
	END
