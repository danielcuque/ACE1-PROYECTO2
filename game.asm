mGameVars macro
    
endm


mStartGame macro 
    call CreateMap
    call InsertMapObject
    call PrintAceman
    mWaitEnter
endm

;---------------------------------------------------------
; Descripción:
; Crea un mapa quemado con finalidad de test, quitar al final
;---------------------------------------------------------

CreateMap PROC
    mov AX, 0000
		mov CX, 0001
		mov DH, 01                ;; código del objeto
		call InsertMapObject
		mov AX, 0012
		mov CX, 0001
		mov DH, 02
		call InsertMapObject
		mov AX, 0000
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
		mov DH, 0e
		call InsertMapObject
		mov DH, 04
		mov AX, 0001
		mov CX, 0001
		xchg CX, BX
		mov CX, 11
CreateMap ENDP

PrintMapObject PROC
    pintar_mapa_objetos:
		mov AX, 0000
		mov CX, 0000
		mov DI, offset tableGame
;;(ciclo-exterior
		xchg CX, SI
		mov CX, 19
objetos_filas:	mov AX, 0000
		push CX
		xchg CX, SI
;;  (ciclo-interior
		xchg CX, BX
		mov CX, 28
objetos_cols:	push CX
		xchg CX, BX
		call GetMapObject
		mov DI, offset wallType1
		cmp DL, 01
		je pintar_obj
		mov DI, offset wallType2
		cmp DL, 02
		je pintar_obj
		mov DI, offset wallType3
		cmp DL, 03
		je pintar_obj
		mov DI, offset wallType4
		cmp DL, 04
		je pintar_obj
		mov DI, offset wallType5
		cmp DL, 0e
		je pintar_obj
		mov DI, offset wallType6
		cmp DL, 0f
		je pintar_obj
		jmp loop_cols
pintar_obj:	push AX
		push CX
		call PrintSprite
		pop CX
		pop AX
loop_cols:	inc AX
		xchg CX, BX
		pop CX
		loop objetos_cols
;;  )
		xchg CX, BX
		inc CX
		xchg CX, SI
		pop CX
		loop objetos_filas
;;)
retornar_pintar_mapa:
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