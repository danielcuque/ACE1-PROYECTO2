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
        mov BX, 0
        mov numberGotten, BX
        ; mov BL, timeNumber
        mov BX, timeNumber
        mov numberGotten, BX
        mResetrecoveredStr
        mPrintNumberConverted
        ; call NumToStr
        ; mov BX, offset recoveredStr
        ; add BX, 05h
        ; mPrintPartialDirection BX
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

    xor AX, AX
    xor BX, BX
    mov BL, CL
    mov currentTime, 0000h
    mov AX, 1770h               ;; 60 * 100 decimal
    mul BX                      ;; AX =  min * 60 * 100
    mov currentTime, AX         ;; currentTime = AX

    mDisplayTime currentTime

    xor AX, AX
    mov AX, 64h             ;; AX = 100 decimal
    mul DH                  ;; AX = seg * 100

    add currentTime, AX     ;; currentTime += AX 
    mov DH, 00
    add currentTime, DX

	ret
GetCurrentTime ENDP

CalculateTime PROC USES AX BX CX DX
    mSetCursorTime
    call GetCurrentTime

    ; mDisplayTime currentTime

    ; xor AX, AX
    ; xor BX, BX
    ; xor DX, DX
    
    ; mov AX, currentTime     
    ; sub AX, initialTime     ;; Restamos tiempoActual - tiempoInicial = Diferencia
    ; mov timePassed, AX      ;; Guardamos el tiempo transcurrido
    ; mov BX, 1770h           ;; 6000 decimal        
    ; div BX                  ;; Diferencia / 6000 = minutos

    ; mov minuteTime, AL      ;; Guardamos los minutos

    ; xor AX, AX
    ; xor BX, BX
    ; xor CX, CX

    ; mov AX, 1770h           ;; 
    ; mov BL, minuteTime 
    ; mul BX                  ;; Minutos * 6000 
    
    ; mov CX, timePassed
    ; sub CX, AX              ;; Tiempo pasado - minutos * 6000 = nueva diferencia
    ; mov timePassed, CX

    ; xor AX, AX
    ; mov AX, 64h             ;; AX = 100 decimal
    ; div CX                  ;; timePassed  = nueva diferencia / 100 = segundos
    ; mov secondTime, AL

    ; mDisplayTime minuteTime

    ; mov AH, 02h
    ; mov DL, ':'
    ; int 21h

    ; mDisplayTime secondTime

    ; mov AH, 02h
    ; mov DL, ':'
    ; int 21h

    ; mDisplayTime hundredTime

    ret
CalculateTime ENDP

