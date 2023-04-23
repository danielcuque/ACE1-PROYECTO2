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
	mov AX, 25h						;; 37 decimal
	mov CX, 18h						;; 24 decimal
	mov DI, offset HeartSprite
	
	paintHearts:
		call PrintSprite
		inc AX
		dec DL
		jnz paintHearts
	ret
PrintHealthAceman ENDP

;---------------------------------------------------------
; mStartGame
;
; Descripción:
; Lleva la secuencia del juego
;
; Recibe:
; -
;
; Retorna:
; -
;---------------------------------------------------------

mStartGame macro 	
    mov DX, offset fileName1			;; Leemos el nivel 1 del juego
    call ReadFile

	call PrintInitialInformation		;; Mostramos la información acerca de los dots, fantasmas, etc
	mWaitEnter

	call FillWithDots					;; Rellena los espacios vacios en el mapa con dots normales
	
    call PrintMapObject    				;; Pintamos el mapa
	call PrintHealthAceman				;; Mostramos la vida del aceman
	call PrintTemporizer

	mPrintTotalPoints					;; Mostramos los puntos iniciales

	mSetCurrentTime						;; Guardamos el tiempo inicial
	
	continueGame:
		call CalculateTime				;; Mostramos el tiempo en cada iteracion
		
		call PrintAceman				;; Mostramos el pacman en cada iteracion
		call ChangeAcemanDirection		;; Solicitamos mover al aceman
		call MoveAceman					;; Calculamos la nueva posición
		
		; mPrintAllGhots				    ;; Mostramos todos los fantasmas
		call MoveGhostCyan
		call MoveGhostRed
		call MoveGhostOrange
		call MoveGhostMagenta

		cmp totalDots, 0h				;; Si el total de dots es 0, se termina el juego
		je endGameSuccess				;; Saltamos al final si se acabaron los dots

		cmp temporizerTime, 00
		je continueSequence
		call CalculateTemporizer

		continueSequence:

		cmp healthAceman, 0h			;; Si se le acabaron las vidas a Aceman, termina el juego
		je endGameSuccess

		cmp isBackMenu, 00
		jne menuProgram

		jmp continueGame
	endGameSuccess:
	
endm

;---------------------------------------------------------
; PrintMapObject
;
; Descripción:
; Pinta el mapa en el que se va a jugar el nivel
;
; Recibe:
; _
;
; Retorna:
; _
;---------------------------------------------------------

PrintMapObject PROC USES AX BX CX DX DI
		mov CX, 0h							;; Dejamos el numero de columna en 0
		mov DI, offset tableGame
	printRow:
		mov AX, 0h							;; Cada vez que se pinte una fila, la pos X regresa a 0

	printCol:
		call GetMapObject
		cmp DL, 0Fh							;; 15 decimal
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
			cmp DL, 13h						;; 19 decimal
			je printObject

			mov DI, offset PowerDot
			cmp DL, 14h						;; 20 decimal
			je printObject

			mov DI, offset PortalSprite
			cmp DL, 15h						;; 21 decimal
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
; SearchPortalPosition
;
; Descripción:
; Busca la pareja del portal para poder cambiar la posición
;
; Recibe:
; CX -> Posición Y actual del portal
; AX -> Posición X actual del portal
; DL -> ID del portal
;
; Retorna:
; CX -> Pos Y de la pareja
; AX -> Pos X de la pareja
;---------------------------------------------------------

SearchPortalPosition PROC USES DI
	mov DI, offset tableGame				;; Obtenemos la direccion de memoria del tablero para poder recorrerlo
	mov DH, DL								;; Movemos temporalmente el valor de DL con el ID a DH
	mov auxiliarX, AX						;; Guardamos temporalmente el valor de AX Y CX para poder evaluar
	mov auxiliarY, CX

	xor AX, AX								;; Limpiamos los registros
	xor CX, CX

	printRow:
		mov AX, 0h							;; Empezamos desde la línea 0

	printCol:
		call GetMapObject					;; Obtenemos el objeto dentro del mapa en la posición actual
		cmp DL, DH							;; Comparamos el ID del objeto, y buscamos que sea el mismo ID
		je verifyPositionY					;; Si es igual, entonces verificamos las posiciones para que no sea el mismo portal
		jmp continueLoop					;; Si no es, entonces continuamos el loop

		;; Para los portales horizontales, el eje Y puede ser igual
		;; Para los verticales, el eje X puede ser igual

		verifyPositionY:
			cmp CX, auxiliarY				;; Guardamos la posición anterior y miramos si son las mismas
			je verifyPositionX				;; Si la posición en Y es la misma, entonces verificamos que el eje X no sea igual
			jmp secondVerifyX				;; Si no son iguales, puede ser que sea un portal vertical		 
		
		verifyPositionX:
			cmp AX, auxiliarX				;; Si el eje X es igual, y el Y también, quiere decir que es el mismo portal y lo saltamos
			je continueLoop					
			jmp changeDirection				;; De lo contrario, entonces cambiamos la dirección
		
		secondVerifyX:	
			cmp AX, auxiliarX				;; Si el eje X no es igual, entonces lo saltamos
			jne continueLoop				
		
		secondVerifyY:
			cmp CX, auxiliarY				;; Si el eje Y es igual, entonces lo saltamos
			je continueLoop	
			jmp changeDirection				;; De lo contrario lo saltamos

		continueLoop:
			inc AX
			cmp AX, 28h						;; Comparamos si llegamos a la ultima fila
			jne printCol					;; Si no llegamos, seguimos iterando

			inc CX						
			cmp CX, 19h						;; Comparamos si llegamos a la última fila
			jne printRow
		jmp setNewCoordinate
	changeDirection:
		cmp AX, 00
		je rigthMove

		cmp AX, 27h
		je leftMove

		cmp CX, 01h
		je belowMove

		cmp CX, 19h
		je aboveMove

	aboveMove:
		dec CX
		jmp setNewCoordinate
	belowMove:
		inc CX
		jmp setNewCoordinate
	leftMove:
		dec AX	
		jmp setNewCoordinate
	rigthMove:
		inc AX
		jmp setNewCoordinate
	setNewCoordinate:	
	ret
SearchPortalPosition ENDP

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

		cmp DL, 15h
		jge movePortal
		
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
		mov DL, 00
		call InsertMapObject
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

		cmp DL, 15h
		jge movePortal
		
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
		mov DL, 00
		call InsertMapObject

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

		cmp DL, 15h
		jge movePortal

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
		mov DL, 00
		call InsertMapObject

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

		cmp DL, 15h
		jge movePortal

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
		mov DL, 00
		call InsertMapObject

	makeLeftMove:
		mov aceman_x, AX
		jmp endProc
	movePortal:
		call SearchPortalPosition
		mov aceman_x, AX
		mov aceman_y, CX
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
; Juego pausado si es necesario
;---------------------------------------------------------
ChangeAcemanDirection PROC USES AX CX
	mov AH, 01									;; Generamos la interrupción para obtener entradas del teclado
	int 16h

	jz endProc									;; Si la bandera de carry es zero entonces retornamos

	cmp AH, 48h									;; 48h es para la tecla de arriba
	je aboveMove

	cmp AH, 50h									;; Tecla abajo
	je belowMove

	cmp AH, 4Bh									;; Tecla izquierda
	je leftMove

	cmp AH, 4Dh									;; Tecla derecha
	je rigthMove

	cmp AH, 01h									;; Tecla ESC
	je pauseGame

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
	
	pauseGame:
		mov AH, 00
		int 16h

		call EmptyScreen
		call PrintInitialInformation
		call PauseMenu
		
		cmp isBackMenu, 00
		jne endProc

		call PrintMapObject
		mPrintTotalPoints
		call PrintHealthAceman
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
SumPowerDotPoints PROC
	push AX
	push BX
	push CX

	mov AX, 00h
	mov BX, 00h

	mov AX, aceDotPoints

	mov BX, 05h
	mul BX
	add totalPoints, AX
	mov isGhostBlue, 01
	mPrintTotalPoints			;; Imprimo el puntaje nuevamente
	sub totalDots, 01h

	;; Colocamos el contador
	mov temporizerTime, 0Ch		;; Colocamos 12s nuevamente

	pop CX
	pop BX
	pop AX

	ret
SumPowerDotPoints ENDP

;---------------------------------------------------------
; PrintInitialInformation
;
; Descripción:
; Imprime la información principal del juego
;
; Recibe:
; -
;
; Retorna:
; -
;---------------------------------------------------------
PrintInitialInformation PROC USES AX BX CX DX DI
	mov AX, 1h					;; Fila 1
	mov CX, 1h					;; Columna 1
	mov DI, offset AceDot
	call PrintSprite
	
	mov AH, 02				;;
	mov DH, 1h				;;	fila
	mov DL, 3h				;;	columna
	mov BH, 00				;;
	int 10

	mov BX, aceDotPoints
	mov numberGotten, BX
	mPrintNumberConverted

	mov AX, 1h					;; Fila 1
	mov CX, 2h					;; Columna 1
	mov DI, offset PowerDot
	call PrintSprite

	mov AH, 02				;;
	mov DH, 2h				;;	fila
	mov DL, 3h				;;	columna
	mov BH, 00				;;
	int 10

	mov AX, 05h
	mov BX, aceDotPoints
	mul BX
	mov numberGotten, AX
	mPrintNumberConverted

	mov AX, 1h					;; Fila 1
	mov CX, 3h					;; Columna 1
	mov DI, offset CoinSprite
	call PrintSprite

	mov AH, 02				;;
	mov DH, 3h				;;	fila
	mov DL, 3h				;;	columna
	mov BH, 00				;;
	int 10

	mov AX, totalPoints
	mov numberGotten, AX
	mPrintNumberConverted

	mov AX, 1h					;; Fila 1
	mov CX, 4h					;; Columna 1
	mov DI, offset GhostCyan
	call PrintSprite

	mov AH, 02				;;
	mov DH, 4h				;;	fila
	mov DL, 3h				;;	columna
	mov BH, 00				;;
	int 10

	mov AX, ghostPoints
	mov numberGotten, AX
	mPrintNumberConverted

	mov AX, 1h					;; Fila 1
	mov CX, 5h					;; Columna 1
	mov DI, offset HeartSprite
	call PrintSprite

	mov AH, 02				;;
	mov DH, 5h				;;	fila
	mov DL, 3h				;;	columna
	mov BH, 00				;;
	int 10

	xor AX, AX
	mov AL, healthAceman
	mov numberGotten, AX
	mPrintNumberConverted

	mov AX, 1h					;; Fila 1
	mov CX, 6h					;; Columna 1
	mov DI, offset LevelSprite
	call PrintSprite

	mov AH, 02				;;
	mov DH, 6h				;;	fila
	mov DL, 3h				;;	columna
	mov BH, 00				;;
	int 10

	xor AX, AX
	mov AL, numberLevel
	mov numberGotten, AX
	mPrintNumberConverted

	mov AH, 02				;;
	mov DH, 09h				;;	fila
	mov DL, 1h				;;	columna
	mov BH, 00				;;
	int 10
	
	mPrintMsg JUGADORKW
	mPrintMsg currentPlayerName

	mov AH, 02				;;
	mov DH, 0Ah				;;	fila
	mov DL, 1h				;;	columna
	mov BH, 00				;;
	int 10

	mPrintMsg developerName
	ret
PrintInitialInformation ENDP

;---------------------------------------------------------
; MoveGhots
;
; Descripción:
; Mueve el fantasma dentro del tablero
;
; Recibe:
; -
;
; Retorna:
; -
;---------------------------------------------------------
MoveGhostCyan PROC USES AX BX CX DX

	mov AX, cyanGhost_x
	mov CX, cyanGhost_y

	call GenerateRandomNum
	
	cmp randomNumber, 00
	je makeLeftMove

	cmp randomNumber, 01
	je makeAboveMove

	cmp randomNumber, 02
	je makeRightMove

	makeBelowMove:
		inc CX

		call GetMapObject

		cmp DL, 01h				;; Si es objeto vacío, avanzamos
		jb isBelow

		cmp DL, 0Fh				;; Validamos que no se pase un muro
		ja isBelow

		cmp DL, maxWall
		ja isBelow
		dec CX
		ret

		isBelow:
			mov cyanGhost_y, CX
			dec CX
			call PrintOneObject
			mPrintGhots cyanGhost_x, cyanGhost_y, GhostCyan
			ret
	
	makeAboveMove:
		dec CX
		
		call GetMapObject

		cmp DL, 01
		jb isAbove

		cmp DL, 13h
		jge isAbove

		cmp DL, maxWall
		ja isAbove
		inc CX
		ret

		isAbove:
			mov cyanGhost_y, CX
			inc CX
			call PrintOneObject
			mPrintGhots cyanGhost_x, cyanGhost_y, GhostCyan
			ret 

	makeRightMove:
		inc AX

		call GetMapObject

		cmp DL, 01
		jb isRight

		cmp DL, 13h
		jge isRight

		cmp DL, maxWall
		ja isRight

		dec AX
		ret

		isRight:
			mov cyanGhost_x, AX
			dec AX
			call PrintOneObject
			mPrintGhots cyanGhost_x, cyanGhost_y, GhostCyan
			ret

	makeLeftMove:
		dec AX
		
		call GetMapObject

		cmp DL, 01
		jb isLeft

		cmp DL, 13h
		jge isLeft

		cmp DL, maxWall
		ja isLeft

		inc AX
		ret

		isLeft:
			mov cyanGhost_x, AX
			inc AX
			call PrintOneObject
			mPrintGhots cyanGhost_x, cyanGhost_y, GhostCyan
			ret
	endProc:
	ret
MoveGhostCyan ENDP


MoveGhostRed PROC USES AX BX CX DX

	mov AX, RedGhost_x
	mov CX, RedGhost_y

	call GenerateRandomNum
	
	cmp randomNumber, 00
	je makeLeftMove

	cmp randomNumber, 01
	je makeAboveMove

	cmp randomNumber, 02
	je makeRightMove

	makeBelowMove:
		inc CX

		call GetMapObject

		cmp DL, 01h				;; Si es objeto vacío, avanzamos
		jb isBelow

		cmp DL, 0Fh				;; Validamos que no se pase un muro
		ja isBelow

		cmp DL, maxWall
		ja isBelow
		dec CX
		ret

		isBelow:
			mov RedGhost_y, CX
			dec CX
			call PrintOneObject
			mPrintGhots RedGhost_x, RedGhost_y, GhostRed
			ret
	
	makeAboveMove:
		dec CX
		
		call GetMapObject

		cmp DL, 01
		jb isAbove

		cmp DL, 13h
		jge isAbove

		cmp DL, maxWall
		ja isAbove
		inc CX
		ret

		isAbove:
			mov RedGhost_y, CX
			inc CX
			call PrintOneObject
			mPrintGhots RedGhost_x, RedGhost_y, GhostRed
			ret 

	makeRightMove:
		inc AX

		call GetMapObject

		cmp DL, 01
		jb isRight

		cmp DL, 13h
		jge isRight

		cmp DL, maxWall
		ja isRight

		dec AX
		ret

		isRight:
			mov RedGhost_x, AX
			dec AX
			call PrintOneObject
			mPrintGhots RedGhost_x, RedGhost_y, GhostRed
			ret

	makeLeftMove:
		dec AX
		
		call GetMapObject

		cmp DL, 01
		jb isLeft

		cmp DL, 13h
		jge isLeft

		cmp DL, maxWall
		ja isLeft

		inc AX
		ret

		isLeft:
			mov RedGhost_x, AX
			inc AX
			call PrintOneObject
			mPrintGhots RedGhost_x, RedGhost_y, GhostRed
			ret
	endProc:
	ret
MoveGhostRed ENDP

MoveGhostOrange PROC USES AX BX CX DX

	mov AX, OrangeGhost_x
	mov CX, OrangeGhost_y

	call GenerateRandomNum
	
	cmp randomNumber, 00
	je makeLeftMove

	cmp randomNumber, 01
	je makeAboveMove

	cmp randomNumber, 02
	je makeRightMove

	makeBelowMove:
		inc CX

		call GetMapObject

		cmp DL, 01h				;; Si es objeto vacío, avanzamos
		jb isBelow

		cmp DL, 0Fh				;; Validamos que no se pase un muro
		ja isBelow

		cmp DL, maxWall
		ja isBelow
		dec CX
		ret

		isBelow:
			mov OrangeGhost_y, CX
			dec CX
			call PrintOneObject
			mPrintGhots OrangeGhost_x, OrangeGhost_y, GhostOrange
			ret
	
	makeAboveMove:
		dec CX
		
		call GetMapObject

		cmp DL, 01
		jb isAbove

		cmp DL, 13h
		jge isAbove

		cmp DL, maxWall
		ja isAbove
		inc CX
		ret

		isAbove:
			mov OrangeGhost_y, CX
			inc CX
			call PrintOneObject
			mPrintGhots OrangeGhost_x, OrangeGhost_y, GhostOrange
			ret 

	makeRightMove:
		inc AX

		call GetMapObject

		cmp DL, 01
		jb isRight

		cmp DL, 13h
		jge isRight

		cmp DL, maxWall
		ja isRight

		dec AX
		ret

		isRight:
			mov OrangeGhost_x, AX
			dec AX
			call PrintOneObject
			mPrintGhots OrangeGhost_x, OrangeGhost_y, GhostOrange
			ret

	makeLeftMove:
		dec AX
		
		call GetMapObject

		cmp DL, 01
		jb isLeft

		cmp DL, 13h
		jge isLeft

		cmp DL, maxWall
		ja isLeft

		inc AX
		ret

		isLeft:
			mov OrangeGhost_x, AX
			inc AX
			call PrintOneObject
			mPrintGhots OrangeGhost_x, OrangeGhost_y, GhostOrange
			ret
	endProc:
	ret
MoveGhostOrange ENDP

MoveGhostMagenta PROC USES AX BX CX DX

	mov AX, MagentaGhost_x
	mov CX, MagentaGhost_y

	call GenerateRandomNum
	
	cmp randomNumber, 00
	je makeLeftMove

	cmp randomNumber, 01
	je makeAboveMove

	cmp randomNumber, 02
	je makeRightMove

	makeBelowMove:
		inc CX

		call GetMapObject

		cmp DL, 01h				;; Si es objeto vacío, avanzamos
		jb isBelow

		cmp DL, 0Fh				;; Validamos que no se pase un muro
		ja isBelow

		cmp DL, maxWall
		ja isBelow
		dec CX
		ret

		isBelow:
			mov MagentaGhost_y, CX
			dec CX
			call PrintOneObject
			mPrintGhots MagentaGhost_x, MagentaGhost_y, GhostMagenta
			ret
	
	makeAboveMove:
		dec CX
		
		call GetMapObject

		cmp DL, 01
		jb isAbove

		cmp DL, 13h
		jge isAbove

		cmp DL, maxWall
		ja isAbove
		inc CX
		ret

		isAbove:
			mov MagentaGhost_y, CX
			inc CX
			call PrintOneObject
			mPrintGhots MagentaGhost_x, MagentaGhost_y, GhostMagenta
			ret 

	makeRightMove:
		inc AX

		call GetMapObject

		cmp DL, 01
		jb isRight

		cmp DL, 13h
		jge isRight

		cmp DL, maxWall
		ja isRight

		dec AX
		ret

		isRight:
			mov MagentaGhost_x, AX
			dec AX
			call PrintOneObject
			mPrintGhots MagentaGhost_x, MagentaGhost_y, GhostMagenta
			ret

	makeLeftMove:
		dec AX
		
		call GetMapObject

		cmp DL, 01
		jb isLeft

		cmp DL, 13h
		jge isLeft

		cmp DL, maxWall
		ja isLeft

		inc AX
		ret

		isLeft:
			mov MagentaGhost_x, AX
			inc AX
			call PrintOneObject
			mPrintGhots MagentaGhost_x, MagentaGhost_y, GhostMagenta
			ret
	endProc:
	ret
MoveGhostMagenta ENDP


;---------------------------------------------------------
; PrintOneObject
;
; Descripción:
; Pinta un solo objeto en el mapa
;
; Recibe:
; CX -> Pos Y
; AX -> Pos X
; DH -> ID del objeto
;
; Retorna:
; Descripción de los registros de salida
;---------------------------------------------------------

PrintOneObject PROC
	cmp DL, 0Fh							;; 15 decimal
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
		cmp DL, 13h						;; 19 decimal
		je printObject

		mov DI, offset PowerDot
		cmp DL, 14h						;; 20 decimal
		je printObject

		mov DI, offset PortalSprite
		cmp DL, 15h						;; 21 decimal
		jge printObject

		jmp skipObject

	printObject:
		
		call PrintSprite
	
	skipObject:
	ret
PrintOneObject ENDP