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
    mov BX, offset nextPointer
    cmp BX, 00                            ;; Comparamos si el puntero es nulo
    jne insertNextUser                    ;; Si no lo es, entonces insertamos el usuario siguiente

    mov BX, offset dataSegment            ;; Si el puntero es nulo, entonces se obtiene la direccion de memoria del inicio del segmento de datos para los usuarios/juegos

    insertNextUser:
        mov SI, BX                        ;; Colocamos la dirección del puntero en SI
        mov [SI], BX                      ;; Guardamos la direccion del puntero en la direccion de memoria del puntero

        mov DI, prevPointer               ;; Verificamos el puntero anterior

        cmp DI, 00h
        je noPrevPointer                  ;; Si el puntero es nulo, entonces movemos el puntero

        add DI, 02h                       ;; De lo contrario, aumentamos en 2 el punterio anterior para obtener
        mov word ptr [DI], BX

        noPrevPointer:
            mov prevPointer, SI           ;; Si no hay algun usuario anterior, entonces

            add SI, 02h
            mov word ptr [SI], 00h

            add SI, 02h
            mov word ptr [SI], 00h

            add SI, 2h
            mov [SI], DL

            inc SI
            mov [SI], DH

            inc SI
            lea DI, nameBuffer

            xor CX, CX
            mov CL, [DI+1]
            mov [SI], CL

            inc SI

            add DI, 02h

        saveUsername:
            mov AL, [DI]
            mov [SI], AL
            inc DI
            inc SI
            loop saveUsername

        add SI, CX
        lea DI, passwordBuffer

        xor CX, CX
        mov CL, [DI+1]
        mov [SI], CL

        inc SI

        add DI, 02h

        savePassword:
            mov AL, [DI]
            mov [SI], AL
            inc DI
            inc SI
            loop savePassword

        add SI, CX

        mov nextPointer, SI
        call GenerateMemoryGraph
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
    mEmptyBuffer nameBuffer             ;; Vaciamos el buffer de inicio

    mov SI, 0           
    mov nameBuffer[SI], 0ffh            ;; En la primera posición del buffer, colocamos el tamaño del buffer

    inc SI                              
    mov CX, 00h
    mov CX, sizeof nameMainAdmin        ;; Movemos los bits leídos a la segunda posición del buffer
    mov nameBuffer[SI], CL
    inc SI                              ;; Nos movemos al primer caracter

    mov DI, offset nameMainAdmin

    setMainAdminName:
        mov AL, [DI]                    ;; Movemos el ascii a AL

        mov nameBuffer[SI], AL

        inc SI
        inc DI
        loop setMainAdminName

    ;; Repetimos los mismo pasos para el password del admin

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
