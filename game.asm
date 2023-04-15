mGameVars macro
    screenTable DB 03E8h dup(0)         ;; La pantalla es de 25*40
endm


mStartGame macro 
    mWaitEnter
endm