mGameVars macro
    screenTable DB 03E8h dup(0)         ;; La pantalla es de 25*40
endm


mStartGame macro 
    ; call CreateMap
    ; call ShowMapObjects
    call PrintAceman
endm


CreateMap PROC
    
CreateMap ENDP

;---------------------------------------------------------
; ShowMapObjects
;
; Descripción:
; Pinta objetos en el mapa del juego
;
; Recibe:
; AX -> Pos X del objeto
; CX -> Pos Y del objeto
; DH -> Tipo de objeto a pintar
;
; Retorna:
; -
;---------------------------------------------------------

ShowMapObjects PROC USES AX CX
    
ShowMapObjects ENDP