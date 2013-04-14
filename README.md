API Rutas - SCT
=========

Una API para extraer rutas entre dos destinos, calculando tramos, costos, y combustible estimado de las principales carreteras del pais. Información extraida de [SCT].

  - Tramos entre dos destinos.
  - Peajes de las carreteras dependiendo el tipo de vehiculo.
  - Puntos relevantes. 
  - Combustible estimado en base al calculo del rendimiento del vehiculo.

Parametros
-
  - **ciudad_origen**: ID de la ciudad origen.
  - **ciudad_destino**: ID de la ciudad destino.
  - **vehiculos**: Tipo de vehiculo (Opcional).
  - **calcula_rendimiento**: Calcula el combustible necesario. (Opcional).
  - **tamanio_vehiculo**: Tamaño del vehiculo (Cilindraje cm3) (Opcional).
  - **rendimiento**: Rendimiento del vehiculo estimado (Km/lt) (Opcional).
  - **combustible**: Costo del litro de combustible. (Opcional).
  - **zonas_urbanas**: Despligue de Zonas Urbanas (Opcional).

Ejemplo
-
**Petición:**
```curl -XPOST -H "Accept: application/json" -H "Content-Type: application/json" "http://0.0.0.0:9292/rutas" -d '
{
  "ciudad_origen": "9010",
  "ciudad_destino": "12010",
  "vehiculos": "2",
  "calcula_rendimiento": "true",
  "tamanio_vehiculo": "2",
  "rendimiento": "12",
  "combustible": "11.25",
  "zonas_urbanas": "false"
}'
```

**Respuesta:**
```js
{
   "tramos": [
      {
         "nombre": "Monumento al Caminero - Entronque Ocotepec",
         "estado": "Mor",
         "carretera": "Mex 095D",
         "longitud": "61.340",
         "tiempo": "00:33",
         "caseta": "Tlalpan",
         "costo": "95.0"
      },
      ...
   ],
   "puntos": [
      {
         "inicio": {
            "nombre": "Cd. De México (Zócalo)",
            "lat": "318.90533",
            "lng": "275.07587",
            "tipo": "PG"
         },
         "fin": {
            "nombre": "Monumento a Cuauhtémoc",
            "lat": "318.35947",
            "lng": "275.15588",
            "tipo": "PP"
         },
         "tipo": "1"
      },
      ...
   ],
   "distancia": 354.92,
   "tiempo": 190,
   "peaje": 495,
   "combustible": 365.8,
   "costo": 860.8
}
```

Parametros - Posibles valores
-

**calcula_rendimiento**

**true**
**false**

**vehiculos** - Tipo de vehiculo

**1** - Motocicleta
**2** - Automóvil
**3** - Automóvil remolque 1 eje
**4** - Automóvil remolque 2 eje
**5** - Pick Ups
**6** - Autobus 2 ejes
**7** - Autobus 3 ejes
**8** - Autobus 4 ejes
**9** - Camión 2 ejes
**10** - Camión 3 ejes
**11** - Camión 4 ejes
**12** - Camión 5 ejes
**13** - Camión 6 ejes
**14** - Camión 7 ejes
**15** - Camión 8 ejes
**16** - Camión 9 ejes


**tamanioVehiculo** - Tamaño del vehiculo (Cilindraje)

**1** - 2 Cilindros
**2** - 4 Cilindros
**3** - 6 Cilindros
**4** - 8 Cilindros


**combustible** (Precio actual del combustible, puede ser cualquier valor)

**11.14** - Gasolina Magna
**11.70** - Gasolina Premium
**11.50** - Pemex Diesel
**9.97** - Gas L.P.

Instalacion
-

Instalar gems necesarios:
```bundle install```

Correr la aplicación:
```rackup config.ru```

Datos tecnicos
-----------

La API utiliza lo siguiente:

* Sinatra - Framework.
* Nokogiri - Parsear HTML.
* HTTParty - Recibir response de SCT.

License
-

MIT

  [SCT]: http://aplicaciones4.sct.gob.mx/sibuac_internet/ControllerUI?action=cmdEscogeRuta