mOpenFileToWrite macro filename
    mov AH, 3Ch             ;; Función de apertura de archivo
    mov AL, 02h             ;; Opciones de acceso, en este caso 2 = write
    lea DX, filename        ;; Movemos el nombre del archivo

    int 21h                 ;; Realizar la interrupción
    jc errorWrite
    mov handleObject, AX    ;; Guardamos el handle en la variable
endm

mWriteSimpleText macro bufferWithText
    mov AH, 40h                     ;; Función de escritura de archivo
    mov BX, handleObject            ;; Handle del archivo
    lea DX, bufferWithText          ;; Texto a escribir
    mov CX, sizeof bufferWithText   ;; Cantidad de bytes a escribir
    int 21h                         ;; Realizar la interrupción

    ;; Colocamos un salto de linea 
    ; mov AH, 40h                     ;; Función de escritura de archivo
    ; mov BX, handleObject            ;; Handle del archivo
    ; lea DX, NEWLINE                 ;; Texto a escribir
    ; mov CX, sizeof NEWLINE          ;; Cantidad de bytes a escribir
    ; int 21h                         ;; Realizar la interrupción
endm

mWriteNumber macro bufferWithText
    
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

        mov BX, handleObject       ;; Movemos a BX le atributo del handler
        mov CX, 1                   ;; Leemos caracter por caracter
        mov DX, DI

        mov AH, 3Fh                 ;; Usamos la interrupción para leer el archivo
        int 21h                     ;; 
        jc errorWhenReadLine                     ;; Si no se puede leer el archivo, nos saltamos a fail

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

ReadFile PROC USES AX BX CX DX
    xor CX, CX

    mov AL, 00                          ;; Modo de lectura
    mov AH, 3dh                         ;; Función para abrir el archivo
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

WriteInFileNumber PROC
    mov BX,  [DI]
    mov numberGotten, BX                    ;; Lo convertimos a Numero
    call NumToStr

    mWriteNumber recoveredStr
    ret
WriteInFileNumber ENDP


;---------------------------------------------------------
; TraverseDataSegment
;
; Descripción:
; Recorre el segmento de datos para graficar los usuarios y juegos, este método será recursivo
;
; Recibe:
; -
;
; Retorna:
; -
;---------------------------------------------------------

TraverseDataSegment PROC
    cmp BX, 00
    je endTraverse

    ; mPrintMsg testStr
    ; mWaitEnter
    mWriteSimpleText MEMADDRESS
    call WriteInFileNumber

    mWriteSimpleText NEXTUSER

    cmp BX, 00
    je skipNextUserAddress
    
    call WriteInFileNumber

    mWriteNumber recoveredStr

    skipNextUserAddress:

        cmp BX, 00
        je skipFirstGame

        call WriteInFileNumber

    skipFirstGame:
        add DI, 02h

    endTraverse:
    ret 
TraverseDataSegment ENDP

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

    ;; TODO: Recorrer memoria
    mov BX, offset dataSegment                  ;; Colocamos el puntero del inicio del usuario en BX
    ; mov AX, [BX]
    ; ; mov numberGotten, AX
    ; ; mPrintNumberConverted
    ; ; mWaitEnter
    call TraverseDataSegment

    mWriteSimpleText footerMemoryGraph          ;; Colocamos el footer para cerrar el archivo uml
    mCloseFile                                  ;; Cerramos el archivo
    jmp endProc
    errorWrite:
        mPrintMsg errorWriteFile
        mWaitEnter
    errorToClose:
        mPrintMsg errorCloseFile
        mWaitEnter
    endProc:
    ret
GenerateMemoryGraph ENDP