; ------------------------------------------------------------
; Se espera a que el usuario presione la tecla ENTER, 
; de lo contrario vuelve a solicitar la tecla
; ------------------------------------------------------------
mWaitEnter macro
    LOCAL wait_enter
    push AX
    wait_enter:
        mov AH, 08h
        int 21
        cmp AL, 0Dh
        jne wait_enter
    pop AX
endm

; ------------------------------------------------------------
; Recibe como parámetro un string y lo imprime en pantalla
; ------------------------------------------------------------

mPrintMsg macro str
    push AX
    push DX

    mov DX, offset str
    mov AH, 09h
    int 21h

    pop DX
    pop AX
endm

mActiveVideoMode macro
    push AX
    mov AL, 13h
    mov AH, 00
    int 10h
    pop AX
endm

mActiveTextMode macro
    push AX
    mov AL, 03h
    mov AH, 00h
    int 10h
    pop AX
endm

; ------------------------------------------------------------
; Finaliza el programa con la interrupción 21 con 4Ch
; ------------------------------------------------------------
mExit macro
    mov AH, 4Ch ;4C en hexa servirá para cargar y generar la int del programa
    int 21h
endm

EmptyScreen PROC
    mPrintMsg infoMsg
    mWaitEnter
    ret
EmptyScreen ENDP

;---------------------------------------------------------
; PrintSprite
;
; Descripción:
; Muestra el sprite del pacman en la pantalla
;
; Receives:
; -
;
; Returns:
; AX -> Posición en X actual del aceman 
; CX -> Posición en Y actual del aceman 
;---------------------------------------------------------

PrintAceman PROC
pintar_aceman:	mov AX, [aceman_x]
		mov CX, [aceman_y]
		push AX
		push CX
		mov DL, [sprite_aceman_actual]
		cmp DL, 0ff
		je sprite_aceman1
		mov DI, offset acemanClose
		mov DH, 00
		mov DL, [dir_sprite_aceman]
		add DI, DX
		jmp cont_pintar_ace
sprite_aceman1:	mov DI, offset acemanClose
		mov DH, 00
		mov DL, [dir_sprite_aceman]
		add DI, DX
cont_pintar_ace:
		call PrintSprite
		pop CX
		pop AX
		call DelayProc
		mov DL, [sprite_aceman_actual]
		not DL
		mov [sprite_aceman_actual], DL
		push AX
		push CX
		; mov DI, offset sprite_vacio
		; call pintar_sprite
		pop CX
		pop AX
		ret
PrintAceman ENDP

PrintSprite PROC
    pintar_sprite:
		mov BX, 0000
		mov DL, 08
		mul DL
		add BX, AX
		xchg AX, CX
		mul DL
		xchg AX, CX
posicionamiento:cmp CX, 0000
		je fin_posicionamiento
		add BX, 140
		loop posicionamiento
fin_posicionamiento:
		mov CX, 0008
pintar_sprite_f:push CX
		mov CX, 0008
pintar_sprite_c:mov AL, [DI]
		push DS
		mov DX, 0A000
		mov DS, DX
		mov [BX], AL
		inc BX
		inc DI
		pop DS
		loop pintar_sprite_c
		pop CX
		sub BX, 08
		add BX, 140
		loop pintar_sprite_f
		ret
PrintSprite ENDP

DelayProc PROC
delay:
		mov BP, 03000
ciclob:		mov SI, 00010
cicloa:		dec SI
		cmp SI, 00
		jne cicloa
		dec BP
		cmp BP, 00
		jne ciclob
		ret
DelayProc ENDP