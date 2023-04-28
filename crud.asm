;; En este archivo se manejará todo el crud con los usuarios
ApproveNewUsers PROC
    
    ret
ApproveNewUsers ENDP

;---------------------------------------------------------
; InsertNewUser
;
; Descripción:
; Inserta un nuevo usuario en el bloque de datos
;
; Recibe:
; DH -> Tipo de usuario
; DL -> 01 = activo | 00 = no activo
; nameBuffer ->  nombre del usuario
; passwordBuffer ->  contraseña del usuario
;
; Retorna:
; -
;---------------------------------------------------------

InsertNewUser PROC
    ; mPrintMsg nameBuffer
    ; mWaitEnter

    cmp nextPointer, 00             ;; Comparamos si el puntero es nulo
    je firstUser                    ;; Si lo es, entonces insertamos el primer usuario


    firstUser:
        mov BX, offset nextPointer
        mov numberGotten, BX
        mPrintNumberConverted
        mWaitEnter
    ret
InsertNewUser ENDP

;---------------------------------------------------------
; InsertMainAdmin
;
; Descripción:
; Inserta el administrador global del programa
;
; Recibe:
; -
;
; Retorna:
; -
;---------------------------------------------------------

InsertMainAdmin PROC
    mEmptyBuffer nameBuffer
    mov SI, 0
    mov nameBuffer[SI], 0ffh
    inc SI
    mov CX, 00h
    mov CX, sizeof nameMainAdmin
    mov nameBuffer[SI], CL
    inc SI

    mov DI, offset nameMainAdmin

    setMainAdminName:
        mov AL, [DI]
        mov nameBuffer[SI], AL
        inc SI
        inc DI
        loop setMainAdminName
    
    lea SI, nameBuffer
    add SI, 02h
    mPrintPartialDirection SI
    mWaitEnter

    mEmptyBuffer passwordBuffer
    mov SI, 00h
    mov passwordBuffer[SI], 0FFh

    inc SI
    mov CX, 00h
    mov CX, sizeof passwordMainAdmin
    mov passwordBuffer[SI], CL
    inc SI

    lea DI, passwordMainAdmin

    setMainAdminPassword:
        mov AL, [DI]
        mov passwordBuffer[SI], AL
        inc SI
        inc DI
        loop setMainAdminPassword

    mov DL, 01
    mov DH, 01

    call InsertNewUser
    ret
InsertMainAdmin ENDP
