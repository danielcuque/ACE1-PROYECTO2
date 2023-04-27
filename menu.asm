;; Metodos para manejar los menús
mMainMenu macro
    LOCAL start
    start:
        mPrintMsg INICIARSESION         ;; Mostramos los mensajes
        mPrintNumberByDigits 6, 02h
        mPrintMsg SALIR
        
        mov AH, 08h ; Cargamos a AH el código de interrupción para leer un caracter
        int 21 ; Llamamos a la interrupción
        cmp AL, 31 ; Comparamos el caracter leído con el código ASCII de 1
        je start_game ; Si se presiona 1 entonces se llama a la función option_1
        cmp AL, 32 ; Comparamos el caracter leído con el código ASCII de 2
        je upload_game ; Si se presiona 2 entonces se llama a la función option_2
        cmp AL, 33 ; Comparamos el caracter leído con el código ASCII de 3
        je exit ; Si se presiona 3 entonces se llama a la función option_3
        jmp mainMenu 

endm