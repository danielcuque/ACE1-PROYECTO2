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
    ; mPrintPartialDirection SI
    ; mWaitEnter
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
        dec AX
        mov DH, currentWallType
        call InsertMapObject

        mReadLine                           ;; Nos saltamos }
        jmp setWall
    

    endWalls:                          
    getPowerDots:
    getPortals:
     

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
        mov BX, handleObject
        mov AH, 03Eh                    ;; Cargamos a AH para hacer la interrupción de cerrar archivo
        int 21h                         ;; Cerramos el archivo
        jc errorToClose                 ;; Mandamos el error si el carry flag se activa
    endRead:
    ; mPrintMsg testStr
    ; mWaitEnter
    ret
ReadFile ENDP