INCLUDE utils.asm
INCLUDE menu.asm

.MODEL small
.STACK
.RADIX 16
.DATA
mUtilsVars
mMenuVars


mStartProgram macro
    LOCAL start, exit
    start:
        mPrintMsg infoMsg
        mWaitEnter
        mPrintMsg menuMsg
        mWaitEnter
    exit:
        mActiveTextMode
        mExit
endm

.CODE
start:
    main PROC
        mov ax, @data
        mov ds, ax
        mStartProgram
    main ENDP
END start
