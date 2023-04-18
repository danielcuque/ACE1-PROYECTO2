;; Procedures y macros para realizar el cronómetro

mPrintTime macro
	mov AH, 02				;;
	mov DH, 00				;;	fila
	mov DL, 1Fh				;;	columna
	mov BH, 00				;;
	int 10
	mPrintMsg timeStr
endm

SetCurrentTime PROC USES AX BX CX DX
	call GetCurrentTime
	mov minutesNumber, DX
	mov secondsNumber, BX
	mov milisecondsNumber, AX
	ret
SetCurrentTime ENDP


GetCurrentTime PROC
	mov ah, 2ch
    int 21h
    mov cx, dx 				;; minutos
    mov dx, bx 				;; segundos
    mov bx, cx 				;; milisegundos
	ret
GetCurrentTime ENDP

CalculateTime PROC
    
    ret
CalculateTime ENDP