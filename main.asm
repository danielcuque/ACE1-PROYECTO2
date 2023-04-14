INCLUDE utils.asm

.MODEL small
.STACK
.RADIX 16
.DATA
mVarsUtils


.CODE
start:
    main PROC
        mov ax, @data
        mov ds, ax
        mPrintMsg infoMsg
        mWaitEnter
        mExit
    main ENDP
END start
