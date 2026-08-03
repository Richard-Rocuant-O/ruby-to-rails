###Bloque G — Rendiemiento y Reflexion Avanzada

##------------------------------------------------------
##------------------------------------------------------
##------------------------------------------------------
#15. Set
#El código
require "set"

=begin
Set no viene disponible "de fábrica" en cada script — tienes que pedirle a Ruby que lo cargue con require. Ya viste esto con require "ostruct", require "json".
=end
ids_ya_procesados = Set.new(["CORD-95", "CORD-96", "CORD-97"])

#Creas un Set a partir de un array. Un Set se parece mucho a un array — es una colección de elementos — pero con una diferencia clave: nunca permite duplicados, y no importa el orden.

puts ids_ya_procesados.include?("CORD-96")
# => true

#.include? pregunta "¿este valor está adentro?" — funciona igual que en un array, la diferencia está en cómo lo busca por dentro.

#Por qué es más rápido — la analogía
=begin
Un array es como buscar un nombre en una lista de papel, leyendo de arriba hacia abajo. Si buscas "CORD-96" en ["CORD-95", "CORD-96", "CORD-97"], Ruby revisa el primero ("CORD-95", no es), revisa el segundo ("CORD-96", sí es) — se detiene ahí. Pero si el elemento no estuviera, tendría que revisar todos, uno por uno, hasta el final, para recién entonces decir "no está".

Con 3 elementos, esto es instantáneo. Pero imagina una lista de 50.000 tickets ya procesados, y necesitas preguntar .include? cada vez que llega un ticket nuevo, miles de veces seguidas. Cada pregunta implica potencialmente revisar los 50.000 elementos uno por uno — eso se vuelve lento, y se pone más lento mientras más grande sea la lista.

Un Set es como buscar un nombre usando el índice de un diccionario, no leyendo página por página. Por dentro, un Set usa la misma tecnología que un Hash (recuerdas los hashes: {clave => valor}) — y buscar una clave en un hash es prácticamente instantáneo, sin importar si el hash tiene 3 elementos o 3 millones. Un Set aprovecha exactamente ese mecanismo: guarda cada elemento como si fuera una "clave" de hash, así que preguntar "¿está esto adentro?" no necesita recorrer nada — va directo a la posición donde debería estar y revisa si hay algo ahí.
=end

#El término técnico: O(1) vs O(n)
# Array (O(n)) — el tiempo que tarda .include? crece proporcionalmente al tamaño de la lista. El doble de elementos = potencialmente el doble de tiempo.

#Set (O(1)) — el tiempo que tarda .include? es prácticamente el mismo, sin importar cuántos elementos tenga adentro. 10 elementos o 10 millones, la búsqueda es igual de rápida.

#El caso real donde importa — tu propio ejemplo del backfill
["CORD-95", "CORD-98"].each do |id|
  if ids_ya_procesados.include?(id)
    puts "#{id} ya procesado, salteando"
  else
    puts "#{id} procesando ahora"
  end
end

=begin
Imagina que este .each recorre 10.000 tickets nuevos, y ids_ya_procesados tiene 50.000 tickets ya procesados de una corrida anterior (un backfill que se interrumpió y necesita reanudarse sin repetir trabajo).

- Con array: cada una de las 10.000 vueltas revisa potencialmente 50.000 elementos → hasta 500 millones de comparaciones en el peor caso
- Con Set: cada una de las 10.000 vueltas es prácticamente instantánea → apenas 10.000 operaciones rápidas en total

Esa es la diferencia real que justifica usar Set en vez de Array — no por el código en sí (que se ve casi idéntico), sino por cómo escala cuando los datos crecen y las consultas se repiten muchas veces.

Cuándo NO vale la pena molestarse: si solo preguntas .include? una vez, o la lista tiene 5 o 10 elementos, la diferencia es invisible — un array normal funciona perfecto y es más simple de leer.
=end



##------------------------------------------------------
##------------------------------------------------------
##------------------------------------------------------
#16. instance_variable_set/get y const_get

#El problema que resuelven: normalmente, para leer o escribir una variable de instancia desde afuera, necesitas un attr_accessor (o un getter/setter escrito a mano). Sin eso, no hay forma de tocar @algo desde fuera del objeto.

class ControllerFalso
end

#Esta clase está completamente vacía — no tiene attr_accessor, no tiene initialize, nada.

controller = ControllerFalso.new
controller.instance_variable_set(:@proforma, { total: 1000 })

#instance_variable_set fuerza la creación de una variable de instancia, saltándose la necesidad de que el objeto tenga preparado un setter. Le dices: "en este objeto, crea (o sobrescribe) la variable @proforma, con este valor".

puts controller.instance_variable_get(:@proforma)
# => {total: 1000}

#instance_variable_get hace lo inverso: lee el valor de esa variable, sin necesitar un getter (attr_reader) definido.

#Por qué el símbolo lleva :@proforma (con la arroba incluida dentro del symbol): ya viste que :algo representa un nombre de método. Acá es parecido, pero representa el nombre literal de la variable de instancia — y las variables de instancia siempre empiezan con @, por eso el símbolo lo incluye.

#Comparación con lo que ya conoces (send):

send(:metodo) # Para que sirve: Llamar un método por nombre, saltando private-> ejemplo: objeto.send(:metodo_privado)

instance_variable_set(:@var, valor) #Escribir una variable por nombre, sin necesitar setter -> objeto.instance_variable_set(:@x, 5)

instance_variable_get(:@var) #Leer una variable por nombre, sin necesitar getter -> ejemplo: objeto.instance_variable_get(:@x)

#Dónde lo viste ya, sin que se llamara así: en el documento de tev, este es exactamente el mecanismo que usan para "armar un controller a mano" fuera del ciclo normal de request/response (generar un PDF en background). Como no hay un request HTTP real que llene las variables normalmente, inyectan manualmente lo que la vista necesita.

class ControllerFalso2
  def show_proc
    "PDF generado con @orden_servicio = #{@orden_servicio}, current_user = #{current_user}"
  end
end

def generar_pdf(orden_servicio_id)
  controller = ControllerFalso2.new
  controller.instance_variable_set(:@orden_servicio, orden_servicio_id)
  controller.define_singleton_method(:current_user) { nil }
  controller.send(:show_proc)
end

=begin
El contexto simple: normalmente, cuando un usuario visita una página web, Rails crea el controller y automáticamente llena sus variables (@orden_servicio, current_user) con los datos del request real.

Pero acá quieren generar un PDF en segundo plano (sin que un usuario esté navegando en ese momento) — no hay ningún request real que llene esas variables solo.

Por eso las "inyectan a mano":
- instance_variable_set(:@orden_servicio, ...) — mete el dato que normalmente vendría del request
- define_singleton_method(:current_user) { nil } — crea a mano el método current_user que normalmente Rails ya tendría disponible

En una frase: simulan un controller "falso" con los datos puestos a mano, para poder reusar la misma vista/lógica sin necesitar un usuario real navegando.
####################################
####################################
####################################
##################const_get##################

#Object.const_get("Factura") es equivalente a escribir Factura directo — pero como el nombre viene de una variable, puedes decidir en tiempo de ejecución qué clase usar, sin haberla "hardcodeado" en el código.

#El problema que resuelve: normalmente, para usar una clase, escribes su nombre directo en el código:
Factura.new.total

#Pero ¿qué pasa si no sabes de antemano cuál clase necesitas usar — porque ese dato viene de una base de datos, un archivo de configuración, o un input del usuario?

nombre_clase = "Factura"  # viene de ALGUN lado dinamico, no escrito fijo en el codigo

clase_resuelta = Object.const_get(nombre_clase)

#const_get toma ese string ("Factura") y te devuelve la clase real que tiene ese nombre — como si hubieras escrito Factura directo, pero de forma dinámica.

clase_resuelta.new.total
# equivale a:
Factura.new.total

#Por qué Object. al inicio: las clases en Ruby viven "dentro" del namespace global, que es Object. const_get busca constantes (y las clases son constantes) dentro de ese contexto.

#Ejemplo combinando ambos, en un caso más cercano a tu trabajo
class TicketCordenap
  def procesar
    "Procesando ticket de Cordenap"
  end
end

class TicketPref
  def procesar
    "Procesando ticket de PREF"
  end
end

def procesar_por_tipo(tipo)
  nombre_clase = "Ticket#{tipo}"       # ej: "TicketCordenap"
  clase = Object.const_get(nombre_clase)
  clase.new.procesar
end

puts procesar_por_tipo("Cordenap")
puts procesar_por_tipo("Pref")

=begin
Ejecución:

1. procesar_por_tipo("Cordenap") → nombre_clase = "TicketCordenap"
2. Object.const_get("TicketCordenap") → devuelve la clase TicketCordenap (la clase real, no un string)
3.new.procesar → crea una instancia y ejecuta procesar
=end
=> Procesando ticket de Cordenap
=> Procesando ticket de PREF

#El riesgo, igual que con eval: si tipo viniera de un input de usuario sin validar, alguien podría intentar resolver una clase que no debería, o provocar un error controlando el string. Por eso, en producción, const_get casi siempre se usa con una lista blanca de nombres permitidos, no con cualquier string libre.

#Analogía con tu stack (Laravel): es equivalente a app(nombre_clase) o new $nombreClase() en PHP, cuando el nombre de la clase viene como string dinámico — mismo patrón, mismo riesgo si no controlas de dónde viene ese string.


# 5 ejercicios explicados:
# Ejercicio 1 - Set para backfill reanudable
require "set"
tickets_procesados = Set.new(["CORD-95", "CORD-96"])
["CORD-95", "CORD-97"].each do |id|
  if tickets_procesados.include?(id)
    puts "#{id} ya procesado, salteando"
  else
    puts "#{id} procesando ahora"
  end
end
# Revisa rapido cuales ya se procesaron para no repetir trabajo
# => CORD-95 ya procesado, salteando
# => CORD-97 procesando ahora

# Ejercicio 2 - Set para eliminar duplicados de un import masivo
require "set"
ruts_importados = ["11.111.111-1", "22.222.222-2", "11.111.111-1", "33.333.333-3"]
ruts_unicos = Set.new(ruts_importados)
puts ruts_unicos.size
# Un Set nunca permite duplicados - al agregar el rut repetido, simplemente se ignora
# => 3

# Ejercicio 3 - instance_variable_set para inyectar datos en un objeto de prueba
class ReporteFalso
end
reporte = ReporteFalso.new
reporte.instance_variable_set(:@total_socios, 150)
puts reporte.instance_variable_get(:@total_socios)
# Se inyecta el dato directo, sin necesitar un attr_accessor definido en la clase
# => 150

# Ejercicio 4 - const_get para resolver un modelo dinamicamente
class Socio
  def self.tabla
    "socios"
  end
end
class Palet
  def self.tabla
    "palets"
  end
end
def tabla_de(nombre_modelo)
  Object.const_get(nombre_modelo).tabla
end
puts tabla_de("Socio")
puts tabla_de("Palet")
# El nombre de la clase viene como string (podria venir de config, DB, etc.)
# => socios
# => palets


# Ejercicio 5 - combinando Set + logica de negocio
require "set"
class ValidadorDuplicados
  def initialize
    @vistos = Set.new
  end
  def duplicado?(rut)
    if @vistos.include?(rut)
      true
    else
      @vistos.add(rut)
      false
    end
  end
end
validador = ValidadorDuplicados.new
puts validador.duplicado?("11.111.111-1")
puts validador.duplicado?("11.111.111-1")
puts validador.duplicado?("22.222.222-2")
# La primera vez que ve un rut, lo registra y dice que NO es duplicado.
# La segunda vez que ve el MISMO rut, Set.include? es rapido incluso con miles de ruts guardados
# => false
# => true
# => false