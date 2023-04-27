# Reperesentación de memoria

````plantuml 
@startjson
{
  "userList": [
    {
      "posición": "000F",
      "bytesnombre": 1,
      "valorbytesnombre": 6,
      "bytespassword": 1,
      "valorbytespassword": 7,
      "bytesprimerjuego": 2,
      "valorprimerjuego": "0037h",
      "bytessiguienteusuario": 2,
      "siguienteusuario": "0022h",
      "nombre" : "aceman",
      "password" : "test123",
      "juegos":[
        {
          "posición":"0037h",
          "bytesmetrica": 1,
          "metrica": "t",
          "bytesvalor": 2,
          "valor": "43800t",
          "bytessiguientejuego": 2,
          "siguientejuego": "0000h"
} ]
}, {
      "posición": "0022h",
      "bytesnombre": 1,
      "valorbytesnombre": 7,
      "bytespassword": 1,
      "valorbytespassword": 8,
      "primerjuego": 2,
      "valorprimerjuego": "0000h",
      "bytessiguienteusuario": 2,
      "siguienteusuario": "0000h",
      "nombre" : "player1",
      "password" : "otropass",
      "juegos":[
] }
] }
@endjson
```