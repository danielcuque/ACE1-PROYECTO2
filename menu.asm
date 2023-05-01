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

        cmp DH, 00              ;; Si el procedure anterior devuelve 0, significa que están malas las credenciales
        je startMainMenu

        mCheckUserCredentials   ;; Redirigimos hacia el menu que le corresponda
    newUser:
        call UserForm
        mov DH, 00              ;; Estado
        mov DL, 01              ;; Credenciales
        call InsertNewUser
        jmp startMainMenu

    endMainMenu:
endm

mLoginMenu macro
    call UserForm           ;; Tomamos los campos del usuario
    call CheckCredentials   ;; Comprobamos sus crendenciales
endm

mCheckUserCredentials macro
    mov BX, userLoggedAdress
    add BX, 06h                 ;; Nos posicionamos en el campo de credenciales del jugador para ver que permisos tiene
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
        je personalTimeReport 

        cmp AL, 32                      ;; 33 = 3
        je personalScoreReport 

        cmp AL, 34                      ;; 34 = 4     
        je menuProgram

        jmp start

        personalTimeReport:
            mReportMenu
            call GeneratePersonalTimeReport
            jmp start
        personalScoreReport:
            mReportMenu
            call GeneratePersonalScoreReport
            jmp start

endm

mAdminUserMenu macro
    LOCAL start,personalTimeReport, personalScoreReport, globalTimeReport, globalScoreReport
    start:  
        mPrintMsg newLineChar

        mPrintMsg INICIARJUEGO

        mPrintNumberByDigits 6, 02H
        mPrintMsg TOP10TIEMPOSPERSONALES

        mPrintNumberByDigits 6, 03H
        mPrintMsg TOP10PUNTEOPERSONAL

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

        cmp AL, 32h
        je personalTimeReport               ;; 2

        cmp AL, 33h                      ;; 3
        je personalScoreReport

        cmp AL, 34h                      ;; 4
        je globalTimeReport

        cmp AL, 35h                      ;; 5
        je globalScoreReport

        cmp AL, 36h                     ;; 32 = 6     
        je menuProgram
        
        jmp start

        personalTimeReport:
            mReportMenu
            call GeneratePersonalTimeReport
            jmp start
        personalScoreReport:
            mReportMenu
            call GeneratePersonalScoreReport
            jmp start
        globalTimeReport:
            mReportMenu
            call GenerateGlobalScoreReport
            jmp start
        globalScoreReport:
            mReportMenu
            call GenerateGlobalTimeReport
            jmp start
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

        cmp AL, 32h
        je toInactiveUsers               ;; 2

        cmp AL, 33h                      ;; 3
        je toActiveUsers

        cmp AL, 34h                      ;; 4
        je globalTimeReport

        cmp AL, 35h                      ;; 5
        je globalScoreReport

        cmp AL, 36                       ;; 32 = 6     
        je menuProgram
        jmp start

        toInactiveUsers:
            jmp start
        toActiveUsers:
            call ApproveNewUsers
            jmp start
        globalTimeReport:
            mReportMenu
            call GenerateGlobalTimeReport
            jmp start
        globalScoreReport:
            mReportMenu
            call GenerateGlobalScoreReport
            jmp start
        endMainAdminMenu:
            jmp start
endm

;---------------------------------------------------------
; mReportMenu
;
; Descripción:
; Establece los valores para realizar los ordenamientos
;
; Recibe:
;
; Retorna:
; metricaValue, sortTypeValue, directionValue
;---------------------------------------------------------

mReportMenu macro
    LOCAL metricaLoop, directionLoop, typeLoop, setMetric, setDirection, setType
        metricaLoop:
            mPrintMsg newLineChar
            mPrintMsg metricaMsg
            xor AX, AX
            mov AH, 08h                     ;; Cargamos la interrupción para leer 1 caracter
            int 21

            cmp AL, 30
            jb metricaLoop

            cmp AL, 33                      ;; Menor a 3      
            jb setMetric

        setMetric:
            sub AL, 30h                     ;; Restamos 30h para obtener el valor numerico del teclado
            mov metricaValue, AL
        
        typeLoop:
            mPrintMsg newLineChar
            mPrintMsg sortTypeMsg
            xor AX, AX
            mov AH, 08h                     ;; Cargamos la interrupción para leer 1 caracter
            int 21

            cmp AL, 30
            jb typeLoop

            cmp AL, 34h                      ;; menor a 4
            jb setType
            jmp typeLoop

        setType:
            sub AL, 30h                     
            mov sortTypeValue, AL
        
        directionLoop:
            mPrintMsg newLineChar
            mPrintMsg directionMsg

            xor AX, AX
            mov AH, 08h                     ;; Cargamos la interrupción para leer 1 caracter
            int 21

            cmp AL, 30
            jb directionLoop

            cmp AL, 33                      ;; Menor a 3
            jb setDirection
            
            jmp directionLoop
        setDirection:
            sub AL, 30h
            mov directionValue, AL
endm