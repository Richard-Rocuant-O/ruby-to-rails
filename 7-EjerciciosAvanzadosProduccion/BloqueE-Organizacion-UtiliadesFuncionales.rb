###Bloque E — Organizacion y utilidades funcionales


##------------------------------------------------------
##------------------------------------------------------
##------------------------------------------------------
##------------------------------------------------------
##------------------------------------------------------
#9. Modulos como namespace + module_function
#Namespace puro (sin mixin):
module CargaConsolidadoServices
  class Cerrar
    def self.call(id)
      "Cerrando consolidado #{id}"
    end
  end
end

CargaConsolidadoServices::Cerrar.call(42)

=begin
esto ya se vio con '::' - el modulo aqui no comparte comportamiento (no hay include), solo agrupa clases relacionadas bajo un nombre comun, evitando que una clase llamamda simplemente 'Cerrar' choque con otra 'Cerrar' de otro dominio 

=end


#1. Namespace puro

module CargaConsolidadoServices
  class Cerrar
    def self.call(id)
      "Cerrando consolidado #{id}"
    end
  end
end

CargaConsolidadoServices::Cerrar.call(42)
=begin

module CargaConsolidadoServices — es solo un contenedor, una "carpeta" con nombre. No hace nada por sí solo, solo agrupa lo que está adentro.

class Cerrar — dentro del módulo, defines una clase normal, como cualquier otra que ya conoces.

def self.call(id) — un método de clase normal (ya lo viste, self. = método de clase, se llama sin .new).

CargaConsolidadoServices::Cerrar.call(42) — para llamar la clase, tienes que usar el :: (ya visto): "busca Cerrar adentro de CargaConsolidadoServices".

¿Por qué molestarse en meterla dentro de un módulo?:
Imagina que en otra parte del proyecto también existe una clase Cerrar, pero para otro dominio distinto (por ejemplo, cerrar sesiones, o cerrar tickets):
=end
module SesionServices
  class Cerrar
    def self.call(sesion_id)
      "Cerrando sesion #{sesion_id}"
    end
  end
end

#Sin el namespace, tendrías dos clases con el mismo nombre Cerrar chocando entre sí — Ruby no sabría a cuál te refieres. Con el módulo, cada una vive en su propio "cajón":

CargaConsolidadoServices::Cerrar.call(42)   # cierra un consolidado
SesionServices::Cerrar.call(7)               # cierra una sesion

#Son clases completamente distintas, ambas llamadas Cerrar, sin conflicto — porque viven en módulos distintos.
#Nota sobre "sin mixin": ya viste que include mete métodos de un módulo dentro de una clase (como Enumerable). Acá no hay ningún include — el módulo no le da comportamiento a nada, solo sirve de "dirección" para encontrar la clase.

#2. module_function
module PatenteDv
  module_function

  def calcular(base)
    base.chars.map(&:to_i).sum
  end

  def valido?(base, dv)
    calcular(base) == dv
  end
end

#El problema que resuelve - sin 'module_function'
module PatenteDv
  def calcular(base)
    base.chars.map(&:to_i).sum
  end
end

PatenteDv.calcular("123")
# ERROR: undefined method 'calcular' for PatenteDv:Module

=begin
Si defines un método normal dentro de un módulo (sin self.), ese método no se puede llamar directo sobre el módulo — solo funciona si otra clase hace include PatenteDv (como pasa con Enumerable). Como no quieres incluirlo en ninguna clase, solo llamarlo directo, esto explota.
=end

#La solución obvia sería self. en cada método, como ya sabes:
module PatenteDv
  def self.calcular(base)
    base.chars.map(&:to_i).sum
  end

  def self.valido?(base, dv)
    calcular(base) == dv
  end
end

PatenteDv.calcular("123")   # funciona

#Esto funciona bien. module_function es solo un atajo para no repetir self. en cada método:
module PatenteDv
  module_function   # a partir de aca, TODO metodo definido se comporta como si tuviera self.

  def calcular(base)
    base.chars.map(&:to_i).sum
  end

  def valido?(base, dv)
    calcular(base) == dv
  end
end

=begin
module_function (sin argumentos, como linea sola) convierte todos los metodos que vengan despues en metodos de modulo, llamables directo con 'Modulo.metodo(...), sin necesitar include ni .new'

=end

#breve, por que yo querria tener un modulo que tieen sus metodos
=begin 
R: para agrupar funciones utilitarias sin estado - codigo que solo transforma un dato de entrada en una salida, sin necesitar guardar nada ni crear objetos.

La pregunta que te ayuda a decidir: ¿Necesitas crear instancias distintas con datos propios (@algo), o solo necesitas una funcion que siempre hace lo mismo con lo que le pasas?
=end

# Si necesitas ESTADO propio por instancia -> usa clase normal con .new
class Socio
  def initialize(nombre)
    @nombre = nombre  # cada socio tiene SU PROPIO nombre
  end
end

# Si NO necesitas estado, solo una funcion reutilizable -> usa modulo
# Si NO necesitas estado, solo una funcion reutilizable -> usa modulo
module ValidadorRut
  module_function
  def calcular_dv(rut)
    rut.chars.map(&:to_i).sum % 11  # siempre calcula lo mismo, no depende de "quien" lo llame
  end
end

=begin
Casos reales donde te conviene un módulo en vez de una clase:
- Validar formato de un RUT, email, telefono
- Calculñar un total, un promedio, una conversion de unidades
- Formatear texto o fechas de una forma especifica del negocio

Por qué no una clase normal con .new: si no vas a guardar ningún dato entre llamadas, crear .new es trabajo innecesario — tendrías que instanciar un objeto solo para llamar un método que no usa nada de ese objeto.
=end 


# CLASE -> primero creas un objeto (.new), despues lo usas
# CLASE -> primero creas un objeto (.new), despues lo usas
socio = Socio.new("Juan")
# socio guarda su propio @nombre = "Juan"

# MODULO -> lo llamas directo, sin .new, sin crear nada
ValidadorRut.calcular_dv("123")
# => 6

=begin
La diferencia clave en la llamada:
1. Con la clase, necesitas Socio.new(...) primero, y el resultado (socio) guarda datos propios que puedes consultar después.

2. Con el módulo, llamas ValidadorRut.calcular_dv(...) directo, como si el módulo mismo fuera la "caja de herramientas" — nunca hay un objeto de por medio, solo entra un dato y sale un resultado.
=end


##------------------------------------------------------
##------------------------------------------------------
##------------------------------------------------------
##------------------------------------------------------
##------------------------------------------------------
#10. OpenStruct
require "ostruct"
require "json"

json_como_string = '{"nombre": "Juan", "edad": 30}'
persona = JSON.parse(json_como_string, object_class: OpenStruct)
puts persona.nombre  # en vez de persona["nombre"]

=begin
La idea: convierte un hash en un objeto donde accedes a las claves con notación de punto (persona.nombre) en vez de corchetes (persona["nombre"] o persona[:nombre]). Por dentro, usa exactamente method_missing y define_singleton_method que ya vimos — cada vez que accedes a un atributo, genera el método sobre la marcha.

Advertencia real de la comunidad: es lento, no se recomienda en producción de alto rendimiento. Úsalo para prototipos, scripts, o casos puntuales — no como estructura de datos central de un sistema con mucho tráfico.

=end

=begin
el parametro 'object_class: OpenStruct le indica a 'JSON.parse' que convierta los objetos/diccionarios JSON en objetos de tipo OpenStruct en lugar de Hash
=end

#La diferencia clave
#Por defecto, cuando parseas un JSON, Ruby te devuelve un Hash:
# SIN object_class: (Comportamiento por defecto)
persona = JSON.parse(json_como_string)

puts persona["nombre"] # ✅ Funciona
puts persona.nombre   # ❌ Error (NoMethodError)

#Al agregar object_class: OpenStruct:
# CON object_class: OpenStruct
persona = JSON.parse(json_como_string, object_class: OpenStruct)

puts persona.nombre # ✅ Funciona (Se lee como un atributo u objeto)

=begin
¿Qué es OpenStruct en Ruby?
R: es una clase flexible que te permite crear objetos y asignarle o leer atributos de forma dinamica sobre la marca, usando sinxtaxis de puntos (.atributo) en lugar de corchetes con strings o simbolos (["atributo"]).

En resumen: convierte las claves del JSON en métodos reales que puedes llamar directamente en la variable.
=end

=begin
Tras ejecutar esa línea, la estructura resultante ya no es un Hash ni un String, sino una instancia de la clase OpenStruct.

1. Inspección en consola (si haces p persona)
Si imprimes el objeto en Ruby para ver su estructura interna (p persona o persona.inspect), se verá así:

#<OpenStruct nombre="Juan", edad=30>

2. Cómo se almacena en memoria
Internamente, OpenStruct envuelve un mapa de datos y crea automaticamente un metodo getter y setter para cada clave del JSON

Objeto de tipo: OpenStruct
 ├── Métodos generados automáticamente:
 │    ├── persona.nombre       # => "Juan"
 │    ├── persona.nombre = "..."
 │    ├── persona.edad         # => 30
 │    └── persona.edad = "..."
 └── Tabla interna de atributos:
      {:nombre => "Juan", :edad => 30}

3. ¿Y si el JSON tuviera estructuras anidadas?
object_class: OpenStruct se aplica recursivamente. Si el JSON tuviera objetos dentro de objetos:

json_completo = '{"nombre": "Juan", "direccion": {"ciudad": "Santiago"}}'
persona = JSON.parse(json_completo, object_class: OpenStruct)

La estructura se convierte en objetos OpenStruct encadenados:

#<OpenStruct nombre="Juan", direccion=#<OpenStruct ciudad="Santiago">>

# Te permite acceder así:
puts persona.direccion.ciudad # => "Santiago"

=end



##------------------------------------------------------
##------------------------------------------------------
##------------------------------------------------------
##------------------------------------------------------
##------------------------------------------------------
##11. Duck typing con respond_to?
def format_date(value)
  value.respond_to?(:strftime) ? value.strftime("%Y-%m-%d") : value.to_s
end

=begin
La filosofía: no importa la clase real del objeto, solo importa si "sabe hacer" lo que necesitas (si responde a ese método). "Si camina como pato y grazna como pato, es un pato" — no revisas de qué especie es, solo si hace lo que un pato hace,
=end

=begin
value.respond_to?(:strftime) — pregunta: "¿este objeto tiene un método llamado strftime?" (ese es el método que formatea fechas en Ruby). Devuelve true o false.

El ternario completo: si value sabe hacer strftime (o sea, es algo tipo fecha — Time, Date, DateTime), lo formatea como fecha. Si no sabe (por ejemplo, ya es un string normal), simplemente lo convierte a texto con .to_s.

=end
format_date(Time.new(2026, 8, 3))
# Time SI responde a strftime -> lo formatea
# => "2026-08-03"

format_date("ya es un string")
# String NO responde a strftime -> usa to_s (no cambia nada, ya era string)
# => "ya es un string"

=begin
Por qué es duck typing: el método format_date nunca pregunta "¿eres de la clase Time?" o "¿eres de la clase Date?" — no le importa la clase exacta del objeto. Solo pregunta "¿sabes hacer strftime?". Si mañana llega un objeto de una clase completamente distinta pero que también tiene strftime, el método lo trata igual, sin que tú hayas anticipado esa clase.
=end

#La alternativa "no duck typing" (mucho más rígida, evítala):
def format_date(value)
  if value.is_a?(Time) || value.is_a?(Date) || value.is_a?(DateTime)
    value.strftime("%Y-%m-%d")
  else
    value.to_s
  end
end
#Esto obliga a listar cada clase posible a mano, y si mañana aparece una clase nueva con strftime que no anticipaste, se rompe. Con respond_to?, no importa la clase — solo importa la capacidad.

#que es 'is_a?"
#R: is_a? pregunta directamente "¿eres de esta clase (o una que hereda de ella)?" — a diferencia de respond_to?, que pregunta "¿sabes hacer esto?".
"hola".is_a?(String)   # => true
5.is_a?(Integer)        # => true
Time.new.is_a?(Time)    # => true

=begin
La diferencia con respond_to? en una frase: is_a? revisa la identidad del objeto (de qué clase es), mientras que respond_to? revisa la capacidad del objeto (qué sabe hacer) — por eso respond_to? es la opción de duck typing, y is_a? es lo "rígido" que el duck typing evita.
=end


#5 ejercicios explicados (mezclando los 3 conceptos, orientados a tu trabajo):

# Ejercicio 1 - namespace puro
module PrefServices
  class CerrarProduccion
    def self.call(lote_id)
      "Cerrando lote de produccion #{lote_id}"
    end
  end
end
puts PrefServices::CerrarProduccion.call(200)
# El modulo agrupa la clase bajo el dominio PREF, evitando choque con otro "CerrarProduccion" en otro dominio
# => Cerrando lote de produccion 200

# Ejercicio 2 - module_function con funcion pura
module ValidadorRut
  module_function

  def calcular_dv(rut)
    rut.to_s.chars.map(&:to_i).sum % 11
  end
end
puts ValidadorRut.calcular_dv("123")
# Se llama directo sobre el modulo, sin instanciar nada, como una funcion utilitaria
# => 6


# Ejercicio 3 - OpenStruct con datos de una importacion
require "ostruct"
require "json"
fila_json = '{"nombre": "Juan Perez", "campus": "Punta Arenas"}'
fila = JSON.parse(fila_json, object_class: OpenStruct)
puts fila.nombre
puts fila.campus
# Se accede con notacion de punto en vez de fila["nombre"], mas legible en una vista/reporte
# => Juan Perez
# => Punta Arenas

# Ejercicio 4 - duck typing, formatear sin importar el tipo real
def formatear_fecha_ticket(valor)
  valor.respond_to?(:strftime) ? valor.strftime("%d-%m-%Y") : valor.to_s
end
puts formatear_fecha_ticket(Time.new(2026, 8, 3))
puts formatear_fecha_ticket("ya es texto")
# No importa si es un objeto Time real o un string, solo importa si "sabe" strftime
# => 03-08-2026
# => ya es texto

# Ejercicio 5 - combinando namespace + module_function + duck typing
module FormateadorPREF
  module_function

  def formatear(valor)
    valor.respond_to?(:round) ? valor.round(2) : valor.to_s
  end
end
puts FormateadorPREF.formatear(1234.5678)
puts FormateadorPREF.formatear("N/A")
# Si el valor sabe redondearse (Float/Integer), lo redondea; si no, lo deja como texto
# => 1234.57
# => N/A