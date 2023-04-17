INCLUDE sprites.asm         ;; Sprites de los personajes en el juego

.MODEL small
.STACK
.RADIX 16

rightKey               equ    00
leftKey                equ    40
aboveKey               equ    80
belowKey               equ    0c0
stopAceman             equ    0ff
maxWall                equ    0ff
.DATA

testStr db 'testeando $'

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
; Variables para el juego
;---------------------------------------------------------
tableGame DB 03E8h dup(0)         ;; La pantalla es de 25*40

;---------------------------------------------------------
; Variables para los sprites de los personajes
;---------------------------------------------------------
mSpriteVars

sprite_aceman_actual   DB     00
movimiento_aceman      DB     rightKey
movimiento_aceman_x    DB     02
movimiento_aceman_y    DB     00
aceman_x               DW     0001
aceman_y               DW     0002
dir_sprite_aceman      DB     rightKey


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

INCLUDE utils.asm           ;; Funciones auxiliares que pueden ser usadas en cualquier parte del programa
INCLUDE keyboard.asm        ;; Funciones con el teclado
INCLUDE menu.asm            ;; Menu principal
INCLUDE game.asm            ;; Lógica del juego
INCLUDE files.asm           ;; Lógica para leer archivos

start:
    main PROC
        mov AX, @data
        mov DS, AX
        mStartProgram
    main ENDP
END start
