;---------------------------------------------------------
; ReadFile
;
; Descripción:
; Lee el archivo de entrada a partir de un filename
;
; Recibe:
; DX -> filename
;
; Retorna:
; Tablero de juego lleno
;---------------------------------------------------------

ReadFile PROC USES AX BX CX
    xor CX, CX
    mov AL, 00                          ;; Modo de lectura
    mov AH, 3dh                         ;; Función para abrir el archivo
    int 21h                             ;; Provocamos la interrupción
    jc errorToOpen

    mov handleObject, AX
    jmp closeFile

    errorToOpen:
        mPrintMsg errorOpenFile
        mWaitEnter
        jmp endRead
    errorToClose:
        mPrintMsg errorCloseFile
        mWaitEnter
        jmp endRead
    closeFile:
        mov BX, handleObject
        mov AH, 03Eh                    ;; Cargamos a AH para hacer la interrupción de cerrar archivo
        int 21h                         ;; Cerramos el archivo
        jc errorToClose                 ;; Mandamos el error si el carry flag se activa
    endRead:
    ret
ReadFile ENDP