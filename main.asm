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
infoMsg             DB 'Universidad de San Carlos de Guatemala', 0Dh, 0Ah,'Facultad de Ingenieria', 0Dh, 0Ah,'Escuela de Ciencias y Sistemas', 0Dh, 0Ah,'Arquitectura de computadores y ensambladores 1', 0Dh, 0Ah,'Seccion B', 0Dh, 0Ah,'Daniel Estuardo Cuque Ruiz' , 0Dh, 0Ah,'202112145', '$'
developerName       DB 'Daniel Cuque | 202112145$'
colonChar           DB ':$'
COLONKW             DB ':'
SLASHKW             DB '/'
newLineChar         DB 0Ah, '$'
errorOpenFile       DB 'Error al abrir el archivo$'
errorReadLine       DB 'Error al leer la linea en $'
errorCloseFile      DB 'Error al cerrar el archivo$'
errorLoginUser      DB 'El usuario y contrase',0A4h,'a son incorrectas',0Dh, 0Ah,'$'
errorUserActive     DB 'El usuario no est',0A0h,' activo$'
errorSizeOfNumber   DB 'Numero demasiado grande$'
errorWriteFile      DB 'Error al escribir el archivo$'

pressEToExit        DB 'Presione E para salir$'
pressEnterToContinue DB 'Presione ENTER para continuar$'

successfulLoginMsg  DB 'Inicio de sesion correcto$'
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
filenameMemoryGraph     DB 'docs/uml/README.md', 0

filePersonalTimeReport  DB 'reports/TIEMPOPR.txt', 0
filePersonalScoreReport DB 'reports/PUNTPR.txt', 0
fileGlobalScoreReport   DB 'reports/TIEMPOSGL.txt', 0
fileGlobalTimeReport    DB 'reports/PUNTGL.txt', 0


headerMemoryGraph DB '````plantuml', 0Dh, 0Ah, '@startjson memoryGraph', 0Dh, 0Ah, '{', '"dataSegment":', 0Dh, 0Ah, '['
footerMemoryGraph DB ']}', 0Dh, 0Ah, '@endjson', 0Dh, 0Ah,'````'

;---------------------------------------------------------
; Variable para convertir numeros
;---------------------------------------------------------
numberGotten DW 0
recoveredStr DB 8 DUP('$')
counterToGetIndexGotten DW 0

;---------------------------------------------------------
; Variables para los reportes
;---------------------------------------------------------
simpleSeparatorText       DB 32h dup('-')
doubleSeparatorText       DB 32h dup('=')
TABULADORKW               DB 09
TIPOKW                    DB 'Tipo: '
SENTIDOKW                 DB 'Sentido: '
FECHAKW                   DB 'Fecha: '
HORAKW                    DB 'Hora: '
RANKKW                    DB 'Rank'
PLAYERKW                  DB 'Player'
NKW                       DB 'N'

;; Ordenamientos
BUBBLESORTKW              DB 'Bubble'
COCKTAILSORTKW            DB 'Cocktail'
PRIMESORTKW               DB 'Prime'

;; Sentidos
ASCENDENTEKW              DB 'Ascendente'
DESCENDENTEKW             DB 'Descendente'

;; Metricas
TIEMPOKW                  DB 'Tiempo'
PUNTOSKW                  DB 'Puntos'


metricaMsg                DB '1. Tiempo', 0Dh, 0Ah, '2. Puntaje',0Dh, 0Ah,'$'
sortTypeMsg               DB '1. Bubble sort', 0Dh, 0Ah, '2. Cocktail sort', 0Dh, 0Ah, '3. Prime sort', 0Dh, 0Ah, '$'
directionMsg              DB '1. Ascendente',0Dh, 0Ah,'2. Descendente',0Dh, 0Ah,'$'

metricaValue DB 0
sortTypeValue DB 0
directionValue DB 0

LBRACE              DB '{'
RBRACE              DB '}'
LSBRACE             DB '['
RSBRACE             DB ']'
COMMA               DB ','
DOUBLEQUOTE         DB 22h
NEWLINE             DB 0Ah

MEMADDRESS          DB '"memoryAddress":'
NEXTUSER            DB '"nextUser":'
FIRSTGAME           DB '"firstGame":'
CREDENTIALS         DB '"credentials":'
ISUSERACTIVE        DB '"isUserActive":'
NAMESIZE            DB '"nameSize":'
NAMESTR             DB '"nameStr":'
PASSWORDSIZE        DB '"passwordSize":'
PASSWORDSTR         DB '"passwordStr":'
GAMES               DB '"games":'
USERS               DB '"users":'
USERADDRESS         DB '"userAddress":'
NEXTGAME            DB '"nextGame":'
TIME                DB '"time":'
SCORE               DB '"score":'
LEVEL               DB '"level":'
NEXTGAMES           DB '"nextGames":'
CENTESIMAS          DB '"centesimas de s",'
UNIDADT             DB '"timeUnit":'

oneCharBuffer DB 0
;---------------------------------------------------------
; Variables para los menus y login
;---------------------------------------------------------
INICIARJUEGO              DB '1. Iniciar juego', 0Dh, 0Ah,'$'
TOP10TIEMPOSPERSONALES    DB '. Top 10 tiempos personales', 0Dh, 0Ah,'$'
TOP10PUNTEOPERSONAL       DB '. Top 10 punteo personal', 0Dh, 0Ah,'$'
SALIR                     DB '. Salir', 0Dh, 0Ah,'$'
TOP10TIEMPOSGLOBALES      DB '. Top 10 tiempos globales', 0Dh, 0Ah,'$'
TOP10PUNTEOGLOBAL         DB '. Top 10 punteos globales', 0Dh, 0Ah,'$'
APROBARUSUARIO            DB '3. Aprobar usuario', 0Dh, 0Ah,'$'
INACTIVARUSUARIO          DB '2. Inactivar usuario', 0Dh, 0Ah,'$'
INICIARSESION             DB '1. Iniciar sesi',0A2h,'n',0Dh, 0Ah,'$'
USERNAMEMSG               DB 'Ingresar nombre: $ '                  
PASSWORDMSG               DB 'Ingresar contrase',0A4h,'a: $'
NEWUSERMSG                DB 'F5 para solicitar nuevo usuario',0Dh, 0Ah,'$'
USERMSG                   DB 'Usuario: $'


;---------------------------------------------------------
; Variables para el cronómetro
;---------------------------------------------------------
initialTime     DW 00                           ;; Se guarda la los minutos:segundos:cs de cuando se inicia el juego en cs (centésimas de segundo)
currentTime     DW 00h                          ;; Se va actualizando el tiempo

initialMinutes  DB 00h
initialSeconds  DB 00h
initialHundred  DB 00h

timePassed      DW 00h
totalTimePassed DW 00h
minuteTime      DW 00h
secondTime      DW 00h
hundredTime     DW 00h

;---------------------------------------------------------
; Variables para el teclado
;---------------------------------------------------------
nameBuffer                  DB   102h dup (0ffh, '$')           ;; Guarda el nombre
passwordBuffer              DB   102h dup (0ffh, '$')           ;; Guarda la contraseña

nameMainAdmin               DB   '202112145'            
; nameMainAdmin               DB   '22'            
passwordMainAdmin           DB   '3024465830102'
; passwordMainAdmin           DB   '33'

bufferPlayerName            DB 10h dup('$')                 ;; Nombre del jugador para mostrarlo durante la aprobación/desaprobación
APPROVEOPTIONSMSG           DB '1 - Aprobar',0Dh, 0Ah,'2 - Siguiente',0Dh, 0Ah, '3 - Regresar',0Dh, 0Ah, '$'
CREDENTIALESMSG             DB '1 - Usuario normal',0Dh, 0Ah, '2 - Usuario administrador', 0Dh, 0Ah, '$'


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
isBackMenu          DB 00                           ;; 00 = continuar | FF = volver al menú principal

currentPlayerName   DB 10h dup('$')                 ;; Nombre del jugador
userLoggedAdress    DW 00h                          ;; Guarda la direccion de memoria del usuario actual
currentBestScore    DW 00h                          ;; Mostramos el mejor puntaje del jugador actual

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

; Estructura para usuarios
; "memoryAddress": "000F",
; "nextUser": "0022h"
; "firstGame": "0023h"
; "credentials": "01"
; "isUserActive": "01"
; "nameSize": "09"
; "nameStr": "202112145"
; "passwordSize": "13"
; "passwordStr": "3024465830102"
; "games": [anidar juegos]
; "users": [anidar proximos usuarios]

; Estructura para juegos

; "memoryAddress": 0023h
; "nextGame": "0024h"
; "score": "1000"
; "time": "400"
; "level": "1"
; "userAddress": "000F"
; "nextGames": []
memoryAddressArray DW 50h dup('$')
prevPointer DW 0
nextPointer DW 0                  ;; Apunta hacia donde tiene que insertar nuevamente el usuario. De inicio es la dirección 4415
dataSegment DW 0                       

;; Recorrer

.CODE
INCLUDE keyboard.asm        ;; Funciones con el teclado
INCLUDE utils.asm           ;; Funciones auxiliares que pueden ser usadas en cualquier parte del programa
INCLUDE crud.asm
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
        mActiveTextMode             ;; Después de terminar los 3 niveles, se regresa al menu del usuario correspondiente
        mCheckUserCredentials
    exit:
        mActiveTextMode
        mExit
endm

start:
    main PROC
        mov AX, @data
        mov DS, AX   

        call InsertMainAdmin   ;; Insertamos el usuario administrado antes del todo
        mPrintMsg infoMsg
        mWaitEnter

        menuProgram:
            mActiveTextMode
            mMainMenu
        normalUserMenu:
            mNormalUserMenu
        adminUserMenu:
            mAdminUserMenu
        globalAdminMenu:
            mMainAdminMenu
            mStartProgram
            jmp exit
    main ENDP
END start
