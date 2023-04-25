# Proyecto 2

## Universidad de San Carlos de Guatemala
## Facultad de Ingeniería
## Escuela de Ciencias y Sistemas
## Arquitectura de Computadores y Ensambladores 1
## Sección B

## Objetivo del proyecto
El objetivo es implementar un juego similar a Pacman, en el cual se debe recolectar la mayor cantidad de puntos posibles, evitando a los enemigos que se mueven de forma aleatoria. El juego termina cuando se recolectan todos los puntos o cuando el jugador es alcanzado por un enemigo más de tres veces.

## Directivas de ensamblador
```asm
.MODEL small
.STACK
.RADIX 16
.DATA
```
- La directiva RADIX indica que se va a trabajar con números hexadecimales. 
- La directiva STACK indica que se va a utilizar la pila. 
- La directiva DATA indica que se va a declarar variables. 
- La directiva MODEL indica que se va a trabajar con un modelo de 16 bits.

En el `data segment` del archivo main, se declaran las variables que se van a utilizar en el programa. 

En la primera sección se declaran variables de proposito general, como mensajes dentro del juego, etc.

La siguiente sección se utiliza para generar numeros aleatorios a partir de una semilla.


En esta sección se declarar las variables que se van a utilizar para el manejo de archivos. 
```asm
    fileLineBuffer DB 32 dup('$') 
    handleObject DW 0       
    fileName1 DB 'niv1.aml', 0                  
    fileName2 DB 'niv2.aml', 0                      ;; Es necesario colocar 0 al final
    fileName3 DB 'niv3.aml', 0
```

En esta sección se declaran variables que se utilizan para la conversión de numeros a cadenas y viceversa.

```asm
numberGotten DW 0
recoveredStr DB 9 DUP('$')
counterToGetIndexGotten DW 0
```

Variables para generar el cronometro del juego
```asm
initialTime     DW 00                           ;; Se guarda la los minutos:segundos:cs de cuando se inicia el juego en cs (centésimas de segundo)
currentTime     DW 00h                          ;; Se va actualizando el tiempo

initialMinutes  DB 00h
initialSeconds  DB 00h
initialHundred  DB 00h

timePassed      DW 00
minuteTime      DW 00h
secondTime      DW 00h
hundredTime     DW 00h
```
