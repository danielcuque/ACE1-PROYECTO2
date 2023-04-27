;; Metodos para manejar los menús
mMainMenu macro
    LOCAL start
    start:
        mPrintMsg newLineChar
        mPrintMsg INICIARSESION         ;; Mostramos los mensajes
        mPrintNumberByDigits 6, 02h
        mPrintMsg SALIR
        
        mov AH, 08h                     ;; Cargamos la interrupción para leer 1 caracter
        int 21

        cmp AL, 31                      ;; 31 = 1
        je displayLoginMenu 

        cmp AL, 32                      ;; 32 = 2     
        je exit
        jmp start 
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