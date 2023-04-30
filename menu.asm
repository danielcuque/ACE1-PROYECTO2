;; Metodos para manejar los menús
NewUserForm PROC
    mGetInputKeyboard nameBuffer, USERNAMEMSG
    mPrintMsg newLineChar
    mGetInputKeyboard passwordBuffer, PASSWORDMSG
    ret
NewUserForm ENDP

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
        call NewUserForm
        mov DH, 00
        mov DL, 00
        call InsertNewUser
        jmp startMainMenu

    endMainMenu:
endm

;Iniciar Juego
;Inactivar usuario Aprobar usuario
;Top 10 tiempos globales Top 10 punteo globales Salir

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
        call NewUserForm
        call CheckCredentials
        jmp exit
        jmp start
    end:
endm