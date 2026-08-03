class Persona
  def initialize(nombre)
    @nombre = nombre
  end

  def saludar
    puts "Hola, soy una persona."
  end

  private

  def secreto
    "soy un metodo secreto"
  end

  protected

  def mostrar_nombre
    puts @nombre
  end

  public

  def llamando_secreto
    puts "hola " + secreto
  end
end

# creacion de objetos
persona1 = Persona.new("Maria")
persona1.llamando_secreto


###
class Persona
  attr_reader :nombre
  attr_writer :edad
  attr_accessor :pais

  def initialize(nombre, edad,pais)
    @nombre = nombre
    @edad = edad
    @pais = pais
  end
  def edad
    "Edad de la persona: #{@edad}"
  end
end


#-------------
begin
  #El codigo que puede lanzar un error o una excepcion
rescue
  #El codigo que se ejecuta si ocurre una excepcion
ensure
  #el codigo que se ejecuta siempre, haya ocurrido una excepcion o no
end

#ejemplo
def dividir(a,b)
  begin
    resultado = a / b
    puts "El resultado de la division es: #{resultado}"
  rescue ZeroDivisionError => e
    puts "Error: No se puede dividir por #{e.message}"
  rescue => e
    puts "Ocurrio un error inesperado: #{e.message}"
  ensure
    puts "Ejecucion finalizada."
  end
end
puts dividir(10, 2) # Ejemplo de division correcta
puts dividir(10, 0) # Ejemplo de division por cero


#---------excpciones personalizadas
class EdadInvalidaError < StandardError
end

class RegistroUsuario
  def registrar_usuario(nombre, edad)
    raise EdadInvalidaError, "La edad no puede ser negativa" if edad < 0
    puts "Usuario registrado: #{nombre}, Edad: #{edad}"
  rescue EdadInvalidaError => e
    puts "Error: #{e.message}"
  end
end

RegistroUsuario.new.registrar_usuario("Juan", 25) # Registro exitoso
RegistroUsuario.new.registrar_usuario("Ana", -5)  # Lanza EdadInvalidaError

