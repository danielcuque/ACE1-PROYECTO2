mOpenFileToWrite macro filename
    mov AH, 3Ch             ;; Función de apertura de archivo
    mov AL, 02h             ;; Opciones de acceso, en este caso 2 = write
    lea DX, filename        ;; Movemos el nombre del archivo

    int 21h                 ;; Realizar la interrupción
    jc errorWrite
    mov handleObject, AX    ;; Guardamos el handle en la variable
endm

mReportHeader macro
    mWriteNumberWithoutDoubleQuote simpleSeparatorText
    mWriteNumberWithoutDoubleQuote infoMsg
    mWriteNumberWithoutDoubleQuote simpleSeparatorText
    mWriteNumberWithoutDoubleQuote developerName
    mWriteNumberWithoutDoubleQuote simpleSeparatorText
endm

mWriteSimpleText macro bufferWithText
    push AX
    push BX
    push CX
    push DX

    mov AH, 40h                     ;; Función de escritura de archivo
    mov BX, handleObject            ;; Handle del archivo
    lea DX, bufferWithText          ;; Texto a escribir
    mov CX, sizeof bufferWithText   ;; Cantidad de bytes a escribir
    int 21h                         ;; Realizar la interrupción

    pop DX
    pop CX
    pop BX
    pop AX
endm

mWriteOneChar macro
    push AX
    push BX
    push CX
    push DX

    ; xor DX, DX

    mov AH, 40h                     ;; Función de escritura de archivo
    mov BX, handleObject            ;; Handle del archivo
    mov DX, offset oneCharBuffer          ;; Texto a escribir
    mov CX, 01                      ;; Cantidad de bytes a escribir
    int 21h                         ;; Realizar la interrupción

    pop DX
    pop CX
    pop BX
    pop AX
endm

mWriteNumber macro bufferWithText
    push AX
    push BX
    push CX
    push DX

    mWriteSimpleText DOUBLEQUOTE
    mov AH, 40h                     ;; Función de escritura de archivo
    mov BX, handleObject            ;; Handle del archivo
    lea DX, bufferWithText          ;; Texto a escribir
    mov CX, sizeof bufferWithText   ;; Cantidad de bytes a escribir
    dec CX
    int 21h
    mWriteSimpleText DOUBLEQUOTE 
    mWriteSimpleText COMMA

    ;; Colocamos un salto de linea 
    mov AH, 40h                     ;; Función de escritura de archivo
    mov BX, handleObject            ;; Handle del archivo
    lea DX, NEWLINE                 ;; Texto a escribir
    mov CX, sizeof NEWLINE          ;; Cantidad de bytes a escribir
    int 21h    
     
    pop DX
    pop CX
    pop BX
    pop AX
endm

mWriteNumberWithoutDoubleQuote macro bufferWithText
    push AX
    push BX
    push CX
    push DX

    mov AH, 40h                     ;; Función de escritura de archivo
    mov BX, handleObject            ;; Handle del archivo
    lea DX, bufferWithText          ;; Texto a escribir
    mov CX, sizeof bufferWithText   ;; Cantidad de bytes a escribir
    dec CX
    int 21h

    ;; Colocamos un salto de linea 
    mov AH, 40h                     ;; Función de escritura de archivo
    mov BX, handleObject            ;; Handle del archivo
    lea DX, NEWLINE                 ;; Texto a escribir
    mov CX, sizeof NEWLINE          ;; Cantidad de bytes a escribir
    int 21h    
     
    pop DX
    pop CX
    pop BX
    pop AX
endm

mCloseFile macro
    mov AH, 3Eh ; Función de cierre de archivo
    mov BX, handleObject
    int 21h     ; Realizar la interrupción
    jc errorToClose
endm

;---------------------------------------------------------
; mReadLine
;
; Descripción:
; Lee una línea del archivo
;
; Recibe:
; handleObject -> Información del archivo
;
; Retorna:
; fileLineBuffer -> Str de la línea
;---------------------------------------------------------

mReadLine macro
    LOCAL start, endOfFile, endOfLine, endMacro
    mResetVarWithDollarSign fileLineBuffer
    lea DI, fileLineBuffer
    
    start:

        mov BX, handleObject        ;; Movemos a BX le atributo del handler
        mov CX, 1                   ;; Leemos caracter por caracter
        mov DX, DI

        mov AH, 3Fh                 ;; Usamos la interrupción para leer el archivo
        int 21h                     
        jc errorWhenReadLine        ;; Si no se puede leer el archivo, nos saltamos a fail

        cmp AX, 0
        je endOfFile

        mov AL, [DI]                ;; Cargamos el caracter actual a AL para poder compararlo

        cmp AL, 20h                 ;; Los espacios nos los saltamos
        je start

        cmp AL, 0Ah                 ;; O si encuentra un salto de línea, significa que terminó
        je endOfLine

        cmp AL, 0Dh                 ;; Nos saltamos los retornos de carro
        je start

        mov [DI], AL                ;; Copiamos el valor a DI para guardarlo en el buffer
        inc DI                      ;; Incrementamos la posicion de DI donde se va a guardar
        jmp start

    endOfLine:
        mov BX, handleObject        ;; Leemos un byte más para saltarnos al siguiente caracter
        mov CX, 1
        mov DX, DI
        
        mov AH, 3Fh
        int 21
        jc errorWhenReadLine

        mov DL, 01h
        jmp endMacro
    
    endOfFile:
        mov DL, 02h                 ;; Para indicar que el archivo se acabó, cargamos a DL con 02
    endMacro:
endm


;---------------------------------------------------------
; mGetNumberValue
;
; Descripción:
; Obtiene el valor numérico de la llave propiedad:valor
;
; Recibe:
; keyword -> string que representa la clave a comparar
;
; Retorna:
; AX -> Valor numérico
;---------------------------------------------------------

mGetNumberValue macro keyword
    LOCAL advance
    mov DI, offset keyword
    mov CL, [DI]
    mov SI, offset fileLineBuffer
    advance:                            ;; Avanzamos el tamaño de la palabra
        inc SI                      
        loop advance
    inc SI                              ;; Nos saltamos el ':'
    call IsNumber                       ;; Comprobamos que sea un número
    cmp DL, 01
    jne errorWhenReadLine
    mov AX, numberGotten
endm

;---------------------------------------------------------
; mGetCoordinate
;
; Descripción:
; Obtiene la coordenada X y Y de clave:valor
;
; Recibe:
; -
;
; Retorna:
; AX ->  Pos X
; CX ->  Pos Y
;---------------------------------------------------------
mGetCoordinate macro
    mReadLine
    mGetNumberValue XKW
    mov CX, AX              ;; BX = Pos X AX = Pos X
    
    push CX
        mReadLine
        mGetNumberValue YKW
    pop CX

    xchg CX, AX             ;; CX = Pos X, AX = Pos Y (intercambiamos)  
endm

;---------------------------------------------------------
; ReadFile
;
; Descripción:
; Lee el archivo de entrada a partir de un filename
;
; Recibe:
; DX -> filename
;
; Retorna:
; Tablero de juego lleno
;---------------------------------------------------------

ReadFile PROC USES AX BX CX DX SI DI
    xor CX, CX

    mov AL, 00                          ;; Modo de lectura
    mov AH, 3Dh                         ;; Función para abrir el archivo
    int 21h                             ;; Provocamos la interrupción
    jc errorToOpen

    mov handleObject, AX

    mReadLine

    mov SI, offset fileLineBuffer       ;; La primera línea debería de contener la llave que abre ({)
    mov AL, [SI]                        ;; Comparamos el caracter
    cmp AL, '{'
    jne errorWhenReadLine

    mReadLine                           ;; Leemos "nivel": valor,
    mGetNumberValue NIVELKW
    mov numberLevel, AL

    mReadLine                           ;; Leemos "valordot": valor
    mGetNumberValue VALORDOTKW
    mov aceDotPoints, AX

    mReadLine                           ;; Leemos "acemaninit":{
    mGetCoordinate                      ;; Obtenemos la coordenada de acemaninit
    mov aceman_x, AX                    
    mov aceman_y, CX

    mReadLine                           ;; Leemos },
    mReadLine                           ;; Leemos "walls":[
    mReadLine                           ;; Leemos {

    getWalls:
        mReadLine
        mov SI, offset fileLineBuffer
        mov AL, [SI]

        cmp AL, '}'
        je endWalls

        ;; Leemos el tipo de muro -> "numTipo": [
        cmp AL, '"'
        jne errorWhenReadLine
        inc SI                              ;; Obtenemos el número
        call IsNumber                       
        cmp DL, 01
        jne errorWhenReadLine

        xor DX, DX
        mov DX, numberGotten
        mov currentWallType, DL             ;; Guardamos el valor del tipo de muro en currentWallType

    setWall:
        mReadLine                           ;; Nos saltamos {
        mov SI, offset fileLineBuffer
        mov AL, [SI]

        cmp AL, ']'
        je getWalls

        mGetCoordinate

        xor DX, DX
        dec AX                              ;; Decrementamos AX para que se coloque una posicion antes
        mov DH, currentWallType
        call InsertMapObject

        mReadLine                           ;; Nos saltamos }
        jmp setWall
    

    endWalls:

    mReadLine                               ;; Nos saltamos ],
    mReadLine                               ;; Leemos "power-dots": [                       
    
    getPowerDots:
        mReadLine

        mov SI, offset fileLineBuffer
        mov AL, [SI]

        cmp AL, ']'
        je endPowerDots

        mGetCoordinate

        xor DX, DX
        dec AX
        mov DH, 14h
        call InsertMapObject
        add totalDots, 01H

        mReadLine
        jmp getPowerDots
    
    endPowerDots:
        mReadLine                             ;; Leemos "portales":[
    
    getPortals:
        mReadLine                             ;; Leemos {

        mov SI, offset fileLineBuffer
        mov AL, [SI]

        cmp AL, ']'
        je endPortals

        mReadLine                              ;; Leemos 'numero': valor

        mReadLine                              ;; Leemos "a":{
        
        mGetCoordinate                         ;; Obtenemos las coordenadas del par A

        xor DX, DX
        mov DH, lastPortalInserted
        dec AX
        call InsertMapObject

        mReadLine                              ;; Leemos },
        mReadLine                              ;; Leemos "b":{

        mGetCoordinate                         ;; Obtenemos la coordenada
        xor DX, DX
        mov DH, lastPortalInserted
        dec AX
        call InsertMapObject                   ;; Insertamos el objeto

        add lastPortalInserted, 01h

        mReadLine                              ;; Leemos  }
        mReadLine

        jmp getPortals
        
    endPortals: 
        jmp closeFile
    errorToOpen:
        mPrintMsg errorOpenFile
        mWaitEnter
        jmp endRead
    errorWhenReadLine:
        call PrintCarryFlag
        mPrintMsg errorReadLine
        mPrintMsg fileLineBuffer
        mWaitEnter
        jmp endRead
    errorToClose:
        mPrintMsg errorCloseFile
        mWaitEnter
        jmp endRead
    closeFile:
        mCloseFile
    endRead:
    ret
ReadFile ENDP

;---------------------------------------------------------
; Write16BitsNumberInFile
;
; Descripción:
; Escribe un numero en el documento, con sus respetivos "" (comilla doble) para un numero de 16 bits (DW)
;
; Recibe:
; BX ->  Valor del numero
;
; Retorna:
; -
;---------------------------------------------------------

Write16BitsNumberInFile PROC USES CX
    xor CX, CX
    mov CX, [BX]
    
    mov numberGotten, CX                    ;; Lo convertimos a numero
    call NumToStr
    mWriteNumber recoveredStr

    ret
Write16BitsNumberInFile ENDP

Write8BitsNumberInFile PROC USES CX
    xor CX, CX
    mov CL, [BX]
    
    mov numberGotten, CX                    ;; Lo convertimos a numero
    call NumToStr
    mWriteNumber recoveredStr

    ret
Write8BitsNumberInFile ENDP



;---------------------------------------------------------
; TraverseDataSegment
;
; Descripción:
; Recorre el segmento de datos para graficar los usuarios y juegos, este método será recursivo
;
; Recibe:
; BX ->  dirección de memoria del usuario
;
; Retorna:
; -
;---------------------------------------------------------

TraverseDataSegment PROC
    cmp BX, 00                      ;; Verifica que la direccion del usuario no sea 0
    je endTraverse                  ;; De lo contrario salta al final del metodo

    mWriteSimpleText LBRACE
    mWriteSimpleText MEMADDRESS     ;; Escribimos la dirección de memoria del usuario
    call Write16BitsNumberInFile

    add BX, 02h                     ;; Sumamos 2, y nos posicionamos en la dirección del siguiente usuario
    mov SI, [BX]                    ;; Guardamos la direccion del siguiente usuario en SI

    mWriteSimpleText NEXTUSER       ;; Escribimos la dirección del siguiente usuario
    call Write16BitsNumberInFile

    add BX, 02h
    mov DI, [BX]                    ;; Guardamos esa dirección en DI
    mWriteSimpleText FIRSTGAME      ;; Dirección de memoria del primer juego
    call Write16BitsNumberInFile

    add BX, 02h                     ;; Escribimos las credenciales, admin, o usuario normal
    mWriteSimpleText CREDENTIALS
    call Write8BitsNumberInFile

    add BX, 01
    mWriteSimpleText ISUSERACTIVE   ;; Escribimos si el usuario está activo o no
    call Write8BitsNumberInFile

    add BX, 01h
    mWriteSimpleText NAMESIZE       ;; Tamaño del nombre
    call Write8BitsNumberInFile

    xor CX, CX
    mov CL, [BX]

    add BX, 01

    mWriteSimpleText NAMESTR        ;; Escribimos el nombre
    mWriteSimpleText DOUBLEQUOTE
    push DI
    saveUsername:   
            mov DI, BX
            mov AL, [DI]
            mov oneCharBuffer, AL
            mWriteOneChar

            inc BX
            loop saveUsername
    pop DI

    mWriteSimpleText DOUBLEQUOTE
    mWriteSimpleText COMMA
    mWriteSimpleText NEWLINE
    
    mWriteSimpleText PASSWORDSIZE   ;; Tamaño de la contraseña
    call Write8BitsNumberInFile

    xor CX, CX
    mov CL, [BX]

    add BX, 01

    mWriteSimpleText PASSWORDSTR    ;; Cadena de la contraseña
    mWriteSimpleText DOUBLEQUOTE

    push DI
    savePassword:   
            mov DI, BX
            mov AL, [DI]
            mov oneCharBuffer, AL
            mWriteOneChar

            inc BX
            loop savePassword
    pop DI
            
    mWriteSimpleText DOUBLEQUOTE
    mWriteSimpleText COMMA
    mWriteSimpleText NEWLINE

    mWriteSimpleText GAMES                  ;; games: []
    mWriteSimpleText LSBRACE

    ;; TODO: Recorrer juegos
    push BX
        mov BX, DI
        call TraverseGames
    pop BX

    mWriteSimpleText RSBRACE
    mWriteSimpleText COMMA
    mWriteSimpleText NEWLINE
    
    mWriteSimpleText USERS
    mWriteSimpleText LSBRACE

    push BX
        mov BX, SI                          ;; Movemos la dirección de memoria del proximo usuario para que se genere su gráfica, recursivamente
        call TraverseDataSegment            ;; LLamamos de manera recursiva para ingresar usuarios
    pop BX

    mWriteSimpleText RSBRACE
    mWriteSimpleText RBRACE

    endTraverse:
        ret 
TraverseDataSegment ENDP

;---------------------------------------------------------
; TraverseGames
;
; Descripción:
; Grafica los juegos de un jugador
;
; Recibe:
; BX -> Dirección de memoria del primer juego
;
; Retorna:
; -
;---------------------------------------------------------
TraverseGames PROC USES DI SI
    cmp BX, 00
    je endTraverse

    mWriteSimpleText LBRACE             ;; Escribimos {
    mWriteSimpleText MEMADDRESS         ;; Escribimos la dirección de memoria de la información del juego

    call Write16BitsNumberInFile        ;; Escribimos dicha información

    add BX, 02h
    mov SI, [BX]                        ;; Guardamos la dirección de memoria del proximo juego
    mWriteSimpleText NEXTGAME
    call Write16BitsNumberInFile

    add BX, 02h
    mWriteSimpleText SCORE
    call Write16BitsNumberInFile        ;; Escribimos el puntaje

    mWriteSimpleText UNIDADT
    mWriteSimpleText CENTESIMAS

    add BX, 02
    mWriteSimpleText TIME               ;; Escribimos el tiempo en centesimas de segundo
    call Write16BitsNumberInFile

    add BX, 02
    mWriteSimpleText LEVEL
    call Write8BitsNumberInFile         ;; Escribimos el numero del nivel que se jugó

    add BX, 01h
    mWriteSimpleText USERADDRESS        ;; Escribimos la dirección de memoria del usuario al que pertenece el juego
    call Write16BitsNumberInFile

    mWriteSimpleText NEXTGAMES           ;; Escribimos los juegos siguientes
    mWriteSimpleText LSBRACE            ;; Escribimos [

    push BX
        mov BX, SI
        call TraverseGames
    pop BX
    mWriteSimpleText RSBRACE            ;; Escribimos ]
    mWriteSimpleText RBRACE

    endTraverse:
    ret
TraverseGames ENDP

;---------------------------------------------------------
; GenerateMemoryGraph
;
; Descripción:
; Muestra la representación de la memmoria que contiene a todos los usuarios
;
; Recibe:
; -
;
; Retorna:
; Archivo generado
;---------------------------------------------------------

GenerateMemoryGraph PROC
    mOpenFileToWrite filenameMemoryGraph        ;; Creamos el archivo
    mWriteSimpleText headerMemoryGraph          ;; Escribimos los encabezados para visualizar el manejo de memoria

    lea SI, dataSegment
    mov BX, [SI]                                ;; Colocamos el puntero del inicio del usuario en BX
    call TraverseDataSegment

    mWriteSimpleText footerMemoryGraph          ;; Colocamos el footer para cerrar el archivo uml
    mCloseFile                                  ;; Cerramos el archivo
    jmp endProc
    errorWrite:
        mPrintMsg errorWriteFile
        mWaitEnter
        jmp endProc
    errorToClose:
        mPrintMsg errorCloseFile
        mWaitEnter
    endProc:
    ret
GenerateMemoryGraph ENDP


GeneratePersonalTimeReport PROC
    mOpenFileToWrite filePersonalTimeReport

    mReportHeader

    mCloseFile
    jmp endProc
    
    errorWrite:
        call PrintCarryFlag
        mPrintMsg errorWriteFile
        mWaitEnter
        jmp endProc
    errorToClose:
        mPrintMsg errorCloseFile
        mWaitEnter
    endProc:
    ret
GeneratePersonalTimeReport ENDP

GeneratePersonalScoreReport PROC
    mOpenFileToWrite filePersonalScoreReport

    mCloseFile
    errorWrite:
        call PrintCarryFlag
        mPrintMsg errorWriteFile
        mWaitEnter
        jmp endProc
    errorToClose:
        mPrintMsg errorCloseFile
        mWaitEnter
    endProc:
    ret
GeneratePersonalScoreReport ENDP

GenerateGlobalScoreReport PROC
    mOpenFileToWrite fileGlobalScoreReport

    mReportHeader

    mCloseFile
    jmp endProc
    
    errorWrite:
        call PrintCarryFlag
        mPrintMsg errorWriteFile
        mWaitEnter
        jmp endProc
    errorToClose:
        mPrintMsg errorCloseFile
        mWaitEnter
    endProc:
    ret
GenerateGlobalScoreReport ENDP

GenerateGlobalTimeReport PROC
    mOpenFileToWrite fileGlobalTimeReport

    mReportHeader

    mCloseFile
    jmp endProc
    
    errorWrite:
        call PrintCarryFlag
        mPrintMsg errorWriteFile
        mWaitEnter
        jmp endProc
    errorToClose:
        mPrintMsg errorCloseFile
        mWaitEnter
    endProc:
    ret
GenerateGlobalTimeReport ENDP

