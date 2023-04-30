;; En este archivo se manejará todo el crud con los usuarios
;---------------------------------------------------------
; ApproveNewUsers
;
; Descripción:
; Muestra la lista de usuarios que tienen que ser aprobados
;
; Recibe:
; -
;
; Retorna:
; -
;---------------------------------------------------------

ApproveNewUsers PROC
    
    ret
ApproveNewUsers ENDP

;---------------------------------------------------------
; CheckCredentials
;
; Descripción:
; Sirve para verificar los datos para realizar el login 
;
; Recibe:
; nameBuffer, passwordBuffer -> información para loguearse
;
; Retorna:
; DH ->  00, contraseña o usuario incorrecto
; DH ->  01, login correcto
;---------------------------------------------------------
CheckCredentials PROC USES SI DI AX BX CX
    mov SI, offset dataSegment      ;; Nos posicionamos al inicio del todo
    mov BX, [SI]                    ;; Colocamos el valor que está en la dirección AX en BX

    verifyUser:
        mov userLoggedAdress, BX        ;; Se guarda la dirección del usuario, por si en dado caso se logra loguear

        cmp BX, 00
        je endOfList

        add BX, 02h                     ;; Obtenemos la dirección de memoria de donde está el next user, pero debemos hacer [BX] para obtener el valor, es decir, solo guardamos el índice
        xor CX, CX
        mov CX, [BX]                    ;; Guardamos la dirección en CX

        add BX, 06h                     ;; Nos posicionamos en el tamaño del username a analizar

        mov DI, BX
        mov SI, offset nameBuffer
        add SI, 02h

        xor DX, DX
        call CompareStr
        
        cmp DL, 00
        je skipUser
    
        xor AX, AX
        mov AL, [DI]
        inc AX
        add BX, AX

        mov DI, BX
        mov SI, offset passwordBuffer
        add SI, 02h


        xor DX, DX
        call CompareStr

        cmp DL, 00
        jne successfulLogin
        
        skipUser:
            mov BX, CX
            jmp verifyUser
    
    successfulLogin:
        mov DH, 01
        mPrintMsg newLineChar
        mPrintMsg successfulLoginMsg
        mWaitEnter
        jmp endProc

    endOfList:
        mPrintMsg newLineChar
        mPrintMsg errorLoginUser
        mWaitEnter
        mov DH, 00        

    endProc:
        ret
CheckCredentials ENDP

;---------------------------------------------------------
; InsertNewGame
;
; Descripción:
; Toma la dirección del usuario logueado, y en base a eso, se inserta el juego
;
; Recibe:
; userLoggedAdress -> Dirección en memoria del jugador logueado
;
; Retorna:
; -
;---------------------------------------------------------

InsertNewGame PROC
    lea DI, userLoggedAdress
    ret
InsertNewGame ENDP


;---------------------------------------------------------
; InsertNewUser
;
; Descripción:
; Inserta un nuevo usuario en el bloque de datos
;
; Recibe:
; DH -> Tipo de usuario, 01 = normal | 02 = admin | 03 = admin global
; DL -> 01 = activo | 00 = no activo
; nameBuffer ->  nombre del usuario
; passwordBuffer ->  contraseña del usuario
;
; Retorna:
; -
;---------------------------------------------------------

InsertNewUser PROC
    mov BX, nextPointer
    cmp BX, 00                            ;; Comparamos si el puntero es nulo
    jne insertNextUser                    ;; Si no lo es, entonces insertamos el usuario siguiente
                                          ;; Ya que significa que existe un usuario antes

    lea BX, dataSegment            ;; Si el puntero es nulo, entonces se obtiene la direccion de memoria del inicio del segmento de datos para los usuarios/juegos

    insertNextUser:
        mov SI, BX                        ;; Colocamos la dirección del puntero en SI
        mov [SI], BX                      ;; Guardamos la direccion del puntero en la direccion de memoria del puntero

        mov DI, prevPointer               ;; Verificamos el puntero anterior

        cmp DI, 00h
        je noPrevPointer                  ;; Si el puntero anterior es 0, singifica que no hay usuarios anteriormente

        add DI, 02h                       ;; De lo contrario, aumentamos en 2 para salvar la direccion de referencia hacia el proximo usuario del usuario anterior
        mov word ptr [DI], BX

        ;; Por ejemplo, si es el segundo usuario que insertamos, ya existirá un usuario 1, que su direccion está en prevPointer
        ;; Para poder enlazar el usuario1 -> usuario2, sabemos que el campo no.2 del usuario1, guardará la referencia de la direccion de memoria hacia el siguiente usuario

        noPrevPointer:
            mov prevPointer, SI           ;; Guardamos la direccion de memoria del usuario que se está insertando, para que cuando se inserte el proximo usuario, sepa que debe hacer referencia a este usuario

            add SI, 02h                   ;; Aumentamos el tamaño en 2, para poder guardar el campo de nextUser
            mov word ptr [SI], 00h        ;; Inicialmente lo guardamos con 0, luego en la proxima inserción, se cambia en la comparación anterior

            add SI, 02h                  ;; Guardamos en un inicio el primer juego del jugador como 00
            mov word ptr [SI], 00h

            add SI, 02h                  ;; Luego guardamos que tipo de permisos tiene 01|02|03  
            mov [SI], DL

            add SI, 01h
            mov [SI], DH                  ;; El siguiente campo es isUserActive, guarda si el usuario ya fue aprobado

            add SI, 01h                   ;; A partir de aquí, tomamos el valor del buffer para el username
            lea DI, nameBuffer

            xor CX, CX
            mov CL, [DI+1]                ;; En la posición del buffer para el nombre está ->  nameBuffer = [cantidadDisponible, caracteresLeidos, ...contenido]
            mov [SI], CL                  ;; Guardamos el tamaño del nombre en la posición siguiente a la de isUserActive

            add SI, 01h                        ;; Nos movemos una vez más

            add DI, 02h                   ;; Nos posicionamos en nameBuffer = [...contenido]

        saveUsername:
            mov AL, [DI]                  ;; Movemos los caracteres del buffer a nuestro dataSegment
            mov [SI], AL
            inc DI
            inc SI
            loop saveUsername

        lea DI, passwordBuffer

        xor CX, CX                          ;; Repetimos el mismo algoritmo para la contraseña
        mov CL, [DI+1]                      ;; Caracteres leidos
        mov [SI], CL

        add SI, 01h

        add DI, 02h

        savePassword:
            mov AL, [DI]
            mov [SI], AL
            inc DI
            inc SI
            loop savePassword

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
