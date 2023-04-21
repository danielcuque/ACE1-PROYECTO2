mSpriteVars MACRO
    acemanClose        DB     00, 00, 0e, 0e, 0e, 0e, 00, 00
                       DB     00, 0e, 0e, 0e, 0e, 0e, 0e, 00
                       DB     0e, 0e, 00, 0e, 0e, 0e, 0e, 0e
                       DB     0e, 0e, 0e, 0e, 0e, 0e, 0e, 0e
                       DB     0e, 0e, 0e, 00, 00, 00, 00, 00
                       DB     0e, 0e, 0e, 0e, 0e, 0e, 0e, 0e
                       DB     00, 0e, 0e, 0e, 0e, 0e, 0e, 00
                       DB     00, 00, 0e, 0e, 0e, 0e, 00, 00
        ;; Aceman izquierda
                       DB     00, 00, 0e, 0e, 0e, 0e, 00, 00
                       DB     00, 0e, 0e, 0e, 0e, 0e, 0e, 00
                       DB     0e, 0e, 0e, 0e, 0e, 00, 0e, 0e
                       DB     0e, 0e, 0e, 0e, 0e, 0e, 0e, 0e
                       DB     00, 00, 00, 00, 00, 0e, 0e, 0e
                       DB     0e, 0e, 0e, 0e, 0e, 0e, 0e, 0e
                       DB     00, 0e, 0e, 0e, 0e, 0e, 0e, 00
                       DB     00, 00, 0e, 0e, 0e, 0e, 00, 00
        ;; Aceman arriba
                       DB     00, 00, 0e, 0e, 00, 0e, 00, 00
                       DB     00, 0e, 0e, 0e, 00, 0e, 0e, 00
                       DB     0e, 0e, 0e, 0e, 00, 0e, 0e, 0e
                       DB     0e, 0e, 0e, 0e, 00, 0e, 0e, 0e
                       DB     0e, 0e, 0e, 0e, 00, 0e, 0e, 0e
                       DB     0e, 0e, 00, 0e, 0e, 0e, 0e, 0e
                       DB     00, 0e, 0e, 0e, 0e, 0e, 0e, 00
                       DB     00, 00, 0e, 0e, 0e, 0e, 00, 00
        ;; Aceman abajo
                       DB     00, 00, 0e, 0e, 0e, 0e, 00, 00
                       DB     00, 0e, 0e, 0e, 0e, 0e, 0e, 00
                       DB     0e, 0e, 00, 0e, 0e, 0e, 0e, 0e
                       DB     0e, 0e, 0e, 0e, 00, 0e, 0e, 0e
                       DB     0e, 0e, 0e, 0e, 00, 0e, 0e, 0e
                       DB     0e, 0e, 0e, 0e, 00, 0e, 0e, 0e
                       DB     00, 0e, 0e, 0e, 00, 0e, 0e, 00
                       DB     00, 00, 0e, 0e, 00, 0e, 00, 00

    acemanOpen         DB     00, 00, 0e, 0e, 0e, 0e, 0e, 00
                       DB     00, 0e, 0e, 0e, 0e, 0e, 0e, 0e
                       DB     0e, 0e, 00, 0e, 0e, 0e, 0e, 00
                       DB     0e, 0e, 0e, 0e, 0e, 0e, 00, 00
                       DB     0e, 0e, 0e, 0e, 0e, 00, 00, 00
                       DB     0e, 0e, 0e, 0e, 0e, 0e, 00, 00
                       DB     00, 0e, 0e, 0e, 0e, 0e, 0e, 0e
                       DB     00, 00, 0e, 0e, 0e, 0e, 0e, 00
        ;; Aceman izquierda
                       DB     00, 0e, 0e, 0e, 0e, 0e, 00, 00
                       DB     0e, 0e, 0e, 0e, 0e, 0e, 0e, 00
                       DB     00, 0e, 0e, 0e, 0e, 00, 0e, 0e
                       DB     00, 00, 0e, 0e, 0e, 0e, 0e, 0e
                       DB     00, 00, 00, 0e, 0e, 0e, 0e, 0e
                       DB     00, 00, 0e, 0e, 0e, 0e, 0e, 0e
                       DB     0e, 0e, 0e, 0e, 0e, 0e, 0e, 00
                       DB     00, 0e, 0e, 0e, 0e, 0e, 00, 00
        ;; Aceman arriba
                       DB     00, 0e, 00, 00, 00, 00, 0e, 00
                       DB     0e, 0e, 0e, 00, 00, 00, 0e, 0e
                       DB     0e, 0e, 0e, 0e, 00, 0e, 0e, 0e
                       DB     0e, 0e, 0e, 0e, 0e, 0e, 0e, 0e
                       DB     0e, 0e, 0e, 0e, 0e, 0e, 0e, 0e
                       DB     0e, 0e, 00, 0e, 0e, 0e, 0e, 0e
                       DB     00, 0e, 0e, 0e, 0e, 0e, 0e, 00
                       DB     00, 00, 0e, 0e, 0e, 0e, 00, 00
        ;; Aceman abajo     
                       DB     00, 00, 0e, 0e, 0e, 0e, 00, 00
                       DB     00, 0e, 0e, 0e, 0e, 0e, 0e, 00
                       DB     0e, 0e, 00, 0e, 0e, 0e, 0e, 0e
                       DB     0e, 0e, 0e, 0e, 0e, 0e, 0e, 0e
                       DB     0e, 0e, 0e, 0e, 0e, 0e, 0e, 0e
                       DB     0e, 0e, 0e, 0e, 00, 0e, 0e, 0e
                       DB     0e, 0e, 0e, 00, 00, 00, 0e, 0e
                       DB     00, 0e, 00, 00, 00, 00, 0e, 00

    wallSprite         DB     00, 00, 00, 00, 00, 00, 00, 00
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00 

    ;; wallSprite          
                       DB     00, 00, 00, 00, 00, 00, 00, 00
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 01, 01, 01, 01, 01, 01  
                       DB     00, 00, 01, 09, 09, 09, 09, 09  
                       DB     00, 00, 01, 09, 09, 09, 09, 09  
                       DB     00, 00, 01, 09, 09, 01, 01, 01  
                       DB     00, 00, 01, 09, 09, 01, 00, 00  
                       DB     00, 00, 01, 09, 09, 01, 00, 00

    ;; wallType2          
                       DB     00, 00, 00, 00, 00, 00, 00, 00
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     01, 01, 01, 01, 01, 01, 00, 00  
                       DB     09, 09, 09, 09, 09, 01, 00, 00  
                       DB     09, 09, 09, 09, 09, 01, 00, 00  
                       DB     01, 01, 01, 09, 09, 01, 00, 00  
                       DB     00, 00, 01, 09, 09, 01, 00, 00  
                       DB     00, 00, 01, 09, 09, 01, 00, 00

    ;; wallType3          
                       DB     00, 00, 01, 09, 09, 01, 00, 00
                       DB     00, 00, 01, 09, 09, 01, 00, 00  
                       DB     00, 00, 01, 09, 09, 01, 00, 00  
                       DB     00, 00, 01, 09, 09, 01, 00, 00  
                       DB     00, 00, 01, 09, 09, 01, 00, 00  
                       DB     00, 00, 01, 09, 09, 01, 00, 00  
                       DB     00, 00, 01, 09, 09, 01, 00, 00  
                       DB     00, 00, 01, 09, 09, 01, 00, 00   

    ;; wallType4          
                       DB     00, 00, 00, 00, 00, 00, 00, 00
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     01, 01, 01, 01, 01, 01, 01, 01  
                       DB     09, 09, 09, 09, 09, 09, 09, 09  
                       DB     09, 09, 09, 09, 09, 09, 09, 09  
                       DB     01, 01, 01, 01, 01, 01, 01, 01  
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00

    ;; wallType5          
                       DB     00, 00, 00, 00, 00, 00, 00, 00
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 01, 01, 01, 01, 01, 01  
                       DB     00, 00, 01, 09, 09, 09, 09, 09  
                       DB     00, 00, 01, 09, 09, 09, 09, 09  
                       DB     00, 00, 01, 01, 01, 01, 01, 01  
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00

    ;; wallType6          
                       DB     00, 00, 00, 00, 00, 00, 00, 00
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     01, 01, 01, 01, 01, 01, 00, 00  
                       DB     09, 09, 09, 09, 09, 01, 00, 00  
                       DB     09, 09, 09, 09, 09, 01, 00, 00  
                       DB     01, 01, 01, 01, 01, 01, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00
                       
    ;; wallType7          
                       DB     00, 00, 01, 09, 09, 01, 00, 00
                       DB     00, 00, 01, 09, 09, 01, 00, 00  
                       DB     00, 00, 01, 09, 09, 01, 00, 00  
                       DB     00, 00, 01, 09, 09, 01, 00, 00  
                       DB     00, 00, 01, 09, 09, 01, 00, 00  
                       DB     00, 00, 01, 01, 01, 01, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00

    ;; wallType8          
                       DB     00, 00, 00, 00, 00, 00, 00, 00
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 01, 01, 01, 01, 00, 00  
                       DB     00, 00, 01, 09, 09, 01, 00, 00  
                       DB     00, 00, 01, 09, 09, 01, 00, 00  
                       DB     00, 00, 01, 09, 09, 01, 00, 00  
                       DB     00, 00, 01, 09, 09, 01, 00, 00  
                       DB     00, 00, 01, 09, 09, 01, 00, 00

    ;; wallType9          
                       DB     00, 00, 00, 00, 00, 00, 00, 00
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     01, 01, 01, 01, 01, 01, 01, 01  
                       DB     09, 09, 09, 09, 09, 09, 09, 09  
                       DB     09, 09, 09, 09, 09, 09, 09, 09  
                       DB     01, 01, 01, 09, 09, 01, 01, 01  
                       DB     00, 00, 01, 09, 09, 01, 00, 00  
                       DB     00, 00, 01, 09, 09, 01, 00, 00

    ;; wallTypeA          
                       DB     00, 00, 01, 09, 09, 01, 00, 00
                       DB     00, 00, 01, 09, 09, 01, 00, 00  
                       DB     00, 00, 01, 09, 09, 01, 01, 01  
                       DB     00, 00, 01, 09, 09, 09, 09, 09  
                       DB     00, 00, 01, 09, 09, 09, 09, 09  
                       DB     00, 00, 01, 09, 09, 01, 01, 01  
                       DB     00, 00, 01, 09, 09, 01, 00, 00  
                       DB     00, 00, 01, 09, 09, 01, 00, 00

    ;; wallTypeB          
                       DB     00, 00, 01, 09, 09, 01, 00, 00
                       DB     00, 00, 01, 09, 09, 01, 00, 00  
                       DB     01, 01, 01, 09, 09, 01, 01, 01  
                       DB     09, 09, 09, 09, 09, 09, 09, 09  
                       DB     09, 09, 09, 09, 09, 09, 09, 09  
                       DB     01, 01, 01, 01, 01, 01, 01, 01  
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00

    ;;wallTypeC
                       DB     00, 00, 01, 09, 09, 01, 00, 00
                       DB     00, 00, 01, 09, 09, 01, 00, 00  
                       DB     01, 01, 01, 09, 09, 01, 00, 00  
                       DB     09, 09, 09, 09, 09, 01, 00, 00  
                       DB     09, 09, 09, 09, 09, 01, 00, 00  
                       DB     01, 01, 01, 09, 09, 01, 00, 00  
                       DB     00, 00, 01, 09, 09, 01, 00, 00  
                       DB     00, 00, 01, 09, 09, 01, 00, 00

    ;; wallTypeD          
                       DB     00, 00, 00, 00, 00, 00, 00, 00
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 01, 01, 01, 01, 00, 00  
                       DB     00, 00, 01, 09, 09, 01, 00, 00  
                       DB     00, 00, 01, 09, 09, 01, 00, 00  
                       DB     00, 00, 01, 01, 01, 01, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00

    ;; wallTypeE         
                       DB     00, 00, 01, 09, 09, 01, 00, 00
                       DB     00, 00, 01, 09, 09, 01, 00, 00  
                       DB     00, 00, 01, 09, 09, 01, 01, 01  
                       DB     00, 00, 01, 09, 09, 09, 09, 09  
                       DB     00, 00, 01, 09, 09, 09, 09, 09  
                       DB     00, 00, 01, 01, 01, 01, 01, 01  
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00  

    ;; wallTypeF
                       DB     00, 00, 01, 09, 09, 01, 00, 00
                       DB     00, 00, 01, 09, 09, 01, 00, 00  
                       DB     01, 01, 01, 09, 09, 01, 00, 00  
                       DB     09, 09, 09, 09, 09, 01, 00, 00  
                       DB     09, 09, 09, 09, 09, 01, 00, 00  
                       DB     01, 01, 01, 01, 01, 01, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00 

    Portal             DB     00, 00, 00, 00, 00, 00, 00, 00
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f  
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00

    GhostRed           DB     00, 00, 04, 04, 04, 00, 00, 00
                       DB     00, 04, 04, 04, 04, 04, 00, 00  
                       DB     04, 0f, 0f, 04, 0f, 0f, 04, 00  
                       DB     04, 00, 0f, 04, 00, 0f, 04, 00  
                       DB     04, 04, 04, 04, 04, 04, 04, 00  
                       DB     04, 04, 04, 04, 04, 04, 04, 00  
                       DB     04, 04, 04, 04, 04, 04, 04, 00  
                       DB     04, 00, 04, 00, 04, 00, 04, 00

    GhostOrange        DB     00, 00, 06, 06, 06, 00, 00, 00
                       DB     00, 06, 06, 06, 06, 06, 00, 00  
                       DB     06, 0f, 0f, 06, 0f, 0f, 06, 00  
                       DB     06, 00, 0f, 06, 00, 0f, 06, 00  
                       DB     06, 06, 06, 06, 06, 06, 06, 00  
                       DB     06, 06, 06, 06, 06, 06, 06, 00  
                       DB     06, 06, 06, 06, 06, 06, 06, 00  
                       DB     06, 00, 06, 00, 06, 00, 06, 00

    GhostMagenta       DB     00, 00, 05, 05, 05, 00, 00, 00
                       DB     00, 05, 05, 05, 05, 05, 00, 00  
                       DB     05, 0f, 0f, 05, 0f, 0f, 05, 00  
                       DB     05, 00, 0f, 05, 00, 0f, 05, 00  
                       DB     05, 05, 05, 05, 05, 05, 05, 00  
                       DB     05, 05, 05, 05, 05, 05, 05, 00  
                       DB     05, 05, 05, 05, 05, 05, 05, 00  
                       DB     05, 00, 05, 00, 05, 00, 05, 00

    GhostCyan          DB     00, 00, 0b, 0b, 0b, 00, 00, 00
                       DB     00, 0b, 0b, 0b, 0b, 0b, 00, 00  
                       DB     0b, 0f, 0f, 0b, 0f, 0f, 0b, 00  
                       DB     0b, 00, 0f, 0b, 00, 0f, 0b, 00  
                       DB     0b, 0b, 0b, 0b, 0b, 0b, 0b, 00  
                       DB     0b, 0b, 0b, 0b, 0b, 0b, 0b, 00  
                       DB     0b, 0b, 0b, 0b, 0b, 0b, 0b, 00  
                       DB     0b, 00, 0b, 00, 0b, 00, 0b, 00

    GhostBlue          DB     00, 00, 01, 01, 01, 00, 00, 00
                       DB     00, 01, 01, 01, 01, 01, 00, 00  
                       DB     01, 0f, 0f, 01, 0f, 0f, 01, 00  
                       DB     01, 00, 0f, 01, 00, 0f, 01, 00  
                       DB     01, 01, 01, 01, 01, 01, 01, 00  
                       DB     01, 01, 01, 01, 01, 01, 01, 00  
                       DB     01, 01, 01, 01, 01, 01, 01, 00  
                       DB     01, 00, 01, 00, 01, 00, 01, 00

    AceDot             DB     00, 00, 00, 00, 00, 00, 00, 00
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 00, 0f, 0f, 00, 00, 00  
                       DB     00, 00, 00, 0f, 0f, 00, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00

    PortalSprite       DB     00, 00, 00, 00, 00, 00, 00, 00
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 00, 06, 06, 00, 00, 00  
                       DB     00, 00, 00, 06, 06, 00, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00

    PowerDot           DB     00, 00, 00, 00, 00, 00, 00, 00
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 07, 07, 07, 07, 00, 00  
                       DB     00, 00, 07, 0f, 0f, 07, 00, 00  
                       DB     00, 00, 07, 0f, 0f, 07, 00, 00  
                       DB     00, 00, 07, 07, 07, 07, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00

    HeartSprite        DB     00, 00, 00, 00, 00, 00, 00, 00
                       DB     00, 04, 04, 00, 04, 04, 00, 00
                       DB     04, 04, 04, 04, 04, 04, 04, 00  
                       DB     04, 04, 04, 04, 04, 04, 04, 00  
                       DB     00, 04, 04, 04, 04, 04, 00, 00  
                       DB     00, 00, 04, 04, 04, 00, 00, 00  
                       DB     00, 00, 00, 04, 00, 00, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00 

    CoinSprite         DB     00, 00, 00, 0e, 0e, 00, 00, 00
                       DB     00, 00, 0e, 0e, 0e, 0e, 00, 00
                       DB     00, 0e, 0e, 0f, 0e, 0e, 0e, 00  
                       DB     00, 0e, 0e, 0f, 0e, 0e, 0e, 00  
                       DB     00, 0e, 0e, 0e, 0f, 0e, 0e, 00  
                       DB     00, 00, 0e, 0e, 0e, 0e, 00, 00  
                       DB     00, 00, 00, 0e, 0e, 00, 00, 00  
                       DB     00, 00, 00, 00, 00, 00, 00, 00 

    LevelSprite        DB     00, 00, 00, 00, 00, 00, 00, 00
                       DB     00, 00, 00, 00, 00, 00, 07, 00
                       DB     00, 00, 00, 00, 00, 07, 07, 00  
                       DB     00, 00, 00, 00, 07, 07, 07, 00  
                       DB     00, 00, 00, 07, 07, 07, 07, 00  
                       DB     00, 00, 07, 07, 07, 07, 07, 00  
                       DB     00, 07, 07, 07, 07, 07, 07, 00  
                       DB     07, 07, 07, 07, 07, 07, 07, 00 
          
ENDM