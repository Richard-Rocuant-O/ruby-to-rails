### Variable de Instancia

## Variable Instancia
# dato que le pertenece a un objeto específico, no a la clase en general. Se escribe con una sola arroba: @edad.

# La idea es simple: cuando creas un objeto con .new, ese objeto puede guardar sus propios valores internos, y esos valores no se mezclan con los de otro objeto de la misma clase. Cada instancia tiene su propia "caja" de variables.

class Persona
    def initialize
        @edad =30
    end
    def mostrar_edad
        puts @edad
    end
end
juanito = Persona.new
juanito.mostrar_edad #Imprimire 30
#1. Persona.new ejecuta automaticamente el metodo initialize

#2. Dentro de initialize, se crea @edad y se le asigna 30. Esa variable queda guardada dentro del objeto juanito, no en la clase Persona. Por eso se llama variable de instancia.

#3. mostrar_edad es otro metodo de la misma clase, y puede leer @edad porque esta dentro del mismo objeto - las variables de isntancia son visibles entre todos los metodos de instancia de esa clase

#4. Si creas otro objeto, por ejemplo Pedro = Persona.new, ese pedro tendra su propio @edad independiente. Si mas adelante cambias @edad de juanito, no afectara a pedro. Cada objeto tiene su propia "caja" de variables.

#------------------
### Variable de clase
# La diferencia central con @edad es que acá el dato ya no le pertenece a un objeto en particular, sino a la clase completa. Es una sola caja compartida por todos los objetos que se creen.
class Persona
    @@total = 0
    def initialize
        @@total += 1
    end
    def self.mostrar_total
        puts @@total
    end
end
persona1 = Persona.new
Persona.mostrar_total #Imprimira 1
# 1. @@total = 0 se define a nivel de clase, fuera de cualquier metodo. Existe desde que se carga la clase, incluso antes de crear algun objeto.
# 2. Cada vez que se ejecuta initialize (o sea, cada Persona.new), se suma 1 a @@total. Como es una sola variable compartida, no se reinicia con cada objeto nuevo.
# 3. self.mostrar_total es un método de clase (no de instancia), por eso se llama como Persona.mostrar_total y no persona1.mostrar_total. Puede leer @@total sin necesidad de que exista ningún objeto.
# 4. Si creas persona2 = Persona.new, @@total pasa a valer 2 — y ese 2 lo va a ver cualquier objeto o el propio Persona.mostrar_total, porque es la misma caja para todos.


### Variable global
$global_variable = 10
class Class1
    def print_global
        puts "Global variable in Class1: #{$global_variable}"
    end
end
class1obj = Class1.new
class1obj.print_global #Imprimira 10

# Por que casi nadie la usa en produccion: si cualquier metodo de cualquier clase puede modificarla, es muy dificil rastrear quien cambio el valor y cuando. Es la fuente tipica de bugs "fantasma" - cambia algo en un archivo y rompe en otro completamente distinto.

# Seria como en Laravel usaras una variable de sesión o config() global que cualquier controller, cualquier job, cualquier listener puede sobrescribir libremente sin pasar por ningún contrato — básicamente el opuesto a la inyección de dependencias que usas en tu arquitectura DDD/hexagonal.