###Bloque F — Seguridad de datos y sintaxis moderna

##------------------------------------------------------
##------------------------------------------------------
##------------------------------------------------------

#12. Freeze
ESTADOS_VALIDOS = %w[ingresada consolidada despachada entregada anulada].freeze
#.freeze marca un objeto como inmutable — cualquier intento de modificarlo (agregar, quitar, cambiar elementos) lanza FrozenError.
ESTADOS_VALIDOS << "otro"
# => FrozenError: can't modify frozen Array

# El detalle crítico que validé — freeze es superficial, no profundo:
config = {limites: [10,20]}.freeze
config[:nuevo] = "algo" # ERROR: el hash esta congelado, no puedes agregar claves
config[:limites] << 30 # FUNCIONA -> el ARRAY de adentro NO esta congelado

=begin
.freeze solo congela el objeto de "primer nivel" (el hash en sí, o el array en sí). Si ese objeto contiene otros objetos mutables adentro (un array dentro de un hash, por ejemplo), esos internos siguen siendo modificables a menos que también los congeles a ellos explícitamente.
=end

=begin
como se congelarian los que estan dentro?

Aplicando .freeze a cada uno de los objetos internos, no solo al de afuera.
=end
config = { limites: [10, 20].freeze }.freeze
config[:limites] << 30
# => FrozenError: can't modify frozen Array

#Si tienes varios niveles anidados, tendrías que congelar cada uno manualmente:
config = {
  limites: [10, 20].freeze,
  nombres: ["a", "b"].freeze
}.freeze

#Si la estructura es muy profunda y no quieres hacerlo a mano, existe el patrón deep_freeze (no viene nativo en Ruby puro, pero sí en Rails/ActiveSupport, o gemas como ice_nine):

# en Rails, con ActiveSupport
config = { limites: [10, 20] }.deep_freeze
config[:limites] << 30
# => FrozenError (ahora si, congela recursivamente todo lo interno)

#En una frase: Ruby puro no tiene una forma automática de congelar "todo lo de adentro" — tienes que congelar cada nivel a mano, o usar una herramienta externa (deep_freeze de Rails/ActiveSupport) que lo haga recursivamente por ti.


##------------------------------------------------------
##------------------------------------------------------
##------------------------------------------------------
#13. Safe navigation (&.) y .tap
fila_interna = { "fecha_ingreso" => "2026-08-01", "monto_total" => 50000 }
  .tap { |h| h["Fecha de Ingreso"] = h.delete("fecha_ingreso") }
  .tap { |h| h["Monto Total"] = h.delete("monto_total") }

p fila_interna
# => {"Fecha de Ingreso"=>"2026-08-01", "Monto Total"=>50000}

=begin
Qué cambió: en vez de escribir fila_interna["X"] = fila_interna.delete("y") en líneas sueltas usando el nombre de la variable dos veces por línea, cada .tap recibe el hash (como h), hace el renombre, y lo devuelve para que el siguiente .tap lo siga procesando — encadenado, sin repetir fila_interna una y otra vez.
=end

#O, más limpio todavía, con un solo .tap y ambos renombres adentro:
fila_interna = { "fecha_ingreso" => "2026-08-01", "monto_total" => 50000 }
  .tap do |h|
    h["Fecha de Ingreso"] = h.delete("fecha_ingreso")
    h["Monto Total"] = h.delete("monto_total")
  end

p fila_interna

# .tap — te deja "meterte" en medio de una cadena de métodos, hacer algo con el valor (mirarlo, modificarlo), y seguir la cadena sin cortarla, porque .tap siempre devuelve el mismo objeto que recibió.


resultado = serializar(con_tipo).tap { |hash| hash["vehiculos"] = hash.delete("vehiculos_asignables") }

#.tap recibe el hash que devolvió serializar, ejecuta el bloque (renombra una clave), y devuelve ese mismo hash modificado — permite encadenar sin necesitar una variable intermedia.


# => {"Fecha de Ingreso"=>"2026-08-01", "Monto Total"=>50000}

=begin
La diferencia real con la versión sin .tap: el resultado es idéntico — mismo hash, mismos cambios. El .tap solo te permite hacerlo encadenado a la creación del hash, en vez de crear la variable primero y modificarla después en líneas separadas. Es puramente una cuestión de estilo/legibilidad para cuando tienes una cadena de transformaciones — no cambia el comportamiento.
=end


##------------------------------------------------------
##------------------------------------------------------
##------------------------------------------------------
#14. Keyword arguments avanzados

#Lo que ya conocías — parámetros posicionales
def crear_socio(nombre, edad, campus)
  "..."
end

crear_socio("Juan", 30, "Punta Arenas")
#Acá el orden importa muchísimo — si cambias el orden de los argumentos al llamar, se asignan mal:
crear_socio(30, "Juan", "Punta Arenas")
# nombre = 30 (!) edad = "Juan" (!) - todo mezclado, sin que Ruby se queje

#Ahora, keyword arguments — cada valor tiene nombre
def initialize(from_date: "2026-01-01", throttle: 0.3, dry_run: true, resume: false)

#Cada parámetro tiene: un nombre (from_date), dos puntos :, y un valor por defecto ("2026-01-01"). Al llamar el método, especificas explícitamente qué nombre le estás dando cada valor — el orden ya no importa.
BackfillSimulado.call(dry_run: false, resume: true)

=begin
Lo que pasa acá:
1. No pasaste from_date → usa su valor por defecto: "2026-01-01"
2. No pasaste throttle → usa su valor por defecto: 0.3
3. Sí pasaste dry_run: false → sobrescribe el default (true) con false
4. Sí pasaste resume: true → sobrescribe el default (false) con true

Podrías haber escrito el orden al revés y funcionaría igual:
=end
BackfillSimulado.call(resume: true, dry_run: false)
# exactamente el mismo resultado - el ORDEN no importa con keywords, solo el NOMBRE
#La ventaja frente a posicionales: con 4 parámetros posicionales, tendrías que recordar el orden exacto y pasar los 4 siempre. Con keywords, solo pasas los que quieres cambiar respecto al default, y nunca te puedes equivocar de orden.

#Ahora, la mezcla — posicional + keywords en el mismo método
def resumen_meses(meses_atras = 7, year: nil, owner_id: nil)

=begin
meses_atras = 7 — este es un parámetro posicional (sin :), con valor por defecto 7. Se pasa sin nombre, por posición, como siempre.

year: nil, owner_id: nil — estos son keywords, con : y valor por defecto nil. Se pasan con nombre explícito.

Forma validos de llamarlo:
=end
resumen_meses
# meses_atras usa su default (7), year y owner_id usan sus defaults (nil)

resumen_meses(3)
# meses_atras = 3 (posicional, sin nombre), year y owner_id siguen en nil

resumen_meses(3, year: 2026)
# meses_atras = 3 (posicional), year = 2026 (keyword), owner_id sigue en nil

resumen_meses(year: 2026, owner_id: 5)
# meses_atras usa su default (7) porque no se paso nada posicional
# year y owner_id se pasan por nombre

#La regla que las diferencia: el argumento posicional siempre va primero, sin nombre, identificado por su posición en la llamada. Los keywords van después, identificados por su nombre, en cualquier orden entre ellos.

#Por qué existe esta mezcla — el caso real de uso
#Tiene sentido cuando hay un dato que casi siempre se pasa igual (por eso puede ir posicional, sin repetir el nombre cada vez), y varios datos opcionales que a veces sí, a veces no, necesitas ajustar (esos van como keyword, con nombre, para que sea claro cuál estás cambiando):

resumen_meses(3, year: 2026)
# claro: "dame el resumen de los ultimos 3 meses, del año 2026"


#5 ejercicios explicados:
# Ejercicio 1 - freeze en constante de dominio
ESTADOS_TICKET = %w[abierto en_progreso cerrado].freeze
begin
  ESTADOS_TICKET << "cancelado"
rescue FrozenError => e
  puts "Error: #{e.message}"
end
# Protege la lista de estados validos de ser modificada accidentalmente en runtime
# => Error: can't modify frozen Array: ["abierto", "en_progreso", "cerrado"]

# Ejercicio 2 - freeze superficial, el problema real
config_facturacion = { campos_obligatorios: [:rut, :nombre] }.freeze
config_facturacion[:campos_obligatorios] << :email
puts config_facturacion[:campos_obligatorios]
# El hash esta frozen, pero el array de adentro NO -> igual se pudo modificar
# => [:rut, :nombre, :email]

# Ejercicio 3 - safe navigation en cadena de asociaciones
class Ticket
  attr_accessor :asignado_a
end
class Persona
  attr_accessor :nombre
end
ticket_sin_asignar = Ticket.new
ticket_asignado = Ticket.new
ticket_asignado.asignado_a = Persona.new.tap { |p| p.nombre = "Alex" }
puts ticket_asignado.asignado_a&.nombre
puts ticket_sin_asignar.asignado_a&.nombre
# Sin &. el segundo puts explotaria con NoMethodError sobre nil
# => Alex
# => nil (sin ERROR)

# Ejercicio 4 - tap para renombrar clave sin variable intermedia
def serializar_socio(socio)
  { "nombre" => socio[:nombre], "campus_actual" => socio[:campus] }
end
resultado = serializar_socio({nombre: "Juan", campus: "Punta Arenas"})
  .tap { |h| h["campus"] = h.delete("campus_actual") }
p resultado
# tap permite renombrar la clave dentro de la misma cadena, sin cortar en 2 lineas con variable
# => {"nombre"=>"Juan", "campus"=>"Punta Arenas"}

# Ejercicio 5 - keyword arguments con defaults, patron factory
class ExportacionPREF
  def self.call(**kwargs)
    new(**kwargs).call
  end
  def initialize(formato: "xlsx", incluir_totales: true, fecha_desde: "2026-01-01")
    @formato = formato
    @incluir_totales = incluir_totales
    @fecha_desde = fecha_desde
  end
  def call
    "Exportando en #{@formato}, totales=#{@incluir_totales}, desde=#{@fecha_desde}"
  end
end
puts ExportacionPREF.call
puts ExportacionPREF.call(formato: "pdf", incluir_totales: false)
# Solo se sobreescriben los kwargs que se pasan, el resto usa su default
# => Exportando en xlsx, totales=true, desde=2026-01-01
# => Exportando en pdf, totales=false, desde=2026-01-01