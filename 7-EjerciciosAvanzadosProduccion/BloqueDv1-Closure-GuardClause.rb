###Closure
=begin
Es un trozo de codigo (funcion/bloque) que recuerda las variables que existian a su alrededor cuando fue creado, incluso si se ejecuta despues, en otro lugar.
=end
def contador
  cuenta = 0
  -> { cuenta += 1 }
end

tick = contador
tick.call  # => 1
tick.call  # => 2

=begin
La lambda "recuerda" cuenta, aunque contador ya terminó de ejecutarse. Bloques, procs y lambdas son closures en Ruby.
=end

###Guard clause (clausula de guarda)
=begin
Una guard clausa es una validacion al inicio de un metodo que corta la ejecucion temprano si algo no cumple, evitando if/else profundos
=end

#CON guard clause (mas limpio)
# CON guard clause (mas limpio)
def procesar_socio(socio)
  return "Socio invalido" if socio.nil?
  return "Socio moroso" if socio[:moroso]

  "Procesando #{socio[:nombre]}"
end

# SIN guard clause (mismo resultado, mas anidado)
def procesar_socio(socio)
  if socio.nil?
    "Socio invalido"
  else
    if socio[:moroso]
      "Socio moroso"
    else
      "Procesando #{socio[:nombre]}"
    end
  end
end