###Bloque D — Metaprogramacion de produccion



##------------------------------------------------------
##------------------------------------------------------
##------------------------------------------------------
##------------------------------------------------------
##------------------------------------------------------
##define_singleton_method — agregar un método a UN solo objeto
#define_singleton_method - Agregar un metodo a UN solo obejto
class UploadFalso
  def original_filename
    "nombre_feo_12345.pdf"
  end
end

upload = UploadFalso.new
upload.define_singleton_method(:original_filename) { "factura_formateada.pdf" }
puts upload.original_filename
# => factura_formateada.pdf

=begin
La diferencia con define_method que ya viste: define_method agrega un metodo a toda la clase - todas las instancias futuras lo tienen. define_singleton_method modifica un solo objeto puntual, sin tocar la clase ni a ningun otro objeto de esa clase.
=end
otro_upload = UploadFalso.new
puts otro_upload.original_filename
# => "nombre_feo_12345.pdf"   (el metodo original, sin modificar - "upload" fue el UNICO afectado)

#Por que sirve en produccion: cuando necesitas 'parchar' el comportamiento de un objeto especifico en un caso puntual (normalizar un nombte de archivo recien subido, simular un objeto en un test), sin tener que crear una subclase entera solo para eso.



##------------------------------------------------------
##------------------------------------------------------
##------------------------------------------------------
##------------------------------------------------------
##------------------------------------------------------
##send + respond_to? - despacho dinamico
=begin
ya viste 'send'. lo nuevo es combinarlo con 'respond_to?' para verificar primero que el metodo existe antes de llamarlo, evitando que explote
=end
def aplicar_scope(clase, nombre_scope)
  return "scope invalido" unless clase.respond_to?(nombre_scope)
  clase.send(nombre_scope)
end
=begin
respond_to?(:algo) pregunta "¿existe un metodo llamado 'algo' en este objeto?" y devuelve true/false, sin ejecutarlo. Combinando con send, tienes un patron seguro: primero verificas, luego ejecutas.
=end

=begin
###3 Razones por las que send es súper útil

1.Recibir la instruccion desde el usuario o la web
Imagínate una tienda en línea donde el cliente elige cómo ordenar los productos desde un desplegable en la web:
=end
# La web te manda en los parámetros: params[:orden] -> "mas_baratos", "mas_nuevos", o "ofertas"

metodo_elegido = params[:orden] #digamos que vale "mas_baratos"
# ❌ SIN SEND (Tendrías que hacer un 'if' gigante):
if metodo_elegido == "mas_baratos"
  Producto.mas_baratos
elsif metodo_elegido == "mas_nuevos"
  Producto.mas_nuevos
elsif metodo_elegido == "ofertas"
  Producto.ofertas
end

# ✅ CON SEND (Se resuelve en UNA sola línea):
Producto.send(metodo_elegido)

=begin
2.Evitar codigo repetitivo (Metaprogramacion)
Si tienes que ejecutar varias acciones sobre un objeto:

:guardar puede ser un método público, mientras que :notificar_usuario y :enviar_email podrían ser privados (y aun así send los podrá ejecutar sin problema): 
=end
class Usuario
  attr_reader :nombre
  def initialize(nombre)
    @nombre = nombre
  end
  # --- Método Público ---
  def guardar
    puts "💾 Guardando a #{@nombre} en la base de datos..."
  end
  # --- Métodos Privados ---
  private
  def notificar_usuario
    puts "🔔 Creando notificación interna para #{@nombre}..."
  end
  def enviar_email
    puts "📧 Enviando correo de bienvenida a #{@nombre}..."
  end
end
usuario = Usuario.new("Ana")
acciones = [:guardar, :notificar_usuario, :enviar_email]
acciones.each do |accion|
    usuario.send(accion) # En cada vuelta ejecuta: usuario.guardar, usuario.notificar_usuario...
end

#💡 El detalle clave
#Si intentaras hacer esto de la forma tradicional sin send:
usuario.notificar_usuario 
# ❌ Error: NoMethodError (private method `notificar_usuario' called for #<Usuario...>)



=begin
3.El "superpoder" de send (Acceso a lo privado)
A diferencia de llamar al método de forma normal, send puede ejecutar métodos privados (private) de una clase. Se usa muchísimo en pruebas (testing) para probar la lógica interna de un objeto sin cambiar su privacidad.
=end



##------------------------------------------------------
##------------------------------------------------------
##------------------------------------------------------
##------------------------------------------------------
##------------------------------------------------------
#####class_eval - generar metodos cuyo nombre depende de una variable
=begin
Paso 1 - que es un heredoc, aislado, sin class_eval
=end
texto = <<-MENSAJE
  Hola
  Este es un texto de varias lineas
MENSAJE

puts texto
=begin
<<-MENSAJE (la palbra puede ser cualquiera, MENSAJE es solo una etiqeuta que tu eliges) le dice a Ruby: "todo lo que sigue, hasta que encuentres MENSAJE de nuevo, es un solo string gigante". Es como comillas, pero para varias lineas, sin tener que escribir \n a mano.

def 2: Un Heredoc (short for here document) es una sintaxis en Ruby para definir strings multilínea largos de forma limpia, preservando los saltos de línea y el formato exacto.

Se abre con <<~ (o <<) seguido de una etiqueta en mayúsculas (como SQL, TEXT, HTML) y se cierra con esa misma etiqueta en su propia línea.
=end
# La tilde (<<~) ignora la sangría/indentación al inicio
mensaje = <<~TEXTO
  Hola Carlos,
  Este es un mensaje multilínea.
  Conserva los saltos de línea automáticamente.
TEXTO

puts mensaje
=begin
Caso de uso tipicos
-consultas SQL largas
-planillas HTML o emails
-textos descriptivos o JSONs dentro del codigo
=end

=begin
Paso 2 - el heredoc del ejemplo, aislado, sin clas_eval
=end
campo = "nombre"
codigo_como_texto = <<-RUBY
  def #{campo}_con_prefijo(valor)
    "config_#{campo}: " + valor
  end
RUBY
=begin
campo vale "nombre". Como el heredoc también permite interpolación (#{}), el resultado de codigo_como_texto es este string:
=end
def nombre_con_prefijo(valor)
    "config_nombre: " + valor
end

=begin
Paso 3 — class_eval, lo que convierte ese texto en código real
=end
class Configuracion
end

Configuracion.class_eval(codigo_como_texto)

#class_eval toma ese str y le dice a Ruby "ejecuta este texto como si estuviera escrito directamente dentro de la clase Configuracion"
class Configuracion
  def nombre_con_prefijo(valor)
    "config_nombre: " + valor
  end
end

#Prueba de que funcionó de verdad:
config = Configuracion.new
puts config.nombre_con_prefijo("Juan")
# => config_nombre: Juan

#Ahora, el ejemplo completo con el .each
["nombre", "email"].each do |campo|
  Configuracion.class_eval <<-RUBY
    def #{campo}_con_prefijo(valor)
      "config_#{campo}: " + valor
    end
  RUBY
end

=begin
Fíjate: class_eval <<-RUBY ... RUBY es solo class_eval(el_string_del_heredoc), sin el paréntesis explícito (Ruby permite omitirlo).

vuelta por vuelta del .each
Vuelta 1 - campo = "nombre". El heredoc se convierte en el str
=end
def nombre_con_prefijo(valor)
  "config_nombre: " + valor
end
#Y class_eval lo ejecuta, agregando el metodo 'nombre_con_prefijo' a la clase

# Vuelta 2 — campo = "email". El heredoc se convierte en:
def email_con_prefijo(valor)
  "config_email: " + valor
end

#Y class_eval lo ejecuta, agregando email_con_prefijo a la clase.
#Al terminar el .each, la clase Configuracion tiene 2 métodos nuevos, generados desde texto:

config = Configuracion.new
puts config.nombre_con_prefijo("Juan")   # => config_nombre: Juan
puts config.email_con_prefijo("juan@x.cl") # => config_email: juan@x.cl

#La comparación con define_method — para que veas por qué es "peor" en este caso
#Con class_eval (texto crudo):
["nombre", "email"].each do |campo|
  Configuracion.class_eval <<-RUBY
    def #{campo}_con_prefijo(valor)
      "config_#{campo}: " + valor
    end
  RUBY
end

#Con define_method (mas seguro, mismo resultado):
["nombre", "email"].each do |campo|
  Configuracion.define_method("#{campo}_con_prefijo") do |valor|
    "config_#{campo}: " + valor
  end
end

=begin
Qué es <<-RUBY ... RUBY: se llama heredoc — una forma de escribir un string de varias líneas sin tener que escapar comillas. Todo lo que está entre <<-RUBY y RUBY es un string gigante.

class_eval sobre ese string: toma ese string y lo ejecuta como si fuera código escrito dentro de la clase Configuracion. Es como eval, pero apuntado específicamente al contexto de una clase — por eso puede definir métodos ahí.

Diferencia con define_method: en este caso concreto, class_eval con un heredoc es más "peligroso" y menos idiomático que define_method — la mayoría de casos como este se resolverían mejor con define_method (que ya viste), pero existe cuando necesitas construir el cuerpo entero del método como texto, no solo su nombre.

=begin
Ambos producen exactamente los mismos 2 métodos. La diferencia es que define_method recibe un bloque real (código Ruby de verdad, que tu editor resalta, que se puede depurar normal). class_eval con un heredoc recibe un string — para Ruby, hasta el momento de ejecutarlo, es solo texto plano, sin resaltado de sintaxis, sin autocompletado, y si el string tiene un error de sintaxis, no lo sabes hasta que se ejecuta esa línea (mismo problema de eval que ya vimos antes).

Resumiendo en una frase: class_eval con heredoc es útil cuando necesitas armar el texto del método completo dinámicamente (con nombres de método Y cuerpo variable, todo como string) — pero cuando solo necesitas que cambie el nombre, define_method hace lo mismo con menos riesgo.
=end

=begin
¿Cual seria lo recomendado?
R: regla general: usa 'define_method' cuando el nombre del metodo es dinamico o generado a partir de datos, ya que captura variables locales del entorno por closure, algo que def no puede hacer. Pero class_eval ejecuta mas rapido una vez definido, aunque tarda mas en definirse - define_method es rapido de crear pero un poco mas lento en cada ejecucion.

Lo recomendado para el 95% de los casos (incluido el tuyo, nombre_con_prefijo/email_con_prefijo): define_method.

Los bloques son mejores porque se integran con el resaltado de sintaxis de tu editor, capturan variables locales (permitiendo closures), y evitan los riesgos de seguridad de evaluar strings arbitrarios.

Cuándo class_eval sí es la opción correcta: cuando necesitas evaluar código escrito junto con la clase, no un método aislado — el patrón real y recomendado es combinar ambos, usando class_eval con un bloque (no un string/heredoc) que por dentro llama a define_method:
=end

Product.class_eval do
    fields.each do |field|
        define_method("#{field}_formatted") do
            #...
        end
    end
end

=begin
Resumen de la jerarquia real de preferencia
1. Mejor: define_method solo
2. También bien: class_eval con bloque (no string) + define_method adentro
3. Evitar salvo necesidad real: class_eval con string/heredoc — el patrón que encontró Claude Code en tev, que es el menos recomendado de los tres
=end



##------------------------------------------------------
##------------------------------------------------------
##------------------------------------------------------
##------------------------------------------------------
##------------------------------------------------------
##Lookup dinámico con hash de constantes (evita if/elsif largo)
#Primero, la versión SIN el hash (con if/elsif)
class Hallazgo
  def encargado_inicial
    "Juan (etapa 1)"
  end

  def encargado_final
    "Maria (etapa 2)"
  end

  def encargado_actual(etapa_id)
    if etapa_id == 1
      encargado_inicial
    elsif etapa_id == 2
      encargado_final
    end
  end
end

h = Hallazgo.new
puts h.encargado_actual(2)
# => Maria (etapa 2)

#Esto funciona perfecto. El problema aparece cuando tienes muchas etapas — el if/elsif se vuelve larguísimo, y cada vez que agregas una etapa nueva, tienes que agregar una rama más.

#Ahora, la version CON en hash
class Hallazgo
  ENCARGADOS_POR_ETAPA = { 1 => :encargado_inicial, 2 => :encargado_final }

def encargado_inicial
    "Juan (etapa 1)"
end

def encargado_final
    "Maria (etapa 2)"
end
def encargado_actual(etapa_id)
    send(ENCARGADOS_POR_ETAPA[etapa_id])
end

=begin
La idea: en vez de escribir iif etapa_id == 1; encargado_inicial; elsif etapa_id == 2; encargado_final; end, guardas la relacion "etapa->metodo" en un hash, y usas send para invocar el metodo correcto dinamicamente. Menos codigo, mas facil de extender (agregar una etapa = agregar una linea al hash, no una rama nueva de if)
=end 

=begin
ENCARGADOS_POR_ETAPA = {1 => :encargado_inicial, 2 => :encargado_final} - un hash donde las claves son los etapa_id posibles (1,2), y los valores son symbols - recordando lo que ya vimos, un symbol aca representa el nombre de un metodo a llamar:

ENCARGADOS_POR_ETAPA[etapa_id] - esto es simplemente buscar en el hash. Si etapa_id es 2, esto devuelve :encargado_final (el symbol, no ejecuta nada todavía).

send(ENCARGADOS_POR_ETAPA[etapa_id]) - recordando 'send': toma ese symbol (:encargado_final) y llama al metodoque tiene ese nombre
=end

#Ejecucion paso a paso
h = Hallazgo.new
puts h.encargado_actual(2)

=begin
1. Entra a 'encargado_actual' con 'etapa_id = 2'
2.ENCARGADO_POR_ETAPA[2] busca la clave 2 en el hash -> devuelve :encargdo_final
3. send(:encargado_final) -> equovale a llaamr ' encargado_final' directmaente
4. encargado_final devuelve "Maria (etapa 2)"
5. Ese resultado se devuelve

=begin
Por que es "menos codigo, mas facil de extender": Si mañana agregas una etapa 3, con if/elsif tienes que tocar el metodo 'encargado_actual' y agregarle una rama mas. Con el hash, solo agregas una linea al ENCARGADOS_POR_ETAPA - el metodo 'encargado_actual' no cambia nunca, siempre hace lo mismo (buscar en el hash y hacer send), y sin importar cuantas etapas existan.
=end

#5 ejercicios explicados (mezclando las 4 técnicas, orientados a tu trabajo):

# Ejercicio 1 - define_singleton_method (normalizar un dato puntual)
class ImportacionSocio
  def nombre_crudo
    "  juan perez  "
  end
end
fila = ImportacionSocio.new
fila.define_singleton_method(:nombre_crudo) { "Juan Perez" }
puts fila.nombre_crudo
# Solo ESTA fila especifica tiene el nombre "arreglado", otras filas de la importacion siguen igual
# => Juan Perez

# Ejercicio 2 - send + respond_to? (aplicar filtro dinamico por nombre)
#respond_to?: tu entiendes o tienes este metodo? - Devuelve true o false
class TicketsCordenap
  def self.abiertos
    "tickets abiertos"
  end
  def self.cerrados
    "tickets cerrados"
  end
end
def filtrar(clase, nombre_filtro)
  return "filtro invalido" unless clase.respond_to?(nombre_filtro)
  clase.send(nombre_filtro)
end
puts filtrar(TicketsCordenap, :abiertos)
puts filtrar(TicketsCordenap, :vencidos)
# respond_to? evita el crash cuando el filtro no existe, en vez de explotar con NoMethodError
# => tickets abiertos
# => filtro invalido

# Ejercicio 3 - class_eval generando validadores por nombre de campo
class ValidadorImport
end
["rut", "campus"].each do |campo|
  ValidadorImport.class_eval <<-RUBY
    def #{campo}_presente?(valor)
      !valor.nil? && !valor.to_s.strip.empty?
    end
  RUBY
end
v = ValidadorImport.new
puts v.rut_presente?("12345678-9")
puts v.campus_presente?("")
# class_eval genero 2 metodos nuevos (rut_presente? y campus_presente?) a partir del array
# => true
# => false

# Ejercicio 4 - lookup dinamico con hash de constantes
class Ticket
  ACCIONES_POR_ESTADO = { "abierto" => :notificar_apertura, "cerrado" => :notificar_cierre }

  def notificar_apertura
    "Notificando apertura de ticket"
  end

  def notificar_cierre
    "Notificando cierre de ticket"
  end

  def notificar(estado)
    send(ACCIONES_POR_ESTADO[estado])
  end
end
t = Ticket.new
puts t.notificar("cerrado")
# En vez de un if/elsif por cada estado, el hash decide que metodo llamar
# => Notificando cierre de ticket


# Ejercicio 5 - combinando send + respond_to? con hash, version segura
class Documento
  REGLAS_POR_TIPO = { "factura" => :validar_factura, "boleta" => :validar_boleta }

  def validar_factura
    "Factura valida"
  end

  def validar(tipo)
    metodo = REGLAS_POR_TIPO[tipo]
    return "tipo desconocido" if metodo.nil? || !respond_to?(metodo)
    send(metodo)
  end
end
d = Documento.new
puts d.validar("factura")
puts d.validar("boleta")
# "boleta" esta en el hash pero el metodo validar_boleta NUNCA se definio -> respond_to? lo detecta
# => Factura valida
# => tipo desconocido