INCLUDE sprites.asm         ;; Sprites de los personajes en el juego

.MODEL small
.STACK
.RADIX 16

rightKey               equ    00
leftKey                equ    40
aboveKey               equ    80
belowKey               equ    0c0
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
fileName DB 'niv1.aml'
;---------------------------------------------------------
; Variable para convertir numeros
;---------------------------------------------------------
numberGotten DW 0
recoveredStr DB 9 DUP('$')
counterToGetIndexGotten DW 0

;---------------------------------------------------------
; Variables para el cronómetro
;---------------------------------------------------------
timeStr DB '00:00:000$'

initialTime     DW 65h                    ;; Como valor inicial guardamos 59s 99cs
currentTime     DW 00h

timePassed      DW 00
minuteTime      DB 00h
secondTime      DB 00h
hundredTime     DB 00h

;---------------------------------------------------------
; Variables para el juego
;---------------------------------------------------------
tableGame       DB 03E8h dup(0)               ;; La pantalla es de 25 * 40
totalPoints     DW 0h
aceDotPoints    DW 01h
totalDots       DW 06h

isGhostBlue DW 0FFh                     ;; 00 = no se puede comer | ff = se puede comer y pintar azul

;---------------------------------------------------------
; Variables para las palabras reservadas
;---------------------------------------------------------
NIVELKW                 DB 07h, '"nivel"'
VALORDOTKW              DB 0Ah, '"valordot"'
ACEMANINITLW            DB 0Ch, '"acemaninit"'
XKW                     DB 03h, '"x"'
YKW                     DB 03h, '"y"'
WALLSKW                 DB 07h, '"walls"'
POWERDOTSKW             DB 0Ch, '"power-dots"'
PORTALESKW              DB 0Ah, '"portales"'
NUMEROKW                DB 08h, '"numero"'
AKW                     DB 01h, '"a"'
BKW                     DB 01h, '"b"'


;---------------------------------------------------------
; Variables para los sprites de los personajes
;---------------------------------------------------------
mSpriteVars

;; Para Aceman
currentAcemanSprite         DB     00
currentAcemanDirection      DB     rightKey
currentAcemanPosition_x     DB     02
currentAcemanPosition_y     DB     00
aceman_x                    DW     0001
aceman_y                    DW     0002
dir_sprite_aceman           DB     rightKey

;; Para fantasmas
redGhost_y                  DW      09h      
redGhost_x                  DW      13h

orangeGhost_y               DW      0Bh
orangeGhost_x               DW      13h

magentaGhost_y              DW      09h
magentaGhost_x              DW      15h

cyanGhost_y                 DW      0Bh
cyanGhost_x                 DW      15h



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
INCLUDE menu.asm            ;; Menu principal
INCLUDE time.asm            ;; Lógica para el crónometro
INCLUDE game.asm            ;; Lógica del juego
INCLUDE files.asm           ;; Lógica para leer archivos

start:
    main PROC
        mov AX, @data
        mov DS, AX
        mStartProgram
    main ENDP
END start
