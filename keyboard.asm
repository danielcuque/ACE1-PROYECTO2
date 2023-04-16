;; Aquí se crearán las macros para manejar la información del teclado
mKeyboardVars macro
    keyBoardBuffer DB 102h dup (0ff, '$')
endm