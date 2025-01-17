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
	DEFB 00h
_c:
	DEFB 0FFh
	DEFB 7Fh
	DEFB 00h
	DEFB 00h
_d:
	DEFB 00h
	DEFB 0FEh
	DEFB 0FFh
	DEFB 0FFh
_result:
	DEFB 00, 00
ZXBASIC_USER_DATA_END:
__MAIN_PROGRAM__:
	ld hl, (_c)
	ld de, (_c + 2)
	ld (_result), hl
	ld hl, (_c)
	ld de, (_c + 2)
	call __SHRL32
	ld (_result), hl
	ld hl, (_c)
	ld de, (_c + 2)
	ld b, 2
__LABEL0:
	call __SHRL32
	djnz __LABEL0
	ld (_result), hl
	ld a, (_a)
	ld b, a
	ld hl, (_c)
	ld de, (_c + 2)
	or a
	jr z, __LABEL2
__LABEL1:
	call __SHRL32
	djnz __LABEL1
__LABEL2:
	ld (_result), hl
	ld hl, (_c)
	ld de, (_c + 2)
	ld (_result), hl
	ld hl, (_c)
	ld de, (_c + 2)
	call __SHL32
	ld (_result), hl
	ld hl, (_c)
	ld de, (_c + 2)
	ld b, 2
__LABEL3:
	call __SHL32
	djnz __LABEL3
	ld (_result), hl
	ld a, (_a)
	ld b, a
	ld hl, (_c)
	ld de, (_c + 2)
	or a
	jr z, __LABEL5
__LABEL4:
	call __SHL32
	djnz __LABEL4
__LABEL5:
	ld (_result), hl
	ld hl, (_d)
	ld de, (_d + 2)
	ld (_result), hl
	ld hl, (_d)
	ld de, (_d + 2)
	call __SHRA32
	ld (_result), hl
	ld hl, (_d)
	ld de, (_d + 2)
	ld b, 2
__LABEL6:
	call __SHRA32
	djnz __LABEL6
	ld (_result), hl
	ld a, (_a)
	ld b, a
	ld hl, (_d)
	ld de, (_d + 2)
	or a
	jr z, __LABEL8
__LABEL7:
	call __SHRA32
	djnz __LABEL7
__LABEL8:
	ld (_result), hl
	ld hl, (_d)
	ld de, (_d + 2)
	ld (_result), hl
	ld hl, (_d)
	ld de, (_d + 2)
	call __SHL32
	ld (_result), hl
	ld hl, (_d)
	ld de, (_d + 2)
	ld b, 2
__LABEL9:
	call __SHL32
	djnz __LABEL9
	ld (_result), hl
	ld a, (_a)
	ld b, a
	ld hl, (_d)
	ld de, (_d + 2)
	or a
	jr z, __LABEL11
__LABEL10:
	call __SHL32
	djnz __LABEL10
__LABEL11:
	ld (_result), hl
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
#line 1 "/zxbasic/src/arch/zx48k/library-asm/shl32.asm"
__SHL32: ; Left Logical Shift 32 bits
		sla l
		rl h
		rl e
		rl d
	    ret
#line 117 "shl_shr_32bit.bas"
#line 1 "/zxbasic/src/arch/zx48k/library-asm/shra32.asm"
__SHRA32: ; Right Arithmetical Shift 32 bits
	    sra d
	    rr e
	    rr h
	    rr l
	    ret
#line 118 "shl_shr_32bit.bas"
#line 1 "/zxbasic/src/arch/zx48k/library-asm/shrl32.asm"
__SHRL32: ; Right Logical Shift 32 bits
	    srl d
	    rr e
	    rr h
	    rr l
	    ret
#line 119 "shl_shr_32bit.bas"
	END
