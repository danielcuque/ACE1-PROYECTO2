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

EmptyScreen PROC
    mPrintMsg infoMsg
    mWaitEnter
    ret
EmptyScreen ENDP

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

mPrintGhots macro x_pos, y_pos, ghost
	LOCAL print, printGhostBlue
	mov AX, x_pos
	mov CX, y_pos

	cmp isGhostBlue, 00
	jne printGhostBlue

	mov DI, offset ghost
	jmp print

	printGhostBlue:
		mov DI, offset GhostBlue
	print:
		call PrintSprite
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
PrintSprite PROC USES AX CX
    
	mov BX, 0h					;; Limpiamos al registro BX
	mov DL, 08h					;; Cargamos a DL 8
	mul DL						;; Multiplicamos Posx * 8 para hacer row major con la matriz de pixeles
	add BX, AX					;; 
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


IsNumber PROC
	
IsNumber ENDP

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
; recoveredStr
;
; Retorna:
; numberGotten
;---------------------------------------------------------
StrToNum PROC
	
	ret
StrToNum ENDP

mPrintNumberConverted macro
    call NumToStr
	call ResetPointer
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
		mPrintNumberConverted
		mov numberGotten, 00
	pop AX
endm

