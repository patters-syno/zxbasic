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
_a:
	DEFB 00, 00, 00, 00
_c:
	DEFB 00
ZXBASIC_USER_DATA_END:
__MAIN_PROGRAM__:
	ld de, 5
	ld hl, 6553
	ld (_a), hl
	ld (_a + 2), de
	ld hl, (_a)
	ld de, (_a + 2)
	call __NOT32
	ld (_c), a
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
#line 1 "/zxbasic/src/arch/zx48k/library-asm/not32.asm"
	; -------------------------------------------------------------
	; 32 bit logical NOT
	; -------------------------------------------------------------
__NOT32:	; A = ¬A
		ld a, d
		or e
		or h
		or l
		sub 1	; Gives CARRY only if 0
		sbc a, a; Gives 0 if not carry, FF otherwise
		ret
#line 25 "25.bas"
	END
