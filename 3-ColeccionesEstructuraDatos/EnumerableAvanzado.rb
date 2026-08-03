#1. find(alias:detect)
#devuelve el primer elemento que cumple la condicion, y se detiene ahi - no sigue revisando el resto del array. A diferencia de select, que devuelve todos los que cumplen en un array nuevo.
numeros = [10, 20, 30, 40]
primero_mayor_25 = numeros.find do |n|
  n>25
end
primero_mayor_251 = numeros.find {|n| n> 25}

# Ejercicio 1
#patron (array de hahses) es muy comun - es como se ve una lista de 'registros' u 'obejtos' con varios campos cada uno, algo parecido a una tabla o una lista de JSON
tickets = [{id: "CORD-95", estado: "abierto"}, {id: "CORD-96", estado: "cerrado"}]
resultado = tickets.find { |t| t[:estado] == "abierto" }
# => {id: "CORD-95", estado: "abierto"}

# Ejercicio 2
palets = [{codigo: "PAL-01", curado: false}, {codigo: "PAL-02", curado: true}]
listo = palets.find do |p|
  p|:curado|
end

listo1 = palets.find{|p| p[:curado]}

# Ejercicio 3
edades = [15, 16, 17, 18, 19]
primer_adulto = edades.find { |e| e >= 18 }
# Revisa 15, 16, 17 (no cumplen), llega a 18 -> cumple, se detiene ahí. No sigue al 19.
# => 18

# Ejercicio 4
socios = [{nombre: "Ana", id: 3}, {nombre: "Luis", id: 7}]
buscado = socios.find { |s| s[:id] == 99 }
# Ningun elemento tiene id 99. Cuando find no encuentra nada, devuelve nil.
# => nil

# Ejercicio 5
stock = [0, 0, 5, 0, 3]
primero_con_stock = stock.find { |s| s > 0 }
# Revisa 0, 0 (no cumplen), llega al 5 -> cumple, se detiene. No revisa el 0 ni el 3 siguientes.
# => 5




#2. reject
#lo opuesto de select: devuelve los elementos que NO cumplen la condicion
#even?: es par este numero
#odd?: es impar este numero

numeros = [1,2,3,4,5,6]
impares = numeros.reject { |n| n.even? }
#=> [1,3,5]

# Ejercicio 1
campus = ["Punta Arenas", "Puerto Natales", nil, "Rio Grande"]
campus_validos = campus.reject{|c| c.nil?}
# Revisa cada elemento, se queda con los que el bloque devuelve false (o sea, no es nil).
# => ["Punta Arenas", "Puerto Natales", "Rio Grande"]

# Ejercicio 2
tickets = [{id: "CORD-95", cerrado: true}, {id: "CORD-96", cerrado: false}]
pendientes = tickets.reject {|t| t{:cerrado}}
# Se queda con los que el bloque NO cumple: cerrado=false -> se queda con CORD-96.
# => [{id: "CORD-96", cerrado: false}]

# Ejercicio 3
numeros = [10, 15, 20, 25, 30]
no_multiplos_10 = numeros.reject { |n| n % 10 == 0 }
#Descarta los que son multiplos de 10 (10,20,30). Se queda con el resto.
#=>[15,25]

# Ejercicio 4
socios = ["Juan", "", "Maria", "", "Pedro"]
nombres_validos = socios.reject { |s| s.empty? }
#Descarta los strings vacios ("")
# => ["Juan", "Maria", "Pedro"]

# Ejercicio 5
horas = [24, 48, 12, 72, 6]
horas_sufientes = horas.reject {|h| h<24}
# Descarta los menores a 24 (12 y 6). Se queda con 24, 48, 72.
# => [24, 48, 72]



#3. sort_by
#ordena el array segun el valor que el bloque devuelve para cada elemento (de menor a mayor por defecto)

palabras = ["banana", "kiwi", "frutilla", "uva"]
por_longitud = palabras.sort_by { |p| p.length }
# => ["uva", "kiwi", "banana", "frutilla"]

#por cada palabra p, calcula p.length (su longitud) y sort_by ordena el array segun esos numeros, de menor a mayor.

edades = [30, 15, 22, 18]
ordenadas = edades.sort_by{|e| e}
# Sin transformar nada, ordena los numeros de menor a mayor.
# => [15, 18, 22, 30]


# Ejercicio 3
palets = [{codigo: "PAL-03"}, {codigo: "PAL-01"}, {codigo: "PAL-02"}]
ordenados = palets.sort_by { |p| p[:codigo] }
# Ordena alfabeticamente por el string del codigo.
# => [{codigo: "PAL-01"}, {codigo: "PAL-02"}, {codigo: "PAL-03"}]

# Ejercicio 4
tickets = ["CORD-98", "CORD-95", "CORD-97"]
mas_reciente_primero = tickets.sort_by {|t| t}.reverse
#sort_by ordena accendente, .reverse invierte el resultado -> del mas alto al mas bajo.
# => ["CORD-98", "CORD-97", "CORD-95"]

#Ejercicio 5
produccion = [{dia: "lunes", cantidad: 15}, {dia: "martes", cantidad: 8}]
menor_produccion = produccion.sort_by{|p| p[:cantidad]}.first
#ordena por cantidad ascendente y tomael primero (el mas bajo)
# => {dia: "martes", cantidad: 8}




######4. group_by
#Agrupa los elementos en un Hash, usando como clave lo que devuelve el bloque para cada elemento.

numeros = [1, 2, 3, 4, 5, 6, 7, 8]
pares_impares = numeros.group_by {|n| n.even? ? "par" : "impar"}
# => {"impar"=>[1,3,5,7], "par"=>[2,4,6,8]}

# Ejercicio 1
tickets = [{proyecto: "CORD"}, {proyecto: "PREF"}, {proyecto: "CORD"}]
por_proyecto = tickets.group_by {|t| t[:proyecto]}
#Crea una clave por cada valor distinto de :proyecto, y mete ahi todos los que coinciden.
# => {"CORD"=>[{proyecto:"CORD"}, {proyecto:"CORD"}], "PREF"=>[{proyecto:"PREF"}]}

# Ejercicio 2
edades = [15,22,17,30,16]
por_mayoria =edades.group_by {|e| e>=18 ? "adulto": "menor"}
#El bloque devuelve "adulto" o "menor" segun cada edad, y agrupa bajo esas dos claves.
# => {"menor"=>[15,17,16], "adulto"=>[22,30]}

# Ejercicio 3
palets = [{estado: "curado"}, {estado: "produccion"}, {estado: "curado"}]
por_estado = palets.group_by {|p| p[:estado]}
# Agrupa segun el valor de :estado.
# => {"curado"=>[{...},{...}], "produccion"=>[{...}]}

#Ejercicio 4
numeros = [10,23,45,8,67,12]
por_paridad = numeros.group_by {|n| n.even?}
# El bloque devuelve true/false, esas son las claves del hash resultante.
# => {true=>[10,8,12], false=>[23,45,67]}

#
#Ejercicio 5
socios = [{campus: "Punta Arenas"}, {campus: "Puerto Natales"}, {campus: "Punta Arenas"}]
por_campus = socios.group_by {|s| s[:campus]}
#Agrupa segun el campus
# => {"Punta Arenas"=>[{...},{...}], "Puerto Natales"=>[{...}]}



#5. sum
#suma directa, mas corta que reduce cuando solo necesitas sumar
precios = [100,200,300]
puts precios.sum
#=> 600

#5 ejercicios explicados
# Ejercicio 1
horas = [4, 2, 6, 1]
total_horas = horas.sum
# Suma directa de todos los numeros del array.
# => 13

# Ejercicio 2
registros = [{minutos: 30}, {minutos: 45}, {minutos: 15}]
total_minutos = registros.sum [|r| r[:minutos]]
#sum con bloque: primero extrae r[:minutos] de cada hash, despues suma esos valores 
#=>90

# Ejercicio 3
palets_por_dia = [10, 15, 8, 20]
total_palets = palets_por_dia.sum
# Suma directa.
# => 53

#Ejercicio 4
precios_con_iva = [1000, 2000].sum { |p| p * 1.19 }
# El bloque transforma cada precio antes de sumarlo (le agrega IVA), despues suma los resultados.
#=>3570.0

# Ejercicio 5
socios_por_campus = {"Punta Arenas" => 40, "Puerto Natales" => 15}
total_socios = socios_por_campus.sum{|campus, cantidad| cantidad }
# En un hash, el bloque recibe clave y valor; acá solo se usa el valor para sumar.
#=> 55



#6. uniq
#Elimina duplicados de un array
numeros = [1, 2, 2, 3, 3, 3, 4]
puts numeros.uniq.inspect
# => [1, 2, 3, 4]

# 5 ejercicios explicados:
#Eejercicio 1
campus = ["Punta Arenas", "Punta Arenas", "Puerto Natales"]
campus_unicos = campus.uniq
#Elimina el duplicado de "Punta Arenas", deja solo una vez cada valor.
# => ["Punta Arenas", "Puerto Natales"]

# Ejercicio 2
ordenes = [{id: 1}, {id: 2}, {id: 1}]
ids_unicos = ordenes.map { |o| o[:id] }.uniq
#primero map extrae solo los ids: [1,2,1]. Despues uniq quita el duplicado
#=>[1,2]



#Ej 3
estados = ["abierto", "cerrado", "abierto", "abierto"]
estados_posibles = estados.uniq
# Deja cada valor distinto una sola vez.
# => ["abierto", "cerrado"]


# Ejercicio 4
numeros = [5, 5, 5, 5]
unicos = numeros.uniq
# Todos son iguales, uniq deja solo uno.
# => [5]

# Ejercicio 5
tickets_proyecto = ["CORD", "PREF", "LMA", "CORD", "PREF"]
proyectos_activos = tickets_proyecto.uniq
# Quita los duplicados de CORD y PREF.
# => ["CORD", "PREF", "LMA"]


###########
#7. uniq
###########
#Encuentra el elemento (no el valor, el elemento completo) con el valor minimo o maximo segun un criterio
candidatos = [{nombre: "A", flete: 500}, {nombre: "B", flete: 900}, {nombre: "C", flete: 300}]
candidatos = [{nombre: "A", flete: 500}, {nombre: "B", flete: 900}, {nombre: "C", flete: 300}]
ganador = candidatos.max_by {|c| c[:flete]}
#=> {nombre: "B", flete: 900}

#ejercicios explicados:
# Ejercicio 1
palets = [{codigo: "PAL-01", peso: 1200}, {codigo: "PAL-02", peso: 800}]
mas_pesado = palets.max_by { |p| p[:peso] }
#Compara el :peso de cada hash y devuelve el hash completo con el mayor.
# => {codigo: "PAL-01", peso: 1200}

# Ejercicio 2
socios = [{nombre: "Ana", edad: 40}, {nombre: "Luis", edad: 20}]
mas_joven = socios.min_by { |s| s[:edad] }
# Devuelve el hash completo con la menor edad.
# => {nombre: "Luis", edad: 20}


# Ejercicio 3
tickets = [{id: "CORD-95", horas: 3}, {id: "CORD-96", horas: 8}]
mas_demoroso = tickets.max_by { |t| t[:horas] }
# Devuelve el ticket con mas horas invertidas.
# => {id: "CORD-96", horas: 8}


# Ejercicio 4
precios = [1500, 800, 3000, 200]
el_mas_barato = precios.min_by { |p| p }
# Sin transformar nada, min_by devuelve directamente el numero menor.
# => 200

# Ejercicio 5
produccion_diaria = [{dia: "lunes", palets: 10}, {dia: "martes", palets: 25}]
mejor_dia = produccion_diaria.max_by { |p| p[:palets] }
# Devuelve el hash completo del dia con mas produccion.
# => {dia: "martes", palets: 25}



###########
#8. any? / all? / none?
###########
#preguntas booleanas sobre toda la coleccion. Devuelven true o false, nunca un array

cargas = [{orden_id: nil}, {orden_id: nil}]
puts cargas.all? {|c| c[:orden_id].nil?}
#=> true (todas cumplen)

#all? -> true si todos cumplen
#any? -> true si al menos uno cumple
#none?-> true si ninguno cumple

#5 ejercicios explicadso

#ejercicio 1
edades = [20, 25, 30]
todos_adultos = edades.all? {|e| e>=18}
# Revisa las 3 edades: 20>=18 si, 25>=18 si, 30>=18 si. Como TODAS cumplen -> true.
#=>true

# Ejercicio 2
stock = [0, 0, 5, 0]
hay_stock = stock_any? {|s| s>0}
# Revisa hasta encontrar UNA que cumpla. El 5 cumple -> se detiene, true.
# => true

# Ejercicio 3
tickets = [{cerrado: true}, {cerrado: true}, {cerrado: true}]
falta_alguno = tickets.none? {|t| !t[:cerrado]}
#none? pregunta: ninguno cumple "no cerrado"? Como todos estan cerrados, ninguno cumple "no cerrado" -> true
#=> true

# Ejercicio 4
palets = [{curado: true}, {curado: false}]
todos_curados = palets.all? { |p| p[:curado] }
# Uno tiene curado=false, entonces NO todos cumplen -> false.
# => false


# Ejercicio 5
horas = [10, 15, 20]
alguna_negativa = horas.any? { |h| h < 0 }
# Ninguna es negativa, entonces any? no encuentra ninguna que cumpla -> false.
# => false



###########
#9. flat_map
###########
#Como map, pero si cada elemento genera un array, los aplana todos en uno solo (en vez de un array de arrays)
grupos = [[1, 2], [3, 4], [5]]
puts grupos.flat_map { |g| g }.inspect
# => [1, 2, 3, 4, 5]

#5 ejercicios explicadso
# Ejercicio 1
registros = [{errores: ["falta nombre"]}, {errores: ["falta email", "falta edad"]}]
todos_los_errores = registros.flat_map {|r| r[:errores]}
# Cada hash da un array de errores. flat_map los junta en UN solo array plano, no array de arrays.
# => ["falta nombre", "falta email", "falta edad"]

# Ejercicio 2
tickets_por_dia = [["CORD-95", "CORD-96"], ["PREF-10"]]
todos_tickets = tickets_por_dia.flat_map {|t| t}
# Aplana los dos arrays internos en uno solo.
# => ["CORD-95", "CORD-96", "PREF-10"]

#Ejercicio 3
socios = [{campos_vacios: [:email]}, {campos_vacios: []}, {campos_vacios: [:telefono, :direccion]}]
campos_faltantes = socios.flat_map { |s| s[:campos_vacios] }
# Aplana los arrays, incluyendo el vacio (que no aporta nada).
# => [:email, :telefono, :direccion]


# Ejercicio 4
numeros = [1,2,3]
duplicados = numeros.flat_map{|n| [n,n]}
#Cada numero genera un array [n,n], flat_map los aplana todos juntos
# => [1, 1, 2, 2, 3, 3]


# Ejercicio 5
palets_por_pedido = [["PAL-01", "PAL-02"], ["PAL-03"], ["PAL-04", "PAL-05"]]
todos_palets = palets_por_pedido.flat_map { |p| p }
# Une los 3 arrays internos en uno solo.
# => ["PAL-01", "PAL-02", "PAL-03", "PAL-04", "PAL-05"]


###########
#10. each_with_index
###########
#Recorre el array dando acceso tambien al indice (posicion) de cada elemento.

frutas = ["manzana", "pera", "uva"]
frutas.each_with_index do |fruta, i|
  puts "#{i}: #{fruta}"
end
# 0: manzana
# 1: pera
# 2: uva

# Ejercicios explicados
# Ejercicio 1
tickets = ["CORD-95", "CORD-96", "CORD-97"]
tickets.each_with_index do |t, i|
  puts "Fila #{i}: #{t}"
end
# El bloque recibe dos parametros: el elemento y su posicion (empezando en 0).
# Fila 0: CORD-95
# Fila 1: CORD-96
# Fila 2: CORD-97

# Ejercicio 2
palets = ["PAL-01", "PAL-02"]
palets.each_with_index do |p, i|
  puts "Palet numero #{i + 1}: #{p}"
end
# Se le suma 1 al indice para mostrar numeracion desde 1 en vez de 0.
# Palet numero 1: PAL-01
# Palet numero 2: PAL-02


# Ejercicio 3
socios = ["Ana", "Luis"]
posiciones = socios.each_with_index.map { |s, i| "#{i}=#{s}" }
# each_with_index + map: transforma cada par (elemento, indice) en un string.
# => ["0=Ana", "1=Luis"]


# Ejercicio 4
horas_por_dia = [4, 6, 3]
horas_por_dia.each_with_index do |h, i|
  puts "Dia #{i}: #{h} horas"
end
# Dia 0: 4 horas
# Dia 1: 6 horas
# Dia 2: 3 horas

#Ejercicio 5
campus = ["Punta Arenas", "Puerto Natales"]
etiquetados = campus.each_with_index.to_a
# each_with_index sin bloque, seguido de to_a, arma pares [elemento, indice].
# => [["Punta Arenas", 0], ["Puerto Natales", 1]]


###########
#11. each_with_object
###########
#Parecido a reduce, pero pensado para construir una estructura (array o hash) en vez de acumular un valor simple.
pares = [[1,"uno"],[2n,"dos"],[3,"tres"]]
hash_resultado = pares.each_with_object({}) do |(id, nombre), h|
  h[id] = nombre
end
puts hash_resultado.inspect
# => {1=>"uno", 2=>"dos", 3=>"tres"}

# 5 Ejercicios explicados
# Ejercicio 1
socios =[{id: 1, nombre: "Ana"}, {id: 2, nombre: "Luis"}]
socios_por_id = socios.each_with_object({}) do |s, h|
  h[s[:id]] = s[:nombre]
end
# Construye un hash donde la clave es el id y el valor es el nombre.
# => {1=>"Ana", 2=>"Luis"}

# Ejercicio 2
palets = ["PAL-01", "PAL-02", "PAL-03"]
mayusculas = palets.each_with_object([]) do |p,arr|
  arr << p.upcase
end
# Construye un array nuevo con los palets en mayusculas.
# => ["PAL-01", "PAL-02", "PAL-03"]

# Ejercicio 3
tickets = [{proyecto: "CORD", horas: 3}, {proyecto: "CORD", horas: 5}, {proyecto: "PREF", horas: 2}]
horas_por_proyecto = tickets.each_with_object(Hash.new(0)) do |t, h|
  h[t[:proyecto]] += t[:horas]
end
# Hash.new(0) hace que cualquier clave nueva arranque en 0. Va sumando horas po  proyecto.
#=> {"CORD"=>8, "PREF"=>2}

#Ejercicio 4
numeros = [1, 2, 3, 4]
pares_dobles = numeros.each_with_object([]) do |n, arr|
  arr << n*2 if n.even?
end
#solo agrega al array los numeros pares multiplicados por 2.
# => [4, 8]

#Ejercicio 5
campus_ids = [["Punta Arenas", 1], ["Puerto Natales", 2]]
mapa_campus = campus_ids.each_with_object({}) do | (nombre, id), h|
  h[nombre] = id
end
# Construye un hash donde la clave es el nombre del campus y el valor es su id
# => {"Punta Arenas"=>1, "Puerto Natales"=>2}


###########
#12. tally
###########
#Cuenta cuantas veces aparece cada elemento, devuelve un Hash valor => cantidad
palabras = ["rojo","azul","rojo","verde","azul","rojo"]
conteo = palabras.tally
puts conteo.inspect
# => {"rojo"=>3, "azul"=>2, "verde"=>1}


# 5 Ejercicios explicados
# Ejercicio 1
proyectos = ["CORD", "PREF", "CORD", "LMA", "PREF"]
conteo_proyectos = proyectos.tally
# Cuenta cuantas veces aparece cada proyecto.
# => {"CORD"=>2, "PREF"=>2, "LMA"=>1}

# Ejercicio 2
edades = [20, 25, 20, 30, 25]
conteo_edades = edades.tally
# Cuenta cuantas veces aparece cada edad.
# => {20=>2, 25=>2, 30=>1}

# Ejercicio 3
notas_reviewer = ["Alex", "Alex", "Alex"]
conteo_reviewers = notas_reviewer.tally
# Todos son iguales, devuelve un hash con un solo par.
# => {"Alex"=>3}

# Ejercicio 4
palets = ["PAL-01", "PAL-02", "PAL-01", "PAL-03", "PAL-02"]
conteo_palets = palets.tally
# Cuenta cuantas veces aparece cada palet.
# => {"PAL-01"=>2, "PAL-02"=>2, "PAL-03"=>1}

# Ejercicio 5
tickets = ["CORD-95", "CORD-96", "CORD-95", "PREF-10"]
conteo_tickets = tickets.tally
# Cuenta cuantas veces aparece cada ticket.
# => {"CORD-95"=>2, "CORD-96"=>1, "PREF-10"=>1}



###########
#13.partition
###########
#Divide el array en dos arrays: los que cumplen la condicion y los que no (en ese orden)
numeros = [1, 2, 3, 4, 5]
pares,impares = numeros.partition {|n| n.even?}
puts pares.inspect # => [2, 4]
puts impares.inspect # => [1, 3, 5]

# 5 Ejercicios explicados
edades = [15, 20, 17, 25]
adultos,menores = edades.partition {|e| e >= 18}
# Separa en dos arrays: los que cumplen la condicion (adultos) y los que no (menores).
#adutlos = [20, 25], menores = [15, 17]

# Ejercicio 2
tickets = [{cerrado: true}, {cerrado: false}, {cerrado: true}]
cerrados,abiertos = tickets.partition {|t| t[:cerrado]}
#cerrados => [{cerrado: true}, {cerrado: true}], abiertos => [{cerrado: false}]

#Ejercicio 3
palets = [{curado: true}, {curado: false}, {curado: true}]
listos, pendientes = palets.partition {|p| p[:curado]}
#listos => [{curado: true}, {curado: true}], 
#pendientes => [{curado: false}]

#Ejercicio 4
numeros = [10, 15, 20, 25]
con_stock,sin_stock = numeros.partition {|n| n > 0}
#con_stock => [10, 15, 20, 25], sin_stock => []


#Ejercicio 5
horas = [2,8,4,10]
mas_de_5,menos_de_5 = horas.partition {|h| h > 5}
#mas_de_5 => [8, 10], menos_de_5 => [2, 4]