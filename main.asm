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
infoMsg             DB 'Universidad de San Carlos de Guatemala', 0Dh, 0Ah,'Facultad de Ingenieria', 0Dh, 0Ah,'Escuela de Ciencias y Sistemas', 0Dh, 0Ah,'Arquitectura de computadores y ensambladores 1', 0Dh, 0Ah,'Seccion B', 0Dh, 0Ah,'Daniel Estuardo Cuque Ruiz' , 0Dh, 0Ah,'202112145', 0Dh, 0Ah, '$'
developerName       DB 'Daniel Cuque | 202112145$'
colonChar           DB ':$'
newLineChar         DB 0Ah, '$'
errorOpenFile       DB 'Error al abrir el archivo$'
errorReadLine       DB 'Error al leer la linea en $'
errorCloseFile      DB 'Error al cerrar el archivo$'
errorSizeOfNumber   DB 'Numero demasiado grande$'
auxiliarX           DW 00h
auxiliarY           DW 00h

; ---------------------------------------------------------
; Variables para números aleatorioss
;---------------------------------------------------------
randomNumber DB 00h
randomSeed DW 00h
Randoms1 DB 0Ah, 9Fh, 0F0h, 1Bh, 69h, 3Dh, 0e8h, 52h, 0c6h, 41h, 0b7h, 74h, 23h, 0ach, 8eh, 0d5h
Randoms2 DB 9CH, 0EEH, 0B5H, 0CAH, 0AFH, 0F0H, 0DBH, 69H, 3DH, 58H, 22H, 06H, 41H, 17H, 74H, 83H

;---------------------------------------------------------
; Variables para los archivos
;---------------------------------------------------------
fileLineBuffer DB 32 dup('$') 
handleObject DW 0       
fileName1 DB 'niv1.aml', 0                  
fileName2 DB 'niv2.aml', 0                      ;; Es necesario colocar 0 al final
fileName3 DB 'niv3.aml', 0

;---------------------------------------------------------
; Variable para convertir numeros
;---------------------------------------------------------
numberGotten DW 0
recoveredStr DB 9 DUP('$')
counterToGetIndexGotten DW 0

;---------------------------------------------------------
; Variables para los reportes
;---------------------------------------------------------
simpleSeparatorText       DB 15h dup('-')
doubleSeparatorText       DB 15h dup('=')
TIPOKW                    DB 'Tipo:'
SENTIDOKW                 DB 'Sentido:'
FECHAKW                   DB 'Fecha:'
HORAKW                    DB 'Hora:'
RANKKW                    DB 'Rank'
PLAYERKW                  DB 'Player'
NKW                       DB 'N'

;---------------------------------------------------------
; Variables para los menus
;---------------------------------------------------------
INICIARJUEGO                    DB '1. Iniciar juego', 0Dh, 0Ah,'$'
TOP10TIEMPOSPERSONALES    DB '. Top 10 tiempos personales', 0Dh, 0Ah,'$'
TOP10PUNTEOPERSONAL       DB '. Top 10 punteo personal', 0Dh, 0Ah,'$'
SALIR                     DB '. Salir', 0Dh, 0Ah,'$'
TOP10TIEMPOSGLOBALES      DB '. Top 10 tiempos globales', 0Dh, 0Ah,'$'
TOP10PUNTEOGLOBAL         DB '. Top 10 punteos globales', 0Dh, 0Ah,'$'
APROBARUSUARIO            DB '3. Aprobar usuario', 0Dh, 0Ah,'$'
INACTIVARUSUARIO          DB '2. Inactivar usuario', 0Dh, 0Ah,'$'
INICIARSESION             DB '1. Iniciar sesi',0A2h,'n',0Dh, 0Ah,'$'


;---------------------------------------------------------
; Variables para el cronómetro
;---------------------------------------------------------
initialTime     DW 00                           ;; Se guarda la los minutos:segundos:cs de cuando se inicia el juego en cs (centésimas de segundo)
currentTime     DW 00h                          ;; Se va actualizando el tiempo

initialMinutes  DB 00h
initialSeconds  DB 00h
initialHundred  DB 00h

timePassed      DW 00
minuteTime      DW 00h
secondTime      DW 00h
hundredTime     DW 00h

;---------------------------------------------------------
; Variables para el cronometro
;---------------------------------------------------------
previousSecond DB 00h                   ;; Guarda el segundo anterior
temporizerTime DB 00h                   ;; Guardar 12 en decimal

;---------------------------------------------------------
; Variables para el juego
;---------------------------------------------------------
tableGame           DB 03E8h dup(0)                 ;; La pantalla es de 25 * 40
totalPoints         DW 0h                           ;; El marcador total para cuando coma ace/power dots
aceDotPoints        DW 01h                          ;; Valor del aceDot
ghostPoints         DW 64h                          ;; El valor inicial de los fantasmas
totalDots           DW 00h                          ;; Cantidad de ace/power dots en el mapa
numberLevel         DB 00h                          ;; Guardamos el nivel actual del juego
healthAceman        DB 03h
isGhostBlue         DW 00h                          ;; 00 = no se puede comer | FF = se puede comer y pintar azul
lastPortalInserted  DB 15h                          ;; 20 decimal
currentPlayerName   DB 'Daniel$'                    ;; Nombre del jugador
isBackMenu          DB 00                           ;; 00 = continuar | FF = volver al menú principal

;---------------------------------------------------------
; Variables para las palabras reservadas
;---------------------------------------------------------
NIVELKW                 DB 07h, '"nivel"'
VALORDOTKW              DB 0Ah, '"valordot"'
ACEMANINITLW            DB 0Eh, '"acemaninit":{'
XKW                     DB 03h, '"x"'
YKW                     DB 03h, '"y"'
WALLSKW                 DB 07h, '"walls"'
POWERDOTSKW             DB 0Ch, '"power-dots"'
PORTALESKW              DB 0Ah, '"portales"'
NUMEROKW                DB 08h, '"numero"'
AKW                     DB 01h, '"a"'
BKW                     DB 01h, '"b"'
JUGADORKW               DB 'JUGADOR: $'

;---------------------------------------------------------
; Variables para los sprites de los personajes
;---------------------------------------------------------
mSpriteVars

;; Para muros
currentWallType             DB     00

;; Para Aceman
currentAcemanSprite         DB     00
currentAcemanDirection      DB     rightKey

aceman_x                    DW     001h
aceman_y                    DW     002h
dir_sprite_aceman           DB     rightKey

;; Para fantasmas
redGhost_y                  DW      09h             ;; 9 decimal 
redGhost_x                  DW      13h             ;; 19 decimal

orangeGhost_y               DW      0Bh             ;; 11 decimal
orangeGhost_x               DW      13h             ;; 19 decimal

magentaGhost_y              DW      09h             ;; 9 decimal
magentaGhost_x              DW      15h             ;; 21 decimal

cyanGhost_y                 DW      0Bh             ;; 11 decimal
cyanGhost_x                 DW      15h             ;; 21 decmal

;---------------------------------------------------------
; Variables para la lista de usuarios
;---------------------------------------------------------

currentBestScore DW     00h         ;; Mostramos el mejor puntaje del jugador actual
; Estructura para usuarios
; Nombre
; Cui
; Credenciales


NewUserPointer DW 0                  ;; Apunta hacia donde tiene que insertar nuevamente el usuario
UserList DW 0                       

;; Recorrer

.CODE

INCLUDE utils.asm           ;; Funciones auxiliares que pueden ser usadas en cualquier parte del programa
INCLUDE menu.asm            ;; Menu principal
INCLUDE time.asm            ;; Lógica para el crónometro
INCLUDE game.asm            ;; Lógica del juego
INCLUDE files.asm           ;; Lógica para leer archivos

mStartProgram macro
    startProgram:
        mActiveVideoMode
        mStartGame fileName1
        mStartGame fileName2
        mStartGame fileName3
    exit:
        mActiveTextMode
        mExit
endm

start:
    main PROC
        mov AX, @data
        mov DS, AX
    menuProgram:
        mActiveTextMode
        mPrintMsg infoMsg
        mWaitEnter
        mMainMenu
    displayLoginMenu:
        mMainAdminMenu
        mStartProgram
    main ENDP
END start
