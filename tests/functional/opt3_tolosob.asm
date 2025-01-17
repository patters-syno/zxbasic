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
_toloTimer:
	DEFB 00, 00
_toloStatus:
	DEFB 00, 00
_sobando:
	DEFB 00
ZXBASIC_USER_DATA_END:
__MAIN_PROGRAM__:
__LABEL__inicio:
	ld de, 0
	ld hl, (_toloTimer)
	or a
	sbc hl, de
	jp nz, __LABEL__inicio
	ld a, 1
	ld (_sobando), a
	sub 2
	jp nz, __LABEL3
	ld hl, (_toloTimer)
	inc hl
	ld a, (hl)
	sub 12
	jp nz, __LABEL3
	ld a, 3
	ld (_sobando), a
	jp __LABEL__inicio
__LABEL3:
	ld a, (_sobando)
	or a
	jp nz, __LABEL__inicio
	ld de, 10
	ld hl, (_toloTimer)
	or a
	sbc hl, de
	jp nz, __LABEL__inicio
	ld hl, (_toloStatus)
	ld a, (hl)
	and 2
	jp nz, __LABEL__inicio
	ld a, 1
	ld (_sobando), a
__LABEL__pontolosobando:
	jp __LABEL__inicio
	;; --- end of user code ---
#line 1 "/zxbasic/src/arch/zx48k/library-asm/eq16.asm"
__EQ16:	; Test if 16bit values HL == DE
		; Returns result in A: 0 = False, FF = True
			xor a	; Reset carry flag
			sbc hl, de
			ret nz
			inc a
			ret
#line 38 "opt3_tolosob.bas"
	END
