;; Procedimientos y macros para poder manejar las entradas del teclado
;---------------------------------------------------------
; mEmptyBuffer
;
; Descripción:
; Vacía el contenido del buffer, respetando el tamaño del mismo
;
; Recibe:
; -
;
; Retorna:
; -
;---------------------------------------------------------

mEmptyBuffer macro buffer
    LOCAL emptyBuffer
    push SI
    push CX
    push AX

    mov SI, offset buffer
    mov CL, [SI]
    mov CH, 00
    add SI, 02

    mov AL, 24h

    emptyBuffer:
        mov [SI], AL
        inc SI
        loop emptyBuffer

    pop DX
    pop CX
    pop SI
endm

mGetInputKeyboard macro keyBoardBuffer, message
    push DX
    push AX
    push CX

    mEmptyBuffer keyBoardBuffer

    mPrintMsg message

    mov DX, offset keyBoardBuffer
    mov AH, 0Ah
    int 21h
    pop CX
    pop AX
    pop DX
endm
