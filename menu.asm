;; Metodos para manejar los menús
;---------------------------------------------------------
; UserForm
;
; Descripción:
; Genera la interrupción para poder cargar la información del usuario
;
; Recibe:
; Descripción de los registros de entrada
;
; Retorna:
; Descripción de los registros de salida
;---------------------------------------------------------

UserForm PROC
    mGetInputKeyboard nameBuffer, USERNAMEMSG
    mPrintMsg newLineChar
    mGetInputKeyboard passwordBuffer, PASSWORDMSG
    ret
UserForm ENDP

mMainMenu macro
    LOCAL start, newUser, endMainMenu

    startMainMenu:
        mov AX, 00
        mPrintMsg newLineChar

        mPrintMsg INICIARSESION         ;; Mostramos los mensajes

        mPrintNumberByDigits 6, 02h
        mPrintMsg SALIR

        mPrintMsg NEWUSERMSG
        
        mov AH, 10h					     ;; Generamos la interrupción para obtener entradas del teclado
	    int 16h

        cmp AL, 31h                      ;; 31 = 1
        je loginUser 

        cmp AL, 32h                      ;; 32 = 2     
        je exit

        cmp AH, 3Fh                      ;; Tecla F5
        je newUser

        jmp startMainMenu
    
    loginUser:
        mLoginMenu
        jmp endMainMenu
        
    newUser:
        call UserForm
        mov DH, 00
        mov DL, 00
        call InsertNewUser
        jmp startMainMenu

    endMainMenu:
endm

mMainAdminMenu macro
    LOCAL start
    start:  
        mPrintMsg newLineChar

        mPrintMsg INICIARJUEGO

        mPrintMsg INACTIVARUSUARIO

        mPrintMsg APROBARUSUARIO

        mPrintNumberByDigits 6, 04H
        mPrintMsg TOP10TIEMPOSGLOBALES

        mPrintNumberByDigits 6, 05H
        mPrintMsg TOP10PUNTEOGLOBAL

        mPrintNumberByDigits 6, 06H
        mPrintMsg SALIR
        
        mov AH, 08h                     ;; Cargamos la interrupción para leer 1 caracter
        int 21

        cmp AL, 31                      ;; 31 = 1
        je startProgram 

        cmp AL, 36                      ;; 32 = 6     
        je exit

        jmp start
endm

mLoginMenu macro
    LOCAL start, end
    start:
        call UserForm           ;; Tomamos los campos del usuario
        call CheckCredentials   ;; Comprobamos sus crendenciales
        
        cmp DH, 00              ;; Si el procedure anterior devuelve 0, significa que están malas las credenciales
        je start

        mCheckUserCredentials   ;; Redirigimos hacia el menu que le corresponda
        jmp exit
    end:
endm

mCheckUserCredentials macro
    mov BX, userLoggedAdress
    add BX, 07h                 ;; Nos posicionamos en el campo de credenciales del jugador para ver que permisos tiene
    xor AX, AX
    mov AL, [BX]

    cmp AL, 01
    je normalUserMenu

    cmp AL, 02
    je adminUserMenu
    jmp globalAdminMenu
endm

mNormalUserMenu macro
    LOCAL start, top10PersonalTimeReport, top10PersonalScoreReport
    start:  
        mPrintMsg newLineChar

        mPrintMsg INICIARJUEGO

        mPrintNumberByDigits 6, 02h
        mPrintMsg TOP10TIEMPOSPERSONALES


        mPrintNumberByDigits 6, 03h
        mPrintMsg TOP10PUNTEOPERSONAL


        mPrintNumberByDigits 6, 04h
        mPrintMsg SALIR
        
        mov AH, 08h                     ;; Cargamos la interrupción para leer 1 caracter
        int 21

        cmp AL, 31                      ;; 31 = 1
        je startProgram 

        cmp AL, 32                      ;; 32 = 2
        je top10PersonalTimeReport 

        cmp AL, 32                      ;; 33 = 3
        je top10PersonalScoreReport 

        cmp AL, 34                      ;; 34 = 4     
        je exit

        jmp start

        top10PersonalTimeReport:
            call GeneratePersonalScoreReport
            jmp start
        top10PersonalScoreReport:
            jmp start

endm

mAdminUserMenu macro
    LOCAL start
    start:  
        mPrintMsg newLineChar

        mPrintMsg INICIARJUEGO

        mPrintMsg INACTIVARUSUARIO

        mPrintMsg APROBARUSUARIO

        mPrintNumberByDigits 6, 04H
        mPrintMsg TOP10TIEMPOSGLOBALES

        mPrintNumberByDigits 6, 05H
        mPrintMsg TOP10PUNTEOGLOBAL

        mPrintNumberByDigits 6, 06H
        mPrintMsg SALIR
        
        mov AH, 08h                     ;; Cargamos la interrupción para leer 1 caracter
        int 21

        cmp AL, 31                      ;; 31 = 1
        je startProgram 

        cmp AL, 36                      ;; 32 = 6     
        je exit

        jmp start
endm