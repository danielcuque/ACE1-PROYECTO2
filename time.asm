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
        mov BX, timeNumber
        mov numberGotten, BX
        mResetrecoveredStr
        call NumToStr
        mov BX, offset recoveredStr
        add BX, 05h
        mPrintPartialDirection BX
    pop BX  
endm

SetCurrentTime PROC USES AX CX DX
	call GetCurrentTime
    mSetCursorTime
    
	; mov minutesNumber, CL
	; mov secondsNumber, DH
	; mov milisecondsNumber, DL
	ret
SetCurrentTime ENDP

;---------------------------------------------------------
; GetCurrentTime
;
; Descripción:
; Obtiene la hora actual del dispositivo y lo devuelve en milésimas
;
; Recibe:
; -
;
; Retorna:
; AX ->  Hora en centésimas
;---------------------------------------------------------

GetCurrentTime PROC
	mov AH, 2ch
    int 21h
    mov AX, 00h


	ret
GetCurrentTime ENDP

CalculateTime PROC USES AX BX CX DX
    mSetCursorTime
    call GetCurrentTime

    sub CX, initialHour
    sub DX, minutesNumber
    sub BX, secondsNumber
    sub AX, milisecondsNumber

    mDisplayTime DX

    mov ah, 2
    mov dl, ':'
    int 21h

    mDisplayTime BX

    mov ah, 2
    mov dl, ':'
    int 21h

    mDisplayTime AX

    ret
CalculateTime ENDP

