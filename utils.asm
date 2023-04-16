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