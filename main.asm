.MODEL small
.STACK
.RADIX 16
.DATA
.CODE

.CODE
start:
    main PROC
        mov ax, @data
        mov ds, ax
    main ENDP
END start
