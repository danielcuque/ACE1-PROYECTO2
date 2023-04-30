# Proyecto 2

## Universidad de San Carlos de Guatemala
## Facultad de Ingeniería
## Escuela de Ciencias y Sistemas
## Arquitectura de Computadores y Ensambladores 1
## Sección B

## Objetivo del proyecto
El objetivo es implementar un juego similar a Pacman, en el cual se debe recolectar la mayor cantidad de puntos posibles, evitando a los enemigos que se mueven de forma aleatoria. El juego termina cuando se recolectan todos los puntos o cuando el jugador es alcanzado por un enemigo más de tres veces.

# Indice
1. [Directivas de ensamblador](#directivas-de-ensamblador)
2. [Diagrama de memoria](#diagrama-de-memoria)

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

### PrintMapObject
No recibe ningun parametro, y se encarga de imprimir el mapa del nivel.

### SearchPortalPosition
Se encarga de cambiar las coordenadas del aceman hacia la salida del otro portal, se verifica que el portal actual no sea el que se encontró en el tablero, y se cambia de posición

### InsertMapObject
Este procedure recibe como argumentos las posiciones X e Y del objeto que se quiere guardar, asi como el ID del objeto. Para ello calcula el row major index de la posición, y se guarda en el tablero.

### GetMapObject
Este procedure recibe como argumentos las posiciones X e Y del objeto que se quiere obtener, y devuelve el ID del objeto que se encuentra en dicha posición.

### mVerifyGhostAcemPosition
Se encarga de verificar si el aceman y algun fantasma que se pase por parametro están el misma posición, también se verifica si el fantasma es comestible o no, y se restan vidas, o se sube el puntaje dependiendo del caso.

### MoveAceman
Este procedure toma en DH la dirección hacia la cual se está moviendo el aceman. Se obtiene la posición del siguiente objeto, y dependiendo de qué ID sea, se mueve el aceman o no.

### ChangeAcemanDirection
Este procedure se encarga de cambiar la dirección del aceman, recibe como parametro la dirección a la cual se quiere mover el aceman. También se encarga de verificar si el usuario pauso el juego, o si se quiere salir del juego.

### mMoveGhost
Este macro se encarga de mover un fantasma, recibe como parametro el ID del fantasma que se quiere mover, y se encarga de verificar si el fantasma es comestible o no, y se mueve de forma aleatoria.

### mMoveGhosts
Este macro se encarga de mover todos los fantasmas, recibe como parametro el ID del fantasma que se quiere mover, y se encarga de verificar si el fantasma es comestible o no, y se mueve de forma aleatoria.

## Timer.asm

### GetCurrentTime
Este procedure se encarga de obtener el tiempo actual, y lo guarda en currentTime, todo esto en centésimas de segundo.

### CalculateTime
Este procedure se encarga de llevar el conteo del tiempo, toma el tiempoActual y lo resta con el tiempoInicial, y lo guarda en timePassed. Luego se divide entre 100 para obtener los segundos, y se divide entre 60 para obtener los minutos.

### PrintTime
Este procedure se encarga de imprimir el tiempo en el tablero, recibe como parametro el tiempo que se quiere imprimir.

## Utils.asm

### FillWithDots
Este procedure se encarga de llenar el tablero con acedots en los espacios faltantes. Toma como referencia el primer muro, para encontrar donde acaba ese muro, y calcular el rando de coordenadas en las cuales si se puede colocar un acedot. De lo contrario sigue iterando hasta llenar todo el tablero.

Además, reserva el espacio que se usa para la casa de los fantasmas, para que no se coloquen acedots en esa posición.

### mResetVar
Este macro se encarga de resetear una variable con signos de dolar, toma como parametro el nombre de la variable.

### mActiveVideoMode
Este macro se encarga de activar el modo de video 13h. Con la interrupción 10h, se cambia el modo de video a 13h.

### mDeactiveVideoMode
Este macro se encarga de desactivar el modo de video 13h. Con la interrupción 10h, se cambia el modo de video a 03h.

### EmptyScreen
Se encarga de limpiar la pantalla, y se encarga de colocar el cursor en la posición 0,0.

### IsNumber
Este procedure se encarga de verificar si un caracter es un numero, recibe como parametro el caracter que se quiere verificar, y devuelve 1 si es un numero, y 0 si no lo es.

### PrincAceman
Se encarga de imprimir el aceman en el tablero, recibe como parametro la posición X e Y donde se quiere imprimir el aceman. Además, en cada iteración niega el valor de la variable currentAcemanSprite, para que se pueda animar el aceman.


### PrintSprite
Se encarga de imprimir un sprite en el tablero, recibe como parametro la posición X e Y donde se quiere imprimir el sprite, y el ID del sprite que se quiere imprimir. Además, calcula el row major de 8x8 para que quede centrado el sprite al moverse a través de la pantalla.

### NumToString

Este procedure se encarga de convertir un numero a una cadena de caracteres, recibe como parametro el numero que se quiere convertir, y el buffer donde se va a guardar la cadena.

### StringToNum

Este procedure se encarga de convertir una cadena de caracteres a un numero, recibe como parametro la cadena que se quiere convertir, y el buffer donde se va a guardar el numero.

### GenerateRandomNumber

Este procedure se encarga de generar un numero aleatorio, recibe como parametro el numero maximo que se puede generar, y devuelve el numero aleatorio generado.


### CalculateTemporizer

Este procedure se encarga de calcular el temporizador, recibe como parametro el tiempo que se quiere temporizar, y se encarga de verificar si el temporizador ya terminó, o si se quiere pausar el juego.


# Diagrama de memoria