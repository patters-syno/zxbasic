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
ZXBASIC_USER_DATA_END:
__MAIN_PROGRAM__:
	ld hl, (_a)
	ld de, (_a)
	call __DIVU16
	push hl
	ld hl, (_a)
	srl h
	rr l
	ld de, (_a)
	call __DIVU16
	ex de, hl
	pop hl
	call __DIVU16
	ld (_a), hl
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
#line 1 "/zxbasic/src/arch/zx48k/library-asm/div16.asm"
	; 16 bit division and modulo functions
	; for both signed and unsigned values
#line 1 "/zxbasic/src/arch/zx48k/library-asm/neg16.asm"
	; Negates HL value (16 bit)
__ABS16:
		bit 7, h
		ret z
__NEGHL:
		ld a, l			; HL = -HL
		cpl
		ld l, a
		ld a, h
		cpl
		ld h, a
		inc hl
		ret
#line 5 "/zxbasic/src/arch/zx48k/library-asm/div16.asm"
__DIVU16:    ; 16 bit unsigned division
	             ; HL = Dividend, Stack Top = Divisor
		;   -- OBSOLETE ; Now uses FASTCALL convention
		;   ex de, hl
	    ;	pop hl      ; Return address
	    ;	ex (sp), hl ; CALLEE Convention
__DIVU16_FAST:
	    ld a, h
	    ld c, l
	    ld hl, 0
	    ld b, 16
__DIV16LOOP:
	    sll c
	    rla
	    adc hl,hl
	    sbc hl,de
	    jr  nc, __DIV16NOADD
	    add hl,de
	    dec c
__DIV16NOADD:
	    djnz __DIV16LOOP
	    ex de, hl
	    ld h, a
	    ld l, c
	    ret     ; HL = quotient, DE = Mudulus
__MODU16:    ; 16 bit modulus
	             ; HL = Dividend, Stack Top = Divisor
	    ;ex de, hl
	    ;pop hl
	    ;ex (sp), hl ; CALLEE Convention
	    call __DIVU16_FAST
	    ex de, hl	; hl = reminder (modulus)
					; de = quotient
	    ret
__DIVI16:	; 16 bit signed division
		;	--- The following is OBSOLETE ---
		;	ex de, hl
		;	pop hl
		;	ex (sp), hl 	; CALLEE Convention
__DIVI16_FAST:
		ld a, d
		xor h
		ex af, af'		; BIT 7 of a contains result
		bit 7, d		; DE is negative?
		jr z, __DIVI16A
		ld a, e			; DE = -DE
		cpl
		ld e, a
		ld a, d
		cpl
		ld d, a
		inc de
__DIVI16A:
		bit 7, h		; HL is negative?
		call nz, __NEGHL
__DIVI16B:
		call __DIVU16_FAST
		ex af, af'
		or a
		ret p	; return if positive
	    jp __NEGHL
__MODI16:    ; 16 bit modulus
	             ; HL = Dividend, Stack Top = Divisor
	    ;ex de, hl
	    ;pop hl
	    ;ex (sp), hl ; CALLEE Convention
	    call __DIVI16_FAST
	    ex de, hl	; hl = reminder (modulus)
					; de = quotient
	    ret
#line 30 "divu16b.bas"
	END
