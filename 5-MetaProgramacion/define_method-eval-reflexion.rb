#Metaprogramacion
#Es como tener una caja de herramientas que te permite escribir codigo que crea o modifica otro codigo. mientras el programa se ejecuta.


##############################
#1. Metodos dinamicos:
##############################


#crear un metodo de ejecucion

class Persona
  %w[saludando corriendo].each do |accion|
    define_method(accion) do
      puts "Estoy #{accion} ahora"
    end
  end
end 
persona = Persona.new
persona.saludando
persona.corriendo

#Esto es util cuando no se sabe de antemano cuantos metodos vas a necesitar o como se van a llamar los metodos, por ejemplo generar metodos badados en datos de una bd



##############################
#2. Eval:
##############################
codigo = 'hola desde eval'
eval(codigo)

class Calculadora
  def Calcular
    operacion = "100+23"  "rm -r /importante"
    eval(operacion)
  end 
end

calc = Calculadora.new
puts calc.calcular

#tiene riesgos de seguridad, por ejemplo "rm -r /"
# en la depuracion se tienen dificultades ya que como el codigo esta en un str los errores son mas dificiles de poder rastrear. y tambien tenemos alternativas por ejemplo utilizar metodos dinamicos o bloques en lugar de eval siempre que se pueda  
#solo utilizar eval como en experimentos o herramientas internas, nunca en aplicaciones con entrada s de lo que seria usuario




##############################
#3. Reflexion
##############################
#te permite inspeccuionar y manupular objetos en tiempo de ejecucion


##############################
#3.1 Method_missing
##############################
#Metodo especial que ruby llama automaticamente cuando intentas usar un metodo que no existe

class Fantasma
  def method_missing(nombre_metodo, *args)
    puts "intentaste llamar a un metodo #{nombre_metodo} pero no existe"
  end
end
fantasma = Fantasma.new
fantasma.saludar("hola",10)

#¿Para que sirve este metodo?
#Para manejar errores de forma creativa o incluso simular metodos que no estan explicitiamente


##############################
#3.2 send
##############################
#metodo especial que te permita llamar a un metodo por su nombre, como si fuera un string o un simbolo.incluso llamar a ese metodo si es privado

class Secreto
  private
  def susurrar
    "soy un metodo privado"
  end
end
secreto = Secreto.new
puts secreto.send(:susurrar)

#Send es util cuando el nombre del metodo viene de una variable o cuando necesitas acceder a metodos privados para pruebas o realisar casos muy especiales 