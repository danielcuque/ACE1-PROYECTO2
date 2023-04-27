;; Metodos para manejar los menús
mMainMenu macro
    LOCAL start
    start:
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