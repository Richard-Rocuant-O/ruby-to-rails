# Simbols
# se escribe con dos puntos adelant :algo. Se parece a un str, pero cumple rol distinto: un string es cualquier texto entre commillas, mientras que un simbolo es texto que empieza con dos puntos.
# La diferencia importante no es solo de escritura, es de propósito y de memoria:
#1. String ("nombre")-> sirve para trabajar con datos, texto que peude cambiar (mutable)
#2. Symbol (:nombre) -> sirve como identificador, una etiqueta fija (inmutable)

#Si el contenido textual del objeto importa, usa un String; si lo que importa es la identidad del objeto, usa un Symbol.

#Por que existen - la razon de memoria
#1. Cuando creas el mismo str varias veces, rb crea obeject new cada vez, aunque texto identico - cada uno tiene un object_id distinto. En cambio, con simbolos, rb reutiliza siempre el mismo objeto - todos comparten el mismo object_id.
"nommbre".object_id #=> 60
"nombre".object_id #=> 80
#cada "nombre" es un objeto nuevo en memoria, aunque el texto sea igual
:nombre.object_id #=> 1384028
:nombre.object_id #=> 1384028
#da 2 veces el mismo object_id, proque rb reutiliza el mismo objeeto simbolo siemrpe que se escribe el mismo texto. Esto ahorra memoria y hace que la comparacion de simbolos sea mas rapida que la de strings.

#Dónde se usan en la práctica — el caso más típico es como clave de hash:
persona = { :nombre => "Juan", :edad => 30 }
# equivalente a:
persona = { :nombre => "Juan", :edad => 30 }

puts persona[:nombre]   # imprime: Juan

# Aquí :nombre y :edad son símbolos usados como etiquetas del hash — no cambian nunca, solo identifican una posición. Si usaras "nombre" como key en vez de :nombre, funcionaría igual, pero sería menos eficiente porque cada string ocupa memoria nueva.

# Convertir entre ambos cuando lo necesites:
:hola.to_s #=> "hola" (convierte simbolo a string)
"hola".to_sym #=> :hola (convierte string a simbolo)

# Las claves (:nombre) y :edad son symbols, y los valores ("Juan" y 30) son strings y enteros.
persona = { :nombre => "Juan", :edad => 30 }
#            ^^^^^^^           clave = symbol
#                     ^^^^^^   valor = string
#                                       ^^ clave = symbol
#                                           ^^ valor = integer

#Pero ojo, no es obligatorio que las claves sean symbols. Un hash en Ruby puede tener cualquier tipo de dato como clave:

#Claves como str
persona = {"nombre" => "Juan", "edad" => 30 }

#claves como symbols (mas comun en la practica)
persona = { nombre: "Juan", edad: 30 }

#Incluso claves como integers
persona = { 1 => "Juan", 2 => 30 }

#La razón por la que casi siempre vas a ver symbols como claves es justo lo que vimos antes: son más eficientes en memoria (un solo objeto reutilizado) y comunican la intención de "esto es una etiqueta fija, no un dato que cambia".

#Un detalle de sintaxis que te vas a topar seguido: cuando la clave es un symbol, Ruby permite una forma corta sin la flecha =>:
# forma larga (la que tú escribiste)
persona = { :nombre => "Juan", :edad => 30 }

# forma corta (equivalente, solo funciona con symbols)
persona = { nombre: "Juan", edad: 30 }
# Ambas hacen exactamente lo mismo — acceder con persona[:nombre] funciona igual en las dos. La forma corta es la que vas a ver más en código Ruby moderno.


# :variable -> siempre es un symnol, se puede usar en cualquier lugar (una variable suelta, un array, lo que sea)

#variable: -> no es un symbol "sueldo" es una forma abreviada de escribir :variable => que solo tiene sentido dentro de un hash (o al llamar un metodo con argumentos con nombre)