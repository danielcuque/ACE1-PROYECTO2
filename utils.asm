; ------------------------------------------------------------
; Se espera a que el usuario presione la tecla ENTER, 
; de lo contrario vuelve a solicitar la tecla
; ------------------------------------------------------------
mWaitEnter macro
    LOCAL wait_enter
    push AX
    wait_enter:
        mov AH, 08h
        int 21
        cmp AL, 0Dh
        jne wait_enter
    pop AX
endm

;---------------------------------------------------------
; mResetVarWithDollarSign
;
; Descripción:
; Reinicia una variable con signo dolar ($) tomando su tamaño
;
; Recibe:
; -
;
; Retorna:
; -
;---------------------------------------------------------

mResetVarWithDollarSign macro str
    LOCAL start
    push CX
    push BX
    push AX

    xor CX, CX
    mov CL, sizeof str
    mov BX, offset str
    mov AL, 24h

    start:
        mov [BX], AL
        inc BX
    loop start

    pop AX
    pop BX
    pop CX
endm

; ------------------------------------------------------------
; Recibe como parámetro un string y lo imprime en pantalla
; ------------------------------------------------------------

mPrintMsg macro str
    push AX
    push DX

    mov DX, offset str
    mov AH, 09h
    int 21h

    pop DX
    pop AX
endm

mPrintPartialDirection macro str
    push AX
    push DX

    mov DX, str
    mov AH, 09h
    int 21h

    pop AX
    pop DX
endm

mActiveVideoMode macro
    push AX
    mov AL, 13h
    mov AH, 00
    int 10h
    pop AX
endm

mActiveTextMode macro
    push AX
    mov AL, 03h
    mov AH, 00h
    int 10h
    pop AX
endm

; ------------------------------------------------------------
; Finaliza el programa con la interrupción 21 con 4Ch
; ------------------------------------------------------------
mExit macro
    mov AH, 4Ch ;4C en hexa servirá para cargar y generar la int del programa
    int 21h
endm

;---------------------------------------------------------
; EmptyScreen
;
; Descripción:
; Vacía la pantalla
;
; Recibe:
; -
;
; Retorna:
; -
;---------------------------------------------------------

EmptyScreen PROC USES AX CX DI
    mov CX, 0h							;; Dejamos el numero de columna en 0
	printRow:
		mov AX, 0h							;; Cada vez que se pinte una fila, la pos X regresa a 0
	printCol:
        mov DI, offset wallSprite
		call PrintSprite

		inc AX
		cmp AX, 28h					;; Comparamos si llegamos a la ultima fila
		jne printCol				;; Si no llegamos, seguimos iterando

		inc CX						
		cmp CX, 19h					;; Comparamos si llegamos a la última fila
		jne printRow	
    ret
EmptyScreen ENDP

;---------------------------------------------------------
; mIsNumber
;
; Descripción:
; Comprueba si la cadena es un numero
;
; Recibe:
; SI -> Posicion donde se quiere verificar si es número
;
; Retorna:
; DL -> 0, si no es número
; DL -> 1, si sí es número
; numberGotten -> Si sí es numero, se carga de str a num, guardando el valor en dicha variable
;---------------------------------------------------------

IsNumber PROC
	xor CX, CX              ;; Este llevara el control de cuantas posiciones aumentar en SI en caso de que sí sea necesario
    xor BX, BX
    xor AX, AX

    mov BX, SI              ;; Copiamos la direccion de memoria de SI para no modificar SI si no es necesario
    
    start:

        mov AL, [BX]
    
        cmp AL, 20h         ;; Si llegamos al espacio y todo está correcto, entonces generamos el numero
        je success

        cmp AL, 00h          ;; Comparamos que si es caracter nulo, llegamos al final
        je success

		cmp AL, 2Ch			;; El numero puede llevar a su fin si se detecta una coma
		je success

        cmp AL, 0Dh         ;; O comparamos que no sea un valor de retorno
        je success

        cmp AL, 0Ah         ;; O si encuentra un salto de línea, significa que terminó
        je success

        cmp AL, '"'         ;; Para obtener el tipo de número
        je success

        cmp AL, 24h         ;; O si encuentra un salto de línea, significa que terminó
        je success
 
        cmp AL, 30h         ;; Comparamos que el ASCII no sea menor al ASCII DE 1
        jb isNot

        cmp AL, 39h         ;; Comparamos que el ASCII no sea mayor al ASCII de 9
        ja isNot

        inc BX
        inc CX              ;; Incrementamos CX para poder hacer un loop y guardar el número recuperado en formato string
        
        jmp start
 
    isNot:
        mov DL, 00h         ;; Si no es número, entonces seteamos a DL como 0 y lo retornarmos
        jmp endProc

    success:
        xor AX, AX                          ;; Limpiamos a AX
        mov BX, offset recoveredStr         ;; Movemos la direccion de memoria del número a recuperar para insertarle datos

        cmp CX, 07h                         ;; Si el número es mayor a 5, significa que no es válido
        jl generateNumber                   ;; Si es menor a 5, entonces recuperamos el número

        mPrintMsg errorSizeOfNumber         ;; si no es válido, lo devolvemos a isNot    
        jmp isNot
        
        generateNumber:
            mResetVarWithDollarSign recoveredStr

            createNumber:

                mov AL, [SI]                    ;; Movemos el valor que se encuentra en SI a AX, por ejemplo, si en Si está 1, entonces lo movemos
                mov [BX], AL                    ;; Le insertamos ese valor a la variable de recoveredStr
                inc BX                          ;; Incrementamos DI
                inc SI                          ;; Incrementamos SI, para avanzar en el buffer
                loop createNumber               ;; Ciclamos
                
                call StrToNum                    ;; Convertimos el String a número
                mov DL, 01
    endProc:
		ret
IsNumber ENDP


;---------------------------------------------------------
; PrintSprite
;
; Descripción:
; Muestra el sprite del pacman en la pantalla
;
; Receives:
; -
;
; Returns:
; AX -> Posición en X actual del aceman 
; CX -> Posición en Y actual del aceman 
;---------------------------------------------------------

PrintAceman PROC
	getCloseAceman:	
		mov AX, aceman_x					;; Cargamos la posición en X del aceman
		mov CX, aceman_y					;; Cargamos la posición en Y del aceman

		mov DL, currentAcemanSprite  		;; Preguntamos si el aceman tiene la boca abierta o cerrada
		cmp DL, 0ff							;; Si es FF entonces saltamos al aceman con boca abierta
		je getOpenAceman			

		mov DI, offset acemanClose			;; De lo contrario pintamos el aceman con boca cerrada
		mov DH, 00							;; Reseteamos DX
		mov DL, dir_sprite_aceman			;; Guardamos la dirección del aceman (arriba, abajo, etc)
		add DI, DX							;; Con esto nos movemos a la posición del sprite del aceman dependiendo de su dirección
		jmp getAceman						;; Nos saltamos a donde se pinta el aceman

	getOpenAceman:	
		mov DI, offset acemanOpen			;; Repetimos el mismo proceso para obtener el sprite dependiendo de su dirección
		mov DH, 00
		mov DL, dir_sprite_aceman
		add DI, DX
		
	getAceman:
			call PrintSprite				;; Utilizamos el proc que pinta el sprite

			call DelayProc					;; Hacemos un delay para que se pueda ver la transición

			mov DL, currentAcemanSprite	;; Cambiamos el estado del aceman para que en la siguiente iteración tenga la boca en el estado contrario
			not DL							;; Negamos 0 o FF

			mov currentAcemanSprite, DL	;; Guardamos el valor engado en la variable

			mov DI, offset wallSprite		;; Pintamos un sprite vacío en donde estaba el aceman
			call PrintSprite
			ret
PrintAceman ENDP

mPrintGhots macro x_pos, y_pos, ghostSprite
	LOCAL print, printGhostBlue
	push AX
	push CX

	mov AX, x_pos
	mov CX, y_pos

	cmp isGhostBlue, 00
	jne printGhostBlue

	mov DI, offset ghostSprite
	jmp print

	printGhostBlue:
		mov DI, offset GhostBlue
	print:
		call PrintSprite

	pop CX
	pop	AX

endm

mPrintAllGhots macro
	mPrintGhots redGhost_x, redGhost_y, GhostRed
	mPrintGhots orangeGhost_x, orangeGhost_y, GhostOrange
	mPrintGhots cyanGhost_x, cyanGhost_y, GhostCyan
	mPrintGhots magentaGhost_x, magentaGhost_y, GhostMagenta
endm

;---------------------------------------------------------
; PrintSprite
;
; Descripción:
; Pinta en el tablero el sprite que se le mande
;
; Recibe:
; DI -> offset del sprite en memoria de 8x8
; AX -> Posición en X
; CX -> Posición en Y
;
; Retorna: -
;---------------------------------------------------------
PrintSprite PROC USES AX CX DX DI
    
	mov BX, 0h					;; Limpiamos al registro BX
	mov DL, 08h					;; Cargamos a DL 8
	mul DL						;; Multiplicamos Posx * 8 para hacer row major con la matriz de pixeles
	add BX, AX					;; Sumamos el resultado de la multiplación
	xchg AX, CX					;; Intercambiamos el valor de las posiciones
	mul DL						;; Multiplicamos nuevamente * 8 las filas
	xchg AX, CX

	putSprite:
		cmp CX, 0h
		je endPut

		add BX, 140h
		loop putSprite

	endPut:
			mov CX, 8h
			
	printSpriteRow:
			push CX
			mov CX, 8h
			
	printSpriteCol:
		mov AL, [DI]
		push DS
		mov DX, 0A000
		mov DS, DX
		mov [BX], AL
		inc BX
		inc DI
		pop DS
		loop printSpriteCol
		pop CX
		sub BX, 08h
		add BX, 140h
		loop printSpriteRow
		ret
PrintSprite ENDP

DelayProc PROC
	delay:
		mov BP, 03000
	ciclob:		
		mov SI, 00010
	cicloa:		
		dec SI
		cmp SI, 00
		jne cicloa
		dec BP
		cmp BP, 00
		jne ciclob
		ret
DelayProc ENDP

;---------------------------------------------------------
; ResetPointer
;
; Descripción:
; Mueve el puntero hacia el inicio de la pantalla
;
; Recibe:
; -
;
; Retorna:
; -
;---------------------------------------------------------

ResetPointer PROC
	mov AH, 02
	mov DH, 00
	mov DL, 00
	mov BH, 00
	int 10
	ret
ResetPointer ENDP

;---------------------------------------------------------
; NumToStr
;
; Descripción:
; Convierte un un numero usando numberGotten a Str
;
; Recibe:
; NumberGotten cargado
;
; Retorna:
; recoveredStr
;---------------------------------------------------------

NumToStr PROC USES AX BX CX DX SI DI

	mResetVarWithDollarSign recoveredStr    ;; Reiniciamos la variable para mostrar un numero str
	mov BX, 0Ah                             ;; Cargamos a BX con 10
    xor CX, CX                              ;; Limpiamos a cx
    mov AX, numberGotten                    ;; Le cargamos a AX el valor del numero que queremos convertir
	mov counterToGetIndexGotten, 0

    extract:
        xor DX, DX                          ;; Limpio a DX
        div BX                              ;; Obtengo el residuo de la division 
        add DX, 30h                         ;; Le sumo a DX el valor de 30 hexa para que el residuo se mueva hacia la posicion del no. ASCII
        push DX                             ;; Meto ese valor de DX en el top de la pila
        inc CX                              ;; Incremento a CX en 1 para asi poder ejecutar el loop
        cmp AX, 0                           ;; Si ax no es 0, entonces sigo ejecutando el bloque de codigo
        jne extract

    ;; En esta sección vamos a añadir los 0s que faltan al numero hacia la izquierda
    push DX                                 ;; Primero guardamos la informacion de DX para poder utilizarlo como registro de cuantos 0s faltan

    mov SI, 0                               ;; Colocamos a SI

    mov DX, 07h                             ;; Inicialmente serán 6, ya que si recibimos el valor de 1, entonces queremos que se muestre como 000001
    sub DX, CX                              ;; El valor de CX nos ayudará a saber el tamaño del numero, para el caso de 1, será 6 - 1 = 5
                                            ;; Por lo que agregaremos 5 0s
    mov counterToGetIndexGotten, DX	        ;; Muevo el valor en el que se quedó DX para poder correrme a esa posición de la cadena

    addZeroToLeft:
        cmp DX, 00h                         ;; Comparo si DX no es 0, si es cero, significa que el num es de 5 cifras
        je continueStore                    ;; Saltamos a otra etiqueta
        mov recoveredStr[SI], 30h           ;; Si no es asi, entonces modificamos la etiqueta recovered Str donde insertará los 0s que hagan falta
        dec DX                              ;; Decrementamos a DX para que poder acabar el ciclo
        inc SI                              ;; Incrementamos SI para avanzar en la cadena
        jmp addZeroToLeft                   ;; Creamos un pseudo loop para insertar los 0s

    continueStore:
        pop DX                              ;; Sacamos el valor de DX que estaba en el top para poder regresarlo a como estaba
        mov SI, 0                           ;; Inicializo a SI en 0
        add SI, counterToGetIndexGotten     ;; Nos movemos con SI, hacia el numero en memoria que le corresponde a la cadena

    store:
        pop DX                              ;; Despues tengo que hacer la misma cantidad de pops que de push, e ir sacando los valores de DX 
        mov recoveredStr[SI], DL            ;; El resultado de las operaciones se almacenan en la parte baja de DX por lo que 
                                            ;; usamos D low (DL) 
        inc SI                              ;; Incrementamos en 1 la dirección de memoria para acceder al byte que le corresponde int SI += 1
        loop store                          ;; Se ejecuta el loop hasta que CX llegue a 0
	ret
NumToStr ENDP

;---------------------------------------------------------
; StrToNum
;
; Descripción:
; Convierte el numero almacenado en recoveredStr en un numero
;
; Recibe:
; SI ->  posición donde se encuentra el str a evaluar
;
; Retorna:
; numberGotten ->  numero extraido del str
;---------------------------------------------------------
StrToNum PROC USES AX BX CX DX
	xor SI, SI ; Limpio SI
    xor AX, AX ; Limpio AX
    xor DX, DX ; Limpio DX
    mov BX, 0Ah ; Cargo a BX con 10 decimal
    
    nextNum:
        mul BX 
        mov DL, recoveredStr[SI]
        sub DL, 30h
        add AX, DX
        inc SI
        mov DL, recoveredStr[SI]
        cmp DL, 24h
        je endProc
        jmp nextNum
    endProc:
        mov numberGotten, AX
	ret
StrToNum ENDP

mPrintNumberConverted macro
    call NumToStr
    mPrintMsg recoveredStr
endm

;---------------------------------------------------------
; mPrintTotalPoints
;
; Descripción:
; Convierte la variable que se encuentra en totalPoints a string para poder mostrarla en pantalla
;
; Recibe:
; -
;
; Retorna:
; número convertido a str
;---------------------------------------------------------

mPrintTotalPoints macro
	push AX
		mov AX, totalPoints
		xchg AX, numberGotten
		call ResetPointer
		mPrintNumberConverted
		mov numberGotten, 00
	pop AX
endm

;---------------------------------------------------------
; CompareStr
;
; Descripción:
; Compara dos cadenas para ver si son iguales
;
; Recibe:
; SI -> offset de la cadena A, la cadena apunta al tamaño de la misma
; DI -> offset de la cadena B que se quiere comparar con A
; 
;
; Retorna:
; DL ->  0, no son iguales
; DL ->  1, son iguales
;---------------------------------------------------------

CompareStr PROC USES AX BX SI DI
    mov DX, 00h       
    mov CL, [DI]
    inc DI
    compareLoop:
        mov AL, [DI]
        mov BL, [SI]
        cmp AL, BL
        jne endCompare
        inc DI
        inc SI
        loop compareLoop
    
    mov DL, 01

    endCompare:
	ret
CompareStr ENDP

;---------------------------------------------------------
; PauseMenu
;
; Descripción:
; Se muestra en el menu de pausa del juego
;
; Recibe:
; -
;
; Retorna:
; -
;---------------------------------------------------------
PauseMenu PROC USES AX
    waitAnswer:
        mov AH, 08h
        int 21

        cmp AL, 0Dh
        je endProc

        cmp AL, 65h
        je setBackMenu

        jmp waitAnswer

    setBackMenu:
        mov isBackMenu, 01h        ;; 00 o FF 
    
    endProc:
    ret
PauseMenu ENDP

;---------------------------------------------------------
; mResetVars
;
; Descripción:
; Reinica todas las variables del juego
;
; Recibe:
; -
;
; Retorna:
; Variables reiniciadas
;---------------------------------------------------------
mResetVars macro
    mov isBackMenu, 00
    mov totalDots, 00
    mov ghostPoints, 64h
endm

;---------------------------------------------------------
; FillWithDots
;
; Descripción:
; LLena el tablero con dots
;
; Recibe:
; -
;
; Retorna:
; -
;---------------------------------------------------------
FillWithDots PROC USES AX BX CX DX
    mov CX, 02 ; row
	mov AX, 01 ; col
	getRowValue:
	    call GetMapObject

	    cmp DL, 00
        jne searchNextValue

	    push CX

        searchWallBelow:
            inc CX
            call GetMapObject

            cmp DL, 00
            jne searchWallAbove

            cmp CX, 17h
            je searchNextValueBelow

            jmp searchWallBelow

	    searchWallAbove:
	    pop CX

	    push CX 
	    loopSearchWallAbove:
            dec CX
            call GetMapObject

            cmp DL, 00
            jne searchWallRight

            cmp CX, 01 
	        je searchNextValueAbove
	
	        jmp loopSearchWallAbove

	    searchWallRight:
	        pop CX 
	        push AX

	    loopSearchWallRigth:

	    inc AX
        call GetMapObject

        cmp DL, 00
        jne searchWallLeft

        cmp AX, 27h
	    je searchNextValueRight

	    jmp loopSearchWallRigth

	    searchWallLeft:
	        pop AX
	        push AX

	    loopSearchWallLeft:
	        dec AX
	        call GetMapObject

            cmp DL, 00
            jne returnValue

            cmp AX, 00 
            je searchNextValueLeft
            jmp loopSearchWallLeft

	returnValue:
	    pop AX
	    jmp insertNewDot

	searchNextValueBelow:
	    pop CX
	    jmp searchNextValue
	searchNextValueAbove:
	    pop CX
	    jmp searchNextValue
	searchNextValueRight:
	    pop AX
	    jmp searchNextValue
	searchNextValueLeft:
	    pop AX
	    jmp searchNextValue

	insertNewDot:
	    mov DH, 13h
	    call InsertMapObject
	    add totalDots, 01
	searchNextValue:
	    inc AX
	    cmp AX, 27h
	    jne getRowValue
        inc CX
        cmp CX, 17
        mov AX, 01
        jne getRowValue

    ;; Reservamos el espacio de los fantasmas
    mov CX, 09h
    mov DH, 00
    ghostRow:
        mov AX, 13h
    
    ghostCol:
        sub totalDots, 01h
        call InsertMapObject
        inc AX
        cmp AX, 16h
        jne ghostCol

        inc CX
        cmp CX, 0Ch
        jne ghostRow 
    
    mov CX, 08h
    mov AX, 14h
    mov DH, 00
    call InsertMapObject
    sub totalDots, 01h
    
    ret
FillWithDots ENDP

;---------------------------------------------------------
; GenerateRandomNum
;
; Descripción:
; Genera un número aleatorio entre 0 y 3
;
; Recibe:
; -
;
; Retorna:
; 
;---------------------------------------------------------
GenerateRandomNum PROC USES AX BX CX DX DS
    mov BH, 0                       ;; Donde empieza el rango
    mov BL, 04h                     ;; El tamaño del rango, en este caso, desde 0, 1, 2, 3

    call DoRangedRandom
    mov byte ptr randomNumber, AL
    ret
GenerateRandomNum ENDP

;---------------------------------------------------------
; DoRandomByte1
;
; Descripción:
; Desplaza aleatoriamente los bytes
;
; Recibe:
; -
;
; Retorna:
; AL con un byte random
;---------------------------------------------------------

DoRandomByte1 PROC
    mov AL, CL
    DoRandomByte1b:
        ror AL, 1
        ror AL, 1
        xor AL, CL
        ror AL, 1
        ror AL, 1
        xor AL, CH
        ror AL, 1
        xor AL, 9Dh             ;; 157 decimal
        xor AL, CL
    ret
DoRandomByte1 ENDP

;---------------------------------------------------------
; DoRandomByte2
;
; Descripción:
; Genera un byte aleatorio 
;
; Recibe:
; -
;
; Retorna:
; -
;---------------------------------------------------------

DoRandomByte2 PROC
    mov BX, offset Randoms1     ;; Se dirige a la tabla de números randoms
    mov AH, 00
    mov AL, CH
    xor AL, 0Bh                 ;; 11 decimal
    and AL, 0Fh                 ;; 15 decimal

    mov SI, AX
    mov DH, [BX+SI]

    call DoRandomByte1
    and AL, 0Fh

    mov BX, offset Randoms2
    mov SI, AX
    mov AL, [BX+SI]
    
    xor AL, DH
    ret
DoRandomByte2 ENDP

;---------------------------------------------------------
; DoRandom
;
; Descripción:
; Guarda el seed para el número random
;
; Recibe:
; -
;
; Retorna:
; -
;---------------------------------------------------------

DoRandom PROC USES BX CX DX
    mov CX, word PTR [ds:randomSeed]
    inc CX
    mov word PTR [ds:randomSeed], CX
    call DoRandomWord
    mov AL, DL
    xor AL, DH
    ret
DoRandom ENDP

;---------------------------------------------------------
; DoRandomWord
;
; Descripción:
; Genera a partir de procedures como DoRandomByte1/2
;
; Recibe:
; -
;
; Retorna:
; CX -> JC
;---------------------------------------------------------

DoRandomWord PROC
    call DoRandomByte1
    mov DH, AL
    push DX
    push CX
    push BX
        call DoRandomByte2
    pop BX
    pop CX
    pop DX
    mov DL, AL
    inc CX
    ret
DoRandomWord ENDP

;---------------------------------------------------------
; DoRangedRandom
;
; Descripción:
; Genera el numero aleatorio
;
; Recibe:
; -
;
; Retorna:
; AL ->  Numero aleatorio de 8 bits
;---------------------------------------------------------

DoRangedRandom:
    call DoRandom

    cmp AL, BH
    jc DoRangedRandom
    cmp AL, BL
    jnc DoRangedRandom
    ret


;---------------------------------------------------------
; PrintTemporizer
;
; Descripción:
; Muestra el temporizador de 12 segundos si es necesario
;
; Recibe:
; Descripción de los registros de entrada
;
; Retorna:
; Descripción de los registros de salida
;---------------------------------------------------------
PrintTemporizer PROC USES AX BX CX DX SI
    mov AH, 02				;;
	mov DH, 18h				;;	fila
	mov DL, 00				;;	columna
	mov BH, 00				;;
	int 10

    xor CX, CX
    mov CL, temporizerTime
    mov numberGotten, CX
    call NumToStr
    lea SI, recoveredStr
    add SI, 05

    mPrintPartialDirection SI
	
    ret
PrintTemporizer ENDP


;---------------------------------------------------------
; CalculateTemporizer
;
; Descripción:
; Calcula el temporizador   
;
; Recibe:
;
; Retorna:
;---------------------------------------------------------
CalculateTemporizer PROC USES AX CX DX
    mov AH, 2ch
    int 21h
    cmp DH, previousSecond
    je   endProc
    
    decrementTime:
        mov previousSecond, DH
        sub temporizerTime, 01h
        call PrintTemporizer

        cmp temporizerTime, 00
        jne endProc
        mov isGhostBlue, 00
    endProc:
    ret
CalculateTemporizer ENDP