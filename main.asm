INCLUDE utils.asm           ;; Funciones auxiliares
INCLUDE sprites.asm         ;; Sprites de los personajes en el juego
INCLUDE keyboard.asm        ;; Funciones con el teclado
INCLUDE menu.asm            ;; Menu principal
INCLUDE game.asm            ;; Lógica del juego
INCLUDE files.asm           ;; Lógica para leer archivos

.MODEL small
.STACK
.RADIX 16
.DATA

mUtilsVars
mMenuVars
mFilesVars
mKeyboardVars
mSpriteVars


mStartProgram macro
    LOCAL start, exit
    start:
        mActiveVideoMode
        mStartGame
    exit:
        mActiveTextMode
        mExit
endm

.CODE
start:
    main PROC
        mov AX, @data
        mov DS, AX
        mStartProgram
    main ENDP
END start
