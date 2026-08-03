#son métodos, y viven en el módulo Enumerable, que Array incluye (junto con Hash, Range, etc.). Por eso los llamas directo sobre un array: numeros.map, numeros.select, numeros.reduce.

#-----------------------
#-----------------------
#-----------------------
#1.map - aplica un bloque a cada elemento del array y devuelve un array nuevo con los valores transformados (el original no cambia)
numeros = [10,20,30]
nueva_lista = numeros.map { |n| n * 2 }# nueva_lista = [20,40,60]

horas_curado = [24,48.72]
horas_extra = horas_curado.map{|h| h +12}
puts horas_extra # => [36,60,84]

nombres = ["juan", "pedro", "maria"]
nombres_mayus = nombres.map{|n| n.upcase}
puts nombres_mayus # => ["JUAN", "PEDRO", "MARIA"]

tickets = [100,200,300]
tickets_formateados = tickets.map {|t| "CORD-#{t}"}
puts tickets_formateados # => ["CORD-100", "CORD-200", "CORD-300"]

#-----------------------
#-----------------------
#-----------------------
#2.select 
# - filtra el array, devolviendo solo los elementos donde el bloque devuelve true. No transforma, solo filtra.
numeros = [10,20,30,40,50]
mayores = numeros.select {|n| n>20}
# => mayores = [30,40,50]

edades = [15, 22, 18, 30, 12]
adultos = edades.select {|edad| edad >=18}
puts adultos # => [22, 18, 30]

stock = [5, 10, 0, 3, 8]
con_stock = stock.select {|cantidad| cantidad > 0}
puts con_stock # => [5, 10, 3, 8]

palabras = ["sol", "luna", "estrella", "cielo"]
palabras_largas = palabras.select {|palabra| palabra.length > 4}
puts palabras_largas # => ["luna", "estrella"]



#3.reduce - aplica una funcion acumulativa a cada elemento, colapsando todo el array en un solo valor final. El primer argumento (0) es el valor inicial del acumulador.
numeros = [1,2,3,4]
suma = numeros.reduce(0) {|acumulador, n| acumulador +n}

# acumulador empieza en 0, y se le va sumando cada elemento del array. Al final, suma = 10.
#el precio total de un carrito de compras, por ejemplo, se puede calcular con reduce.
precios = [100, 200, 300]
total = precios.reduce(0) { |acumulador, p| acumulador + p }
puts total # => 600

palets_por_dia = [10, 20, 15, 25]
mayor_dia = palets_por_dia.reduce { |max, dia| dia > max ? dia : max }

nombres = ["Juan", "Maria", "Pedro"]
oracion = nombres.reduce("") { |acumulador, n| acumulador + n + " " }

#-----------------------
#-----------------------
#-----------------------
#.4.yield---------------
#Es una palabra clave que, dentro de un metodo, ejecuta el bloque de codigo qeu se le paso a ese metodo al llamarlo. El bloque es implicito: no aparece como parametro en la definicion del metodo.
def saludar
    puts "antes"
    yield
    puts "despues"
end
saludar {puts "hola"} # => antes, hola, despues

#Si llamas 'saludar' sin bloque explota (no block given (yield)), pero puedes usar 'block_given?' para verificar si hay un bloque antes de hacer yield.

puts "--- YIELD 1 ---"
def procesar_import
    puts "abriendo excel"
    yield
    puts "cerrando excel"
end
procesar_import {puts "procesando datos"} # => abriendo excel, procesando datos, cerrando excel

def saludar
    puts "hola"
    yield
    puts "adios"
end
saludar do 
    puts "bloque de codigo"
end

#.5.&block---------------
#Es la misma idea - un metodo que un trozo de codigo de aguera - pero capturado explicitamente como parametro con nombre. En vez de yield, usas block.call.
def saludar (&block)
    puts "antes"
    block.call
    puts "despues"
end
saludar {puts "hola"} # => antes, hola, despues

def ejecutar_bloque(&block)
    block.call
end
ejecutar_bloque do
    puts "Bloque ejecutado"
end

#La diferencia entre ambos, en una linea
yield # ejecuta el bloque pasado al metodo, sin necesidad de declararlo como parametro.
#ejecuta el bloque directo, sin poder guardarlo, moverlo, no pasarlo a otro metodo.
&block #el bloque queda guardado en una variable (block), asi que lo puedes pasar a otro metodo, guardarlo para usarlo despues, o preguntarle cosas (como si existe, con block_given?)
def ejecutar_bloque(&block)
    otro_metodo(&block) #paso el bloque a otro metodo
end
def otro_metodo
    yield #ejecuta el bloque pasado al metodo, sin necesidad de declararlo como parametro.
end
ejecuta_bloque {puts "hola"} # => hola