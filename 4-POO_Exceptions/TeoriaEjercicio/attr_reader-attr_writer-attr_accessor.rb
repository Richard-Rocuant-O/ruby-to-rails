# attr_reader/attr_writer/attr_accessor

############################
########attr_reader#########
############################

#Paso 1 - un objeto que guarda un dato adentro
class Persona
  def initialize(nombre)
    @nombre = nombre
  end
end

juan = Persona.new("Juan") # esto es un comentario
#Juan es un objeto que tiene guardado adentro @nombre = "Juan".
#Ahora, se puede hacer esto?
puts juan.nombre # Esto no funciona, porque no hay un metodo para acceder a @nombre
#@nombre esta guardado adentro del objeto, pero no existe ningun metodo llamdado 'nombre' que de deje sacarlo de ahi. Es como si 'nombre' estuviera guardado en una caja fuerte y no tuvieramos la llave para abrirla. Para poder acceder a @nombre, necesitamos un metodo que nos de acceso a el.

#Paso 2 - creamos la 'llave' a mano
class Persona
  def initialize(nombre)
    @nombre = nombre
  end

  def nombre
    @nombre
  end
end

juan = Persona.new("Juan")
puts juan.nombre
# => Juan

#Ahora si funciona. ¿Que agregamos? Un metodo nuevo llamado 'nombre', cuyo unico trabajo es devolver el valor de @nombre. Ahora, cuando hacemos juan.nombre, estamos llamando al metodo 'nombre', que nos devuelve el valor de @nombre.

#Ahora la pregunta clave: ¿de donde sale 'Attr_reader'

#'attr_reader :nombre' hace exactamente esto:
#
# def nombre
#   @nombre
# end

##############################
##########attr_accessor##########
############################## 

#Paso 1 - el problema
class Persona
  def initialize(nombre)
    @nombre = nombre
  end

  def nombre
    @nombre
  end
end

juan = Persona.new("Juan")
puts juan.nombre
# => Juan

#Con esto puedes leer @nombre. Peros si intentas cambiarlo desde afuera:
juan.nombre = "Pedro" # Esto no funciona, porque no hay un metodo 'nombre=' que nos deje cambiar el valor de @nombre

#Paso 2 - creamos el metodo 'nombre=' a mano
class Persona
  def initialize(nombre)
    @nombre = nombre
  end

  def nombre
    @nombre
  end

  def nombre=(nuevo_nombre)
    @nombre = nuevo_nombre
  end
end

juan = Persona.new("Juan")
puts juan.nombre
# => Juan

juan.nombre = "Pedro"
puts juan.nombre
# => Pedro

#y attr_accesor :nombre es el atajo para tener AMBOS al mismo tiempo (el de leer y el de escribir juntos)

#attr_accessor :nombre es lo mismo que escribir:
def nombre
  @nombre
end

def nombre=(nuevo_nombre)
  @nombre = nuevo_nombre
end


#Ejemplo integrador
class Socio
  attr_reader :id, :nombre #solo lectura: no queremos que se puedan reasignar desde afuera
  attr_writer :estado #solo escritura: se puede cambiar el estado, pero nunca leerlo directo
  attr_accessor :campus #lectura y escritura: se puede leer y escribir desde afuera

  def initialize(id, nombre, estado, campus)
    @id = id
    @nombre = nombre
    @estado = estado
    @campus = campus
  end
end
socio = Socio.new(1, "Juan Perez", "activo", "Punta Arenas")

#attr_reader -> solo lectura
puts socio.id # => 1
puts socio.nombre # => "Juan Perez"
socio.id = 2 # Esto no funciona, porque id es solo lectura

#attr_writer -> solo escritura
socio.estado = "moroso" # Esto funciona, porque estado es solo escritura
puts socio.estado # Esto no funciona, porque estado es solo escritura

#attr_accessor -> lectura y escritura
puts socio.campus # => "Punta Arenas"
socio.campus = "Santiago" # Esto funciona, porque campus es lectura y escritura
puts socio.campus # => "Santiago"


