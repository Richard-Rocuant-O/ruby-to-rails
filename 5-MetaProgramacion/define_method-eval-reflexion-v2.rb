#Metaprogramacion - la idea general
#codigo que escribe o modifica otro codigo mientras el programa corre- En vez de escribir cada metodo a mano, el propio programa genera metodos, o inspecciona/llama cosas por nombre en tiempo real.

##########################
#1.Metodos dinamicos (define_method)
##########################

#define_method te permite crear metodos nuevos mientras el programa corre, sin escribir 'def NombreDelMetodo' a mano - le pasas un nombre (puede venir de una variable) y un bloque con la logica del metodo.

class Persona
  define_method(:saludar) do
    puts "hola"
  end
end 

p = Persona.new
p.saludar
#=> Hola

#lo mismo que:
class Persona
  def saludar
    puts "Hola"
  end
end

#La diferencia es que con 'def', el nombre del metodo (saludar) esta fijo, escrito a mano. Con 'define_method', ese nombre puede ser una 'variable' - y ahi es donde se pone util.

#El caso real donde sirve - cuando no sabes de antemano cuantos metodos necesitas ni como se van a llamar:

class Persona
  %w[saludando corriendo comiendo].each do |accion|
    define_method(accion) do
      puts "Estoy #{accion} ahora"
    end
  end
end

p = Persona.new
p.saludando  # => Estoy saludando ahora
p.corriendo  # => Estoy corriendo ahora
p.comiendo   # => Estoy comiendo ahora

#Fijate: nunca escribiste 'def saludando', 'def corriendo', def comiendo - el '.each' genero los 3 metodos automaticmaente, uno por cada palabra del array.

#Sobre lo que se investigo - historicamente, tecnicas de metaprogramacion como method_missing eran consideradas mas lentas que definir metodos explciitos. 'define_method' es la alternativa mas rapida y mas segura a 'metthod_missing' cuando ya sabes de antemano cual es el conjunto de nombres que vas a necesitas (aunque no sepas cuantos seran hasta ejecutar el codigo).

#analogia con codigo normal en produccion
class ValidadorSocio
  def initialize
    @errores = [] #@errores -> variable de instancia (guarda el array real)
  end
  attr_accessor :errores # :errores -> symbol (le dice a Ruby: "genera un metodo llamado errores")

  # region Symbol como nombre de metodo (explicacion larga)

  # 1. Que genera attr_accessor/attr_reader por detras
  # @errores sigue siendo variable de instancia todo el rato - nunca se convierte en symbol.
  # 'attr_reader :errores' genera esto por debajo:
  #   def errores
  #     @errores
  #   end
  # O sea: symbol :errores es solo el nombre que le pones al metodo getter. Ese metodo,
  # cuando se ejecuta, devuelve la variable de instancia @errores. Son dos identificadores
  # relacionados por convencion (mismo nombre, sin la arroba).

  # 2. Symbol como referencia al nombre de un metodo (no solo como clave de hash)
  #   attr_reader :errores          # :errores  -> nombre de metodo a generar
  #   attr_writer :edad             # :edad     -> nombre de metodo a generar
  #   define_method(:saludar)       # :saludar  -> nombre de metodo a crear
  #   secreto.send(:susurrar)       # :susurrar -> nombre de metodo a llamar
  # En los 4 casos, el simbolo no es un dato - es una etiqueta que apunta al nombre de un
  # metodo. Ruby internamente lo usa para saber "cual metodo generar" o "cual metodo llamar".
  # Un simbolo sirve como identificador: algo que Ruby necesita reconocer, comparar o buscar
  # por nombre. Ya sea la clave de un hash, el nombre de un metodo a crear, o el nombre de un
  # metodo a invocar, todos son el mismo caso de uso: una etiqueta fija, no un dato que cambia.

  # 3. Ejemplo con send
  #   class Persona
  #     def saludar
  #       puts "hola"
  #     end
  #   end
  #
  #   p = Persona.new
  #   p.send(:saludar)
  #   # => hola
  # :saludar es literalmente el nombre del metodo 'saludar', empaquetado como simbolo para
  # poder pasarselo a send como argumento.

  # endregion
  def 

#De nuevo 
class ValidadorSocio
  def initialize
    @errores = [] #crea un array vaciop para ir guardando los mensajes de error
  end

  attr_reader :errores #genera el metodo "errores " para poder leer @errores desde afuera

  def validar_nombre(valor)
    # revisa si el valor es nil o si es un string vacio (o solo espacios). Si alguna es true, guarda el mensaje de error; si no, guarda nil
    error = valor.nil? || valor.strip.empty? ? "El nombre no puede estar vacio" : nil
    @errores << error if error # si "error" no es nil, lo agrega al array @errores
    error.nil? #devuelve true si NO hubo error, false si SI hubo error
  end
  def validar_edad(valor)
    error = valor.nil? || valor <0 ? "la edad no puede ser negativa": nil
    @errores << error if error
    error.nil?
  end

  def validar_campus(valor)
    error = valor.nil? ? "Debe seleccionar un campus" : nil
    @errores << error if error
    error.nil?
  end
  def validar_estado(valor)
    # revisa si el valor esta dentro de la lista permitida. Si SI esta, guarda nil; si NO esta, guarda el mensaje de error
    error = %w[activo moroso suspendido].include?(valor) ? nil : "Estado invalido"
    @errores << error if error# si "error" no es nil, lo agrega al array @errores
    error.nil?                                   # devuelve true si NO hubo error, false si SI hubo error
  end
  def valido?
    @errores.empty?                              # devuelve true si el array de errores esta vacio (nada fallo)
  end
end

validador = ValidadorSocio.new # crea un nuevo objeto ValidadorSocio, con @errores = []

validador.validar_nombre("")                     # nombre vacio -> agrega error al array
validador.validar_edad(-5)                       # edad negativa -> agrega error al array
validador.validar_campus("Punta Arenas")         # campus valido (no es nil) -> NO agrega error
validador.validar_estado("vip")                  # "vip" no esta en la lista permitida -> agrega error

puts validador.valido?
# => false                                        # porque @errores NO esta vacio (hay 3 errores)

puts validador.errores
# => ["El nombre no puede estar vacio", "La edad no puede ser negativa", "Estado invalido"]


#Que es '%w[]'
#Es un atajo para escribir un array de str sin tener que poner comillas ni comas - creando un array de strings escribiendo cada comilla explícitamente es tedioso, y el estilo de la comunidad Ruby recomienda usar %w en vez de la sintaxis literal de array cuando necesitas crear un array de strings simples (sin espacios ni caracteres especiales dentro).

#forma normal
lenguajes = ["ruby", "php", "javascript"]

# con %w (equivalente exacto)
lenguajes = %w[ruby php javascript]


#Mis codigo pero aplicando 'define_method'
class ValidadorSocio
  #Hash donde cada clave es un symbol (nombre del campo) y cada valor es una lambda
  #con la regla de validacion de ese campo. Cada llamada recibe "valor" y devuelve 
  #nil si esta OK, o un string con el mensaje de error si no lo esta.
    CAMPOS_REQUERIDOS = {
    nombre: ->(valor) { valor.nil? || valor.strip.empty? ? "El nombre no puede estar vacio" : nil },
    edad:   ->(valor) { valor.nil? || valor < 0 ? "La edad no puede ser negativa" : nil },
    campus: ->(valor) { valor.nil? ? "Debe seleccionar un campus" : nil },
    estado: ->(valor) { %w[activo moroso suspendido].include?(valor) ? nil : "Estado invalido" }
  }
  def initialize
    @errores = [] # array vacio donde se van acumulando los mensajes de error
  end

  attr_reader :errores # genera el metodo "errores" para leer @errores desde afuera

  #Recorre el hash CAMPOS_REQUERIDOS. Por cada par (campo, regla), genera un metodo nuevo llamado "validar_<campo>" (ej: validar_nombre, validar_edad, etc.)
  #sin tener que escribir cada uno a mano con "def"
    CAMPOS_REQUERIDOS.each do |campo, regla|
    define_method("validar_#{campo}") do |valor|
      error = regla.call(valor)                    # ejecuta la lambda de ese campo con el valor recibido
      @errores << error if error                    # si devolvio un mensaje (no nil), lo agrega al array
      error.nil?                                     # true si NO hubo error, false si SI hubo error
    end

    def valido?
      @errores.empty?                                 # true si nunca se agrego ningun error
    end
  end

validador = ValidadorSocio.new                      # crea el objeto, @errores arranca en []

validador.validar_nombre("")                          # string vacio -> agrega error
validador.validar_edad(-5)                            # numero negativo -> agrega error
validador.validar_campus("Punta Arenas")              # no es nil -> NO agrega error
validador.validar_estado("vip")                        # no esta en la lista permitida -> agrega error

puts validador.valido?
# => false                                            # porque @errores tiene elementos

puts validador.errores
# => ["El nombre no puede estar vacio", "La edad no puede ser negativa", "Estado invalido"]


##########################
#2.eval
##########################
#eval es un metodo de Ruby que toma un string de texto y lo ejecuta como si fuera codigo Ruby real
codigo = 'puts "hola"'
eval(codigo)
# => hola

#idea central: normalmente, el codigo que escribes en un archivo '.rb' se ejecuta directamente - Ruby lo lee y lo corre. Pero con 'eval' puedes tener codigo Ruby guardado como texto (un string), y decirle a Ruby "toma este texto y ejecutalo ahora, como si fuera codigo normal"

#Ejemplo simple para verlo bien:
eval("puts 1 + 1")
# => 2
#Esto es equivalente a haber escrito directamente:
puts 1+1

#¿Para que sirve en la practica? Casi nunca se usa en codigo de produccion normal, porque es peligroso (como ya vimos) - pero existe para casos como:
#- Herramientas de desarrollo o consolas interactivas (como la consola de Rails, rails console, que ejecuta el texto que escribes)
#-Experimentos rapidos
#-motores de reglas muy especificos, donde el string viene de una fuente 100% controlada

#El riesgo — por qué casi nunca se usa fuera de esos casos: si el string que le pasas a eval viene de afuera (input de un usuario, un formulario, una API), esa persona podría escribir código malicioso en vez de una operación normal, y eval lo ejecutaría igual, sin preguntar:

texto_del_usuario = "system('rm -r /carpeta_importante')"
eval(texto_del_usuario)
# ejecutaria ese comando destructivo, porque eval no distingue "codigo bueno" de "codigo malo"


##############################
#3. Reflexion
##############################
#te permite inspeccuionar y manupular objetos en tiempo de ejecucion


#3.1 method_missing
#Es un metodo especial que Ruby llama automaticamente cuando intentas usar un metodo que no existe en un objeto, en vez de simplemente explotar con error. Cuando Ruby hace una busqueda de metodo y no puede encontrar uno en particular, llama a un metodo llamado method_missing() en el receptor original.

#Normalmente, sin method_missing sobreescrito:
class Persona
end

p = Persona.new
p.saludar
# => NoMethodError: undefined method 'saludar' for #<Persona>

#Ruby busca el método saludar en la clase Persona, no lo encuentra, y por defecto revienta con ese error. BasicObject#method_missing() responde lanzando un NoMethodError — eso es lo que pasa "por debajo" siempre, aunque nunca lo veas escrito.

#Cuando sobreescribe 'method_missing', interceptas ese momento antes de que explote:
class Fantasma
  def method_missing(nombre_metodo, *args)
    puts "Intentaste llamar a #{nombre_metodo} pero no existe"
  end
end
fantasma = Fantasma.new
fantasma.saludar("hola",10)
#=> Intentaste llamar a saludar pero no existe

#nombre_metodo recibe el nombre del metodo que intentaste usar (:saludar), y *args captura cualquier argumento que le hayas pasado. En vez de explotar, tu codigo decir que hacer.

#Donde sirve en el trabajo
#asi funcionan los "dynamics finder" de Rails, method_missing es lo que hace posible las 'dynamics finders' de Rails, como find_by_name, bind_by_age, tc. Nadie en Rails escribio a mano un metodo 'find_by_email', find_by_dni, find_by_loquesea - cuando llamas Usuario.find_by_email("x@x.com"), Rails intercepta esa llamada con 'method_missing', se da cuenta de que empieza con 'method_missing', se da cuenta de que empieza con 'find_by', extrae 'email', y arma la query automaticamnte.

class ConsultaSocio
  def initialize(socios)
    @socios = socios #guarda el array de socios recibido en la variable de instancia @socios
  end

  #Ruby llama automaticmaente a ese metodo cuando alguien intenta usar metodo que NO existe en ConsultaSocio (ej: buscar_por_campus)
  def method_missing(nombre_metodo, *args)
    # nombre_metodo = el nombre del metodo que se intento llamar (viene como symbol, ej: :buscar_por_campus)
    # *args = un array con todos los argumentos que se le pasaron a ese metodo (ej: ["Puerto Natales"])

    if nombre_metodo.to_s.start_with?("buscar_por_")
      # nombre_metodo.to_s convierte el symbol a string: :buscar_por_campus -> "buscar_por_campus"
      # start_with?("buscar_por_") revisa si el string empieza con ese texto -> true en este caso

      campo = nombre_metodo.to_s.sub("buscar_por_", "").to_sym
      # .sub("buscar_por_", "") reemplaza "buscar_por_" por nada, dejando solo "campus"
      # .to_sym convierte ese string "campus" de vuelta a symbol :campus
      # campo ahora vale :campus

      valor = args.first
      # args es el array de argumentos, ej: ["Puerto Natales"]
      # .first toma el primer elemento -> valor = "Puerto Natales"

      @socios.find { |s| s[campo] == valor }
      # recorre el array @socios buscando el PRIMER hash donde la clave :campus
      # tenga el valor "Puerto Natales", y lo devuelve
    else
        super
        #si el metodo llamado NO empezaba con "buscar_por_", no lo manejamos aca
        #super deja que Ruby haga lo que haria normalmente: lanzar NoMethodError
    end
  end
end

socios = [
  {nombre: "Juan", campus: "Punta Arenas"},
  {nombre: "Ana", campus: "Puerto Natales"}
]
consulta = ConsultaSocio.new(socios)                    # crea el objeto, @socios queda con el array de arriba

consulta.buscar_por_campus("Puerto Natales")
# Ruby busca un metodo llamado "buscar_por_campus" en ConsultaSocio -> NO existe
# Como no existe, Ruby automaticamente llama a method_missing(:buscar_por_campus, "Puerto Natales")
# Dentro de method_missing: nombre_metodo = :buscar_por_campus, args = ["Puerto Natales"]
# Como "buscar_por_campus" empieza con "buscar_por_" -> entra al if
# campo = :campus, valor = "Puerto Natales"
# @socios.find busca el hash con campus == "Puerto Natales" -> encuentra el de Ana
# => {nombre: "Ana", campus: "Puerto Natales"}

#Si llamaras algo que no encaja en el patrón:
consulta.volar_a_la_luna

#1. Ruby no encuentra volar_a_la_luna, dispara method_missing(:volar_a_la_luna)
#2. "volar_a_la_luna".start_with?("buscar_por_") → false
#3. Entra al else, ejecuta super
#4. super deja que Ruby haga lo que haría normalmente (sin tu method_missing) → lanza NoMethodError: undefined method 'volar_a_la_luna'




#3.2 send

class Secreto
  private                                    # todo lo que se defina DESPUES de esta linea es privado
  def susurrar
    "soy un metodo privado"
  end
end

secreto = Secreto.new
puts secreto.send(:susurrar)

#Primero, qué significa private en Ruby. Todo método definido después de la palabra private (sin argumentos) dentro de la clase se vuelve privado — solo se puede llamar desde adentro del propio objeto, no desde afuera con objeto.metodo.

#Prueba de que es privado — sin send, esto explota:
secreto = Secreto.new
secreto.susurrar
# => NoMethodError: private method 'susurrar' called for #<Secreto>

# Ruby te bloquea, literalmente porque marcaste ese método como privado.
# Ahora, send. send es un método que te permite llamar a otro método por su nombre, pasado como símbolo o string, y se salta la restricción de privacidad.
puts secreto.send(:susurrar)
# => soy un metodo privado

#Los dos usos reales que ya identificaste correctamente en tu documento:
#1.Testear métodos privados — en tus tests con Pest/PHPUnit ya conoces la necesidad de a veces verificar el comportamiento interno de un método que no debería ser público en producción. send te permite hacer eso en Ruby sin cambiar la visibilidad del método solo para poder testearlo.

#2.El nombre del método viene de una variable — por ejemplo, procesar dinámicamente distintos campos de un formulario, donde el nombre del método a llamar depende de un dato que llega en tiempo de ejecución (no lo sabes de antemano al escribir el código).