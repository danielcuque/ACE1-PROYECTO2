INCLUDE utils.asm           ;; Funciones auxiliares
INCLUDE sprites.asm         ;; Sprites de los personajes en el juego
INCLUDE keyboard.asm        ;; Funciones con el teclado
INCLUDE menu.asm            ;; Menu principal
INCLUDE game.asm            ;; Lógica del juego

.MODEL small
.STACK
.RADIX 16
.DATA

mUtilsVars
mMenuVars
mCharVars


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
        mov ax, @data
        mov ds, ax
        mStartProgram
    main ENDP
END start
