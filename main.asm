
INCLUDE sprites.asm         ;; Sprites de los personajes en el juego
INCLUDE keyboard.asm        ;; Funciones con el teclado
INCLUDE menu.asm            ;; Menu principal
INCLUDE game.asm            ;; Lógica del juego
INCLUDE files.asm           ;; Lógica para leer archivos

.MODEL small
.STACK
.RADIX 16
derecha                equ    00
izquierda              equ    40
arriba                 equ    80
abajo                  equ    0c0
no_movimiento          equ    0ff
pared_maxima           equ    0ff
.DATA

; ------------------------------------------------------------
; Variables de propósito general, 
; o que no van a ser de utilidad en otra parte del codigo
; ------------------------------------------------------------
infoMsg DB 'Universidad de San Carlos de Guatemala', 0Dh, 0Ah,'Facultad de Ingenieria', 0Dh, 0Ah,'Escuela de Ciencias y Sistemas', 0Dh, 0Ah,'Arquitectura de computadores y ensambladores 1', 0Dh, 0Ah,'Seccion B', 0Dh, 0Ah,'Daniel Estuardo Cuque Ruiz' , 0Dh, 0Ah,'202112145', 0Dh, 0Ah, '$'

; ---------------------------------------------------------
; Variables para el menu principal
;---------------------------------------------------------
menuMsg DB '1. Iniciar sesi', 0A2h, 'n $'

;---------------------------------------------------------
; Variables para los archivos
;---------------------------------------------------------
fileLineBuffer DB 102h dup('$') 
handleObject DW 0       

;---------------------------------------------------------
; Variable para las funciones del teclado
;---------------------------------------------------------

keyBoardBuffer DB 102h dup (0ff, '$')
;---------------------------------------------------------
; Variables para los sprites de los personajes
;---------------------------------------------------------
mSpriteVars

sprite_aceman_actual   db     00
movimiento_aceman      db     derecha
movimiento_aceman_x    db     02
movimiento_aceman_y    db     00
aceman_x               dw     0001
aceman_y               dw     0002
dir_sprite_aceman      db     derecha


mStartProgram macro
    LOCAL start, exit
    start:
        mActiveVideoMode
        call PrintAceman
        mStartGame
    exit:
        mActiveTextMode
        mExit
endm

.CODE
INCLUDE utils.asm
start:
    main PROC
        mov AX, @data
        mov DS, AX
        mStartProgram
    main ENDP
END start
