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
	DEFB 00, 00
_b:
	DEFB 00
ZXBASIC_USER_DATA_END:
__MAIN_PROGRAM__:
	ld hl, (_a)
	ld a, l
	ld (_b), a
	ld de, 1
	ld hl, (_a)
	call __BOR16
	ld a, l
	ld (_b), a
	ld hl, (_a)
	ld hl, 0FFFFh
	ld a, l
	ld (_b), a
	ld hl, (_a)
	ld a, l
	ld (_b), a
	ld de, 1
	ld hl, (_a)
	call __BOR16
	ld a, l
	ld (_b), a
	ld hl, (_a)
	ld hl, 0FFFFh
	ld a, l
	ld (_b), a
	ld de, (_a)
	ld hl, (_a)
	call __BOR16
	ld a, l
	ld (_b), a
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
#line 1 "/zxbasic/src/arch/zx48k/library-asm/bor16.asm"
; vim:ts=4:et:
	; FASTCALL bitwise or 16 version.
	; result in HL
; __FASTCALL__ version (operands: A, H)
	; Performs 16bit or 16bit and returns the boolean
; Input: HL, DE
; Output: HL <- HL OR DE
__BOR16:
		ld a, h
		or d
	    ld h, a
	    ld a, l
	    or e
	    ld l, a
	    ret
#line 46 "bor16.bas"
	END
