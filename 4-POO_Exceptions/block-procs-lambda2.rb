##############################
#1.Bloque
##############################
#Un trozo de codigo, entre {} o do...end, que le entragas a un metodo al llamarlo. Un bloque de Ruby es una seleccion de codigo dentro 'do...end', o entre llaves '{}'. No es un objeto - no lo puedes guardar en una variable ni pasarlo dos veces.

def mi_metodo
  yield
end

mi_metodo { puts "Hola desde el bloque" }
mi_metodo do
  puts "Hola desde el bloque"
end

##############################
#############2.Proc
##############################

#Es un objeto que encapsula un bloque de codigo y puede ser guardado en una variable, pasado como argumento. o llamado en cualquier momento. A diferencia del bloque puro, un Proc si es un objeto - lo puedes guardar, reutilizar, pasar de un lado a otro.

def saludar
  yield
end
saludar { puts "Hola desde el bloque" }

#Este {puts "Hola desde el bloque "} solo existe en el momento exacto en que se llama a 'saludar'. No lo puedes guardar en ninguna variable pára usarlo despues. Si quieres guardar un bloque de codigo para usarlo despues, necesitas un Proc.

#Ahora, la diferencia con Proc:
mi_proc = Proc.new { puts "Hola desde el Proc" }

#Aca 'Proc.new {puts "hola"}' crea un objeto que guarda ese trozo de codigo adentro, y ese objeto lo estas asignando a una variable llamda 'mi_proc' - exactamente igual que cuando asignas 'numeeros = [1,2,3]' a una variable

#La diferencia clave: como es un objeto guardado en una variable, ahora puedes usarlo cuando quieras, las veces que quieras:

mi_proc.call   # => hola
mi_proc.call   # => hola  (lo llamas de nuevo, sin repetir el codigo)
mi_proc.call   # => hola  (y otra vez)

#.call es la forma de decirle al Proc: "ejecuta ahora el codigo que tienes guardado adentro"

# Bloque puro: se usa una sola vez, en el momento
saludar { puts "hola" }

# Proc: se guarda, se puede reutilizar
mi_proc = Proc.new { puts "hola" }
mi_proc.call
mi_proc.call

#¿Para qué sirve esto en la práctica? Piensa en algo simple: quietres tener una "receta" guardada para usarla en distintos momentos de tu programa

formatear_moneda = Proc.new { |valor| "$#{valor}" }

puts formatear_moneda.call(1000)   # => $1000
puts formatear_moneda.call(2500)   # => $2500

#Sin Proc, tendirasa que '$#{valor}' cada vez que necesitaras formatear un numero. Con Proc, escribes la logica una sola vez, la guardas en 'formatear_moneda' y la resuas donde quieras.



##############################
#############3.Lambda
##############################

#Lambda es practicamente lo mismo que un Proc - un objeto que guardas en una variable y llamas con .call cuando quieras - pero con dos reglas extra que la hacen comportarse mas como un metodo normal.

#Primero, lo que tienen en comun (igual que un Proc)
mi_lambda = -> {puts "Hola"}
mi_lambda.call #=> hola
mi_lambda.call   # => hola  (se puede reutilizar, igual que un Proc)

#-> es simplemente otra forma de escribir "esto es una lambda" (existe tambien lambda{}, hacen lo mismo). Iugal que con Proc, guardas el trozo de codigo en una variable y lo ejecutas con .call cuando quieras.

#Ahora, las dos diferenciales reales con Proc
#1. La Lambda exige la cantidad exacta de argumentso
mi_proc = Proc.new { |x, y| puts "x=#{x}, y=#{y}" }
mi_proc.call(1)
# => x=1, y= (no explota, "y" queda vacio/nil, Ruby no que queja)

mi_lambda = ->(x, y) { puts "x=#{x}, y=#{y}" }
mi_lambda.call(1)
# => ERROR: wrong number of arguments (given 1, expected 2)

#El Proc es "relajado" — si le faltan o sobran argumentos, no reclama. La lambda es estricta, como un método normal — si defines que necesita 2 argumentos, tienes que darle exactamente 2.


#2. El return se comporta distinto. Este es el mas importante y el que causa bugs si no lo sabes

def con_proc
  p = Proc.new {return 10}
  p.call
  puts "Esto nunca se imprime"
end

def con_lambda
  l = -> {return 10}
  l.call
  puts "Esto SI se imprime"
end 

con_proc #El return del proc mata TODO el metodo con proc, la linea del puts nunca corre
con_lambda #el return de la lambda solo termna a la lambda, el metodo con_lambda sigue normal

#Con un Proc, cuando adentro haces return, no solo sale del Proc - sale de todo el metodo donde esta ese Proc, como si hubieras puesto el return directamente. Con una lambda, el reutn solo corta la lambda misma, y el metodo sigue su curso normal despues.

#Resumiendo la relacion entre los tres:
Bloque  →  se usa una vez, no se guarda
  ↓
Proc    →  se guarda en variable, se puede reutilizar, pero es "relajado" (no valida argumentos, return raro)
  ↓
Lambda  →  como Proc, pero se comporta como un método real (valida argumentos, return normal)