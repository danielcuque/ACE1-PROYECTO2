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

El programa está dividido en los siguientes archivos :
- Files.asm: guarda los procedures y macros para leer y escribir archivos.
- Game.asm: guarda los procedures y macros para el manejo del juego.
- Main.asm: guarda el main del programa.
- Sprites.asm: guarda los procedimientos y macros para el manejo de los sprites.
- Timer.asm: guarda los procedimientos y macros para el manejo del cronometro.
- Utils.asm: guarda los procedimientos y macros para el manejo de cadenas y numeros.

## Files.asm

### mReadline
Este macro lee una linea de un archivo y la guarda en un buffer. Recibe como parametros el handle del archivo, el buffer donde se va a guardar la linea y el tamaño del buffer.

### mGetNumberValue 
Este macro avanza denro del fileLineBuffer hasta encontrar un numero, recibe un keyword con el tamaño de la misma, y un buffer donde se va a guardar el numero.

### mGetCoordinate
Este macro lee las coordenadas X y Y del archivo AML, y devuelve dichas coordenadas en los registro AX para X y CX para Y.

### ReadFile
Este procedure recibe en DX el nombre del archivo, y utiliza la interrupción 21h para poder abrir el archivo, la información del archivo se almancena en handleObject.

Este se encarga de cargar el nivel al tablero prinicipal, recibe como parametro el nombre del archivo, y utiliza los macros y procedures definidos anteriormente para poder cargar el nivel.


## Game.asm

### mStartGame
Este macro se encarga de inicializar el juego, recibe como parametro el nombre del archivo que se va a cargar, y utiliza el procedure ReadFile para cargar el nivel.

### PrintHealthAceman
Este procedure se encarga de imprimir la cantidad de vidas que le quedan al jugador, recibe como parametro la cantidad de vidas que le quedan al jugador.


