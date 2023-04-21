;---------------------------------------------------------
; PrintHealthAceman
;
; Descripción:
; Muestra la cantidad de vida que tiene el aceman
;
; Recibe:
; -
;
; Retorna:
; -
;---------------------------------------------------------
PrintHealthAceman PROC USES AX BX CX DX DI
	mov DL, healthAceman			;; Imprimimos n veces, donde n es al cantidad de vidas que le quedan al aceman
	mov AX, 25h		
	mov CX, 18h
	mov DI, offset HeartSprite
	
	paintHearts:
		call PrintSprite
		inc AX
		dec DL
		jnz paintHearts
	ret
PrintHealthAceman ENDP

mStartGame macro 

	push DX
        mov DX, offset fileName1		;; Leemos el nivel 1 del juego
        call ReadFile
    pop DX

	mSetCurrentTime						;; Guardamos el tiempo inicial
	
    call PrintMapObject    				;; Pintamos el mapa
	call PrintHealthAceman				;; Mostramos la vida del aceman

	mPrintTotalPoints					;; Mostramos los puntos iniciales
	
	mPrintAllGhots						;; Mostramos todos los fantasmas

	continueGame:
		call CalculateTime				;; Mostramos el tiempo en cada iteracion
		call PrintAceman				;; Mostramos el pacman en cada iteracion
		call ChangeAcemanDirection		;; Solicitamos mover al aceman
		call MoveAceman					;; Calculamos la nueva posición

		cmp totalDots, 0h				;; Si el total de dots es 0, se termina el juego
		je endGameSuccess				;; Saltamos al final si se acabaron los dots

		cmp healthAceman, 0h			;; Si se le acabaron las vidas a Aceman, termina el juego
		je endGameSuccess

		jmp continueGame
	endGameSuccess:
	
endm

PrintMapObject PROC
		mov CX, 0h							;; Dejamos el numero de columna en 0
		mov DI, offset tableGame
	printRow:
		mov AX, 0h							;; Cada vez que se pinte una fila, la pos X regresa a 0

	printCol:
		call GetMapObject
		cmp DL, 0Fh
		jg isNotWall

		push AX
			xor AX, AX
			mov DI, offset wallSprite		;; Nuestro sprites de muros va a seguir la misma logica que el del pacman
											;; Hacemos offset en el sprite de muros para que empieze en el primer tipo de wall que es un vacío
											;; Luego dependiendo de lo que venga en el mapa, se hace offset + 64*tipo para acceder al tipo de muro
			mov AL, DL						;; En DL, está almacenado el valor del tipo de muro que es
			mov BX, 40h						;; Cargamos a BX con 40h/64d
			mul BX							;; Multiplicamos tipo * 40
			add DI, AX						;; Nos posicionamos en el sprite deseado
		pop AX

		jmp printObject

		isNotWall:
			mov DI, offset AceDot			;; Luego validamos el resto de objetos que pueden existir en el juego
			cmp DL, 13h
			je printObject

			mov DI, offset PowerDot
			cmp DL, 14h
			je printObject

			mov DI, offset PortalSprite
			cmp DL, 15h
			jge printObject

			jmp skipObject

	printObject:
		
		call PrintSprite
	
	skipObject:
		inc AX
		cmp AX, 28h					;; Comparamos si llegamos a la ultima fila
		jne printCol				;; Si no llegamos, seguimos iterando

		inc CX						
		cmp CX, 19h					;; Comparamos si llegamos a la última fila
		jne printRow	
		ret
PrintMapObject ENDP

;---------------------------------------------------------
; InsertMapObject
;
; Descripción:
; Pinta objetos en el mapa del juego
; Row major -> posX * nFilas + posY
;
; Recibe:
; AX -> Pos X del objeto
; CX -> Pos Y del objeto
; DH -> Tipo de objeto a pintar
;
; Retorna:
; -
;---------------------------------------------------------

InsertMapObject PROC USES AX CX
    mov DI, offset tableGame            ;; Obtenemos la posición de memoria del tablero a pintar
    mov DL, 28h                         ;; Cargamos 28h/40d a DL para calcular row major

    xchg AX, CX                         ;; Intercambiamos el valor de las posiciones para hacer la multiplicación
                                        ;; Ahora la posición Y está en AX y viceversa
                                        ;; Esto con la finalidad de obtener la multiplcación, ya que el resultado se almacena en AX
    mul DL                              ;; En DL ya está el número de filas (Y * 40 filas)

    xchg AX, CX                         ;; Ahora tenemos cargamos nuevamente el valor de la pos X en AX

    add DI, AX                          ;; Ahora sumamos numero de la pos X
    add DI, CX                          ;; Sumamos el valor de 40 * Y

    mov [DI], DH                        ;; Insertamos el objeto que se encuentra en DH
    ret
InsertMapObject ENDP

;---------------------------------------------------------
; GetMapObject
;
; Descripción:
; Obtiene el valor que se encuentra dentro del tablero de juego
;
; Recibe:
; AX -> X + 1 del objeto
; CX -> Y + 1 del objeto
;
; Retorna:
; DL -> Valor del objeto (wall, acedot, powerdot)
;---------------------------------------------------------


GetMapObject PROC USES AX CX
    mov DI, offset tableGame	;; Obtenemos la dirección de memoria donde se almacena todo
    mov DL, 28h          		;; Hacer y_futura * 40d
    xchg AX, CX					;; Primero calculamos la posición Y que está en CX
    mul DL
    xchg AX, CX					;; Ahora regresamos el valor a CX que estaba como resultado de la multiplicacion
    add DI, AX          		;; Hacer row major: offset + x_futura + y_futura * 40d
    add DI, CX
    mov DL, [DI]				;; Cargamos ese valor en DL
    ret
GetMapObject ENDP

;---------------------------------------------------------
; MoveAceman
;
; Descripción:
; Mueve el aceman a través del tablero si es posible
;
; Recibe:
; AX ->  X actual del aceman
; CX ->  Y actual del aceman
;
; Retorna:
; AX -> Nueva pos X del aceman
; CX -> Nueva pos Y del aceman
; var aceman_x -> nueva pos x del aceman
; var aceman_y ->  nueva pos y del aceman
;---------------------------------------------------------

MoveAceman PROC
	mov DH, currentAcemanDirection		;; Preguntamos la direccion que tiene el aceman (der, izq, etc)

	checkBelow:
		cmp DH, belowKey				;; Comparamos si va hacia abajo
		jne checkAbove					;; Si no es igual, entonces chequeamos el resto de direcciones

		inc CX							;; Incrementamos la posición siguiente para poder obtener el objeto que le sigue al aceman

		call GetMapObject				;; Obtenemos ese objeto a través de la pos AX, CX

		cmp DL, 01						;; Si no es un muro, entonces avanzamos
		jb makeBelowMove

		cmp DL, 13h
		je addAceDotPointsBelow

		cmp DL, 14h
		je addPowerDotPointsBelow
		
		cmp DL, maxWall
		ja makeBelowMove				;; También necesitamos comparar si llegó al límite de las paredes
		dec CX							;; Si llegó, entonces no avanzamos y retornamos la función
		ret
	addAceDotPointsBelow:
		call SumAceDotPoints
		jmp deleteDotBelow

	addPowerDotPointsBelow:
		call SumPowerDotPoints

	deleteDotBelow:
		push DX
			mov DL, 00
			call InsertMapObject
		pop DX
	makeBelowMove:
		mov aceman_y, CX				;; Cargamos la nueva posición en Y
		ret
	checkAbove:
		cmp DH, aboveKey
		jne checkRight

		dec CX							;; Para ir hacia arriba, necesitamos decrementar la pos Y

		call GetMapObject

		cmp DL, 01
		jb makeAboveMove
		
		cmp DL, 13h
		je addAceDotPointsAbove

		cmp DL, 14h
		je addPowerDotPointsAbove

		
		cmp DL, maxWall
		ja makeAboveMove
		inc CX							
		ret
	addAceDotPointsAbove:
		call SumAceDotPoints
		jmp deleteDotBelow

	addPowerDotPointsAbove:
		call SumPowerDotPoints

	deleteDotAbove:
		push DX
			mov DL, 00
			call InsertMapObject
		pop DX

	makeAboveMove:
		mov aceman_y, CX
		ret
	checkRight:

		cmp DH, rightKey
		jne checkLeft

		inc AX

		call GetMapObject

		cmp DL, 01
		jb makeRightMove

		cmp DL, 13h
		je addAceDotPointsRight

		cmp DL, 14h
		je addPowerDotPointsRight

		cmp DL, maxWall
		ja makeRightMove
		dec AX
		ret
	addAceDotPointsRight:
		call SumAceDotPoints
		jmp deleteDotRight
	addPowerDotPointsRight:
		call SumPowerDotPoints
		
	deleteDotRight:
		push DX
			mov DL, 00
			call InsertMapObject
		pop DX

	makeRightMove:
		mov aceman_x, AX
		ret

	checkLeft:
		cmp DH, leftKey
		jne endProc

		dec AX

		call GetMapObject

		cmp DL, 01
		jb makeLeftMove

		cmp DL, 13h
		je addAceDotPointsLeft

		cmp DL, 14h
		je addPowerDotPointsLeft

		cmp DL, maxWall
		ja makeLeftMove
		inc AX
		ret
	addAceDotPointsLeft:
		call SumAceDotPoints
		jmp deleteDotLeft

	addPowerDotPointsLeft:
		call SumPowerDotPoints

	deleteDotLeft:
		push DX
			mov DL, 00
			call InsertMapObject
		pop DX

	makeLeftMove:
		mov aceman_x, AX
	endProc:
		ret
MoveAceman ENDP

;---------------------------------------------------------
; ChangeAcemanDirection
;
; Descripción:
; Obtiene el valor que se ingresa por teclado
;
; Recibe:
; -
;
; Retorna:
; Cambio de direcciones
;---------------------------------------------------------
ChangeAcemanDirection PROC USES AX CX
	mov AH, 01									;; Generamos la interrupción para obtener entradas del teclado
	int 16h

	jz endProc									;; Si la bandera de carry es zero entonces retornamos

	cmp AH, 48h									;; 48h es para la tecla de arriba
	je aboveMove

	cmp AH, 50h
	je belowMove

	cmp AH, 4Bh
	je leftMove

	cmp AH, 4Dh
	je rigthMove
	jmp emptyBuffer


	aboveMove:
		mov AH, 00
		int 16h
		mov currentAcemanDirection, aboveKey
		mov dir_sprite_aceman, aboveKey
		jmp endProc

	belowMove:
		mov AH, 00
		int 16h
		mov currentAcemanDirection, belowKey
		mov dir_sprite_aceman, belowKey
		jmp endProc
	leftMove:	
		mov AH, 00
		int 16h
		mov currentAcemanDirection, leftKey
		mov dir_sprite_aceman, leftKey
		jmp endProc
	rigthMove:
		mov AH, 00
		int 16h
		mov currentAcemanDirection, rightKey
		mov dir_sprite_aceman, rightKey
		jmp endProc

	emptyBuffer:
		mov AH, 00
		int 16
	endProc:
		ret
ChangeAcemanDirection ENDP

;---------------------------------------------------------
; SumAceDotPoints
;
; Descripción:
; Hace la operación de sumar el valor de los aceDots al puntaje total
;
; Recibe:
; totalPoints -> puntaje total
; aceDotsPoints ->  valor del puntaje de los acedots
;
; Retorna:
; -
;---------------------------------------------------------

SumAceDotPoints PROC USES BX
	mov BX, 00					;; Limpiamos BX
	mov BX, totalPoints			;; El valor del puntaje se cambia a BX
	add BX, aceDotPoints		;; Le sumo a BX el valor del puntaje de los acedots
	xchg BX, totalPoints		;; Devuelvo el valor a la variable de puntaje total
	mPrintTotalPoints			;; Imprimo el puntaje nuevamente
	sub totalDots, 01h
	ret
SumAceDotPoints ENDP

;---------------------------------------------------------
; SumPowerDotPoints
;
; Descripción:
; Calcula el valor de los Power Dots en base a los acedots
;
; Recibe:
; totalPoints -> puntaje total
;
; Retorna:
; -
;---------------------------------------------------------
SumPowerDotPoints PROC USES AX BX
	mov AX, 00h
	mov BX, 00h

	mov AX, aceDotPoints

	mov BX, 05h
	mul BX
	add totalPoints, AX

	mPrintTotalPoints			;; Imprimo el puntaje nuevamente
	sub totalDots, 01h
	ret
SumPowerDotPoints ENDP

MoveGhost PROC
	
MoveGhost ENDP