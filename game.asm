mStartGame macro 
	mPrintMsg testStr
    call CreateMap
    call PrintMapObject    
	ciclo:
		call PrintAceman
		call ChangeAcemanDirection
		call MoveAceman
		jmp ciclo
endm

;---------------------------------------------------------
; Descripción:
; Crear un mapa quemado con finalidad de test, quitar al final
;---------------------------------------------------------

CreateMap PROC
		mov AX, 0000			; X
		mov CX, 0001			; Y
		mov DH, 01              ; Codigo  
		call InsertMapObject
		mov AX, 0012
		mov CX, 0001
		mov DH, 02
		call InsertMapObject
		mov AX, 0011
		mov CX, 0001
		mov DH, 03
		call InsertMapObject
		mov AX, 0013
		mov CX, 0001
		mov DH, 04
		call InsertMapObject
		mov AX, 0014
		mov CX, 0001
		mov DH, 05
		call InsertMapObject
		mov AX, 0015
		mov CX, 0001
		mov DH, 06
		call InsertMapObject
		mov AX, 0016
		mov CX, 0001
		mov DH, 07
		call InsertMapObject
		mov AX, 0017
		mov CX, 0001
		mov DH, 08
		call InsertMapObject
		mov AX, 0018
		mov CX, 0001
		mov DH, 09
		call InsertMapObject
		mov AX, 0001
		mov CX, 0017
		mov DH, 0a
		call InsertMapObject
		mov AX, 0002
		mov CX, 0017
		mov DH, 0b
		call InsertMapObject
		mov AX, 0003
		mov CX, 0017
		mov DH, 0c
		call InsertMapObject
		mov AX, 0004
		mov CX, 0017
		mov DH, 0d
		call InsertMapObject
		mov AX, 0005
		mov CX, 0017
		mov DH, 0e
		call InsertMapObject
		mov AX, 0012
		mov CX, 0017
		mov DH, 0f
		call InsertMapObject
		mov AX, 000a
		mov CX, 0009
		mov DH, 01
		call InsertMapObject
		mov AX, 000a
		mov CX, 000f
		mov DH, 0e
		call InsertMapObject
		mov AX, 0002
		mov CX, 0003
		mov DH, 01
		call InsertMapObject
		mov AX, 0002
		mov CX, 0015
		mov DH, 13h
		call InsertMapObject
		mov AX, 0005
		mov CX, 0015
		mov DH, 14h
		call InsertMapObject
		mov AX, 0006
		mov CX, 0015
		mov DH, 15h
		call InsertMapObject
		mov DH, 04
		mov AX, 0001
		mov CX, 0001
		xchg CX, BX
		mov CX, 11
		ret
CreateMap ENDP


PrintMapObject PROC
    start:
		mov CX, 0h					;; Dejamos el numero de columna en 0
	printRow:
		mov AX, 0h					;; Cada vez que se pinte una fila, la pos X regresa a 0

	printCol:
		call GetMapObject
		cmp DL, 0Fh
		jg isNotWall

		push AX
			mov DI, offset wallSprite		;; Nuestro sprites de muros va a seguir la misma logica que el del pacman
											;; Hacemos offset en el sprite de muros para que empieze en el primer tipo de wall que es un vacío
											;; Luego dependiendo de lo que venga en el mapa, se hace offset + 64*tipo para acceder al tipo de muro
			mov AX, DX						;; En DL, está almacenado el valor del tipo de muro que es
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
; AX -> X + 1 del aceman
; CX -> Y + 1 del aceman
;
; Retorna:
; DL -> Valor del objeto (wall, acedot, powerdot)
;---------------------------------------------------------


GetMapObject PROC USES AX CX
    mov DI, offset tableGame
    mov DL, 28          ;; Hacer y_futura * 40d
    xchg AX, CX
    mul DL
    xchg AX, CX
    add DI, AX          ;; Hacer row major: offset + x_futura + y_futura * 40d
    add DI, CX
    mov DL, [DI]
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
	mov DH, currentAcemanDirection	;; Preguntamos la direccion que tiene el aceman (der, izq, etc)

	checkBelow:
		cmp DH, belowKey				;; Comparamos si va hacia abajo
		jne checkAbove					;; Si no es igual, entonces chequeamos el resto de direcciones
		inc CX							;; Incrementamos la posición siguiente para poder obtener el objeto que le sigue al aceman
		call GetMapObject				;; Obtenemos ese objeto a través de la pos AX, CX
		cmp DL, 01						;; Si no es un muro, entonces avanzamos
		jb makeBelowMove
		
		cmp DL, maxWall
		ja makeBelowMove				;; También necesitamos comparar si llegó al límite de las paredes
		dec CX							;; Si llegó, entonces no avanzamos y retornamos la función
		ret
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
		cmp DL, maxWall
		ja makeAboveMove
		inc CX							
		ret
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
		cmp DL, maxWall
		ja makeRightMove
		dec AX
		ret
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
		cmp DL, maxWall
		ja makeLeftMove
		inc AX
		ret
	makeLeftMove:
		mov aceman_x, AX
	endProc:
		ret
MoveAceman ENDP