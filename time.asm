;; Procedures y macros para realizar el cronómetro

mSetCursorTime macro
	mov AH, 02				;;
	mov DH, 00				;;	fila
	mov DL, 20h				;;	columna
	mov BH, 00				;;
	int 10
endm

mDisplayTime macro timeNumber
    push BX
        mov BX, 0                       ;; Limpiamos BX
        mov numberGotten, BX            ;; Limpiamos numberGotten
        mov BX, timeNumber              ;; Obtenemos el numero del tiempo que se quiere mostrar
        mov numberGotten, BX            ;; Le pasamos ese valor a numberGotten
        call NumToStr                   ;; Lo convertimos a str        
        mov BX, offset recoveredStr     ;; Con el numero convertido a Str
        add BX, 05h                     ;; Solo mostramos los ultimas 2 dígitos
        mPrintPartialDirection BX       ;; Mostramos esa información parcial
    pop BX  
endm

;---------------------------------------------------------
; GetCurrentTime
;
; Descripción:
; Obtiene la hora actual del dispositivo y lo devuelve en centésimas
;
; Recibe:
; -
;
; Retorna:
; currentTime ->  Tiempo en centésimas
;---------------------------------------------------------

GetCurrentTime PROC USES AX BX CX DX
	mov AH, 2ch
    int 21h
    ; CH -> Hora
    ; CL -> Minutos 
    ; DH -> Segundos
    ; DL -> Milisegundos
    ; min * 60s * 100cs + seg * 100cs + cs = tiempo en cs

    mov initialHundred, 00h
    mov initialSeconds, 00h
    mov initialMinutes, 00h
    mov currentTime,    00h      ;; Limpiamos currentTime

    mov initialMinutes, CL
    mov initialSeconds, DH
    mov initialHundred, DL

    xor AX, AX                  ;; Limpiamos AX
    xor BX, BX                  ;; Limpiamos BX para que sirva como registro para hacer las operaciones
    xor CX, CX
    xor DX, DX

    mov BL, initialMinutes      ;; Movemos los minutos a BL

    mov AX, 1770h               ;; 60 * 100 decimal
    mul BX                      ;; AX =  min * 60 * 100
    mov currentTime, AX         ;; currentTime = AX (pasamos los minutos a centésimas)

    xor AX, AX
    xor BX, BX
    mov BL, initialSeconds

    mov AX, 64h             ;; AX = 100 decimal
    mul BL                  ;; AX = seg * 100 (pasamos los segundos a centésimas)

    add currentTime, AX     ;; currentTime += AX (sumamos minutos en centésimas con segundos en centésimas)
    xor BX, BX
    mov BL, initialHundred
    add currentTime, BX

	ret
GetCurrentTime ENDP

mSetCurrentTime macro
    push AX
    call GetCurrentTime
    mov AX, currentTime
    mov initialTime, AX
    pop AX
endm

CalculateTime PROC USES AX BX CX DX
    mSetCursorTime                  ;; Establecemos el cursor al final de la línea 0
    call GetCurrentTime             ;; Obtenemos el tiempo actual en milésimas

    xor AX, AX                      ;; Limpiamos los registros
    xor BX, BX
    xor CX, CX
    xor DX, DX

    mov minuteTime, 00h
    mov secondTime, 00h
    mov hundredTime, 00h
    
    mov AX, currentTime             ;; En AX guardamos el tiempo actual
    sub AX, initialTime             ;; Restamos tiempoActual - tiempoInicial = Diferencia
    mov timePassed, AX              ;; Guardamos el tiempo transcurrido entre la hora de inicio y la actual
    mov totalTimePassed, AX

    mov BX, 1770h                   ;; 6000 decimal        
    div BX                          ;; Diferencia / 6000 = minutos

    mov minuteTime, AX              ;; Guardamos los minutos
    
    mDisplayTime minuteTime        ;; Mostramos los minutos

    mPrintMsg colonChar

    xor AX, AX
    xor BX, BX
    xor CX, CX
    xor DX, DX

    mov AX, 1770h           ;; Cargamos a AX con 6000 d
    mov BX, minuteTime      ;; Movemos los minutos a BX
    mul BX                  ;; Minutos * 6000 
    ;; AX = minutos * 6000
    
    mov CX, timePassed      ;; Movemos la diferencia anterior a CX
    sub CX, AX              ;; Tiempo pasado - minutos * 6000 = nueva diferencia
    

    mov AX, 64h             ;; AX = 100 decimal
    xchg AX, CX
    div CX                  ;; timePassed  = nueva diferencia / 100 = segundos
    mov secondTime, AX

    mDisplayTime secondTime
    mPrintMsg colonChar

    xor AX, AX
    xor BX, BX
    xor CX, CX
    xor DX, DX

    mov BX, secondTime      ;; Movemos los segundos a BX
    mov AX, 64h             ;; Cargamos a AX con 100 decimal
    mul BX                  ;; AX = segundos * 100

    mov CX, timePassed      ;; Cargamos la diferencia pasada en CX
    sub CX, AX              ;; Restamos la diferencia pasada con AX

    mov hundredTime, CX     ;; Guardamos las centéstimas
    
    mDisplayTime hundredTime

    ret
CalculateTime ENDP

