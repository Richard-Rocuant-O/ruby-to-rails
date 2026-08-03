###Bloque A - Estado y visibilidad

#--------------------------------------------
#--------------------------------------------
#--------------------------------------------

##1. Variable de instancia (@variable) - con el patron de memoizacion
#nuevo de documento tev es el patron d) - memoizacion a nivel de clase:

#5 ejercicios explicados:

# Ejercicio 1
class ConfigCordenap
  def self.tarifas
    @tarifas ||= (puts "Calculando tarifas..."; {basica: 1000, premium: 2000})
  end
end
ConfigCordenap.tarifas   # imprime "Calculando tarifas..." y devuelve el hash
ConfigCordenap.tarifas   # NO imprime nada, solo devuelve el hash guardado
# La primera llamada calcula y guarda en @tarifas. La segunda ve que @tarifas ya no es nil, y lo devuelve directo.

# Ejercicio 2
class CacheSocios
  def self.total_activos
    @total_activos ||= 150
  end
end
puts CacheSocios.total_activos
# Como @total_activos empieza en nil, ||= lo asigna a 150 la primera vez.
# => 150

# Ejercicio 3
class ReporteMensual
  def self.datos
    @datos ||= []
  end
end
ReporteMensual.datos << "fila 1"
ReporteMensual.datos << "fila 2"
puts ReporteMensual.datos
# La primera llamada crea el array vacio y lo guarda. Las siguientes llamadas
# devuelven EL MISMO array (no uno nuevo), por eso los <<  se van acumulando.
# => ["fila 1", "fila 2"]

# Ejercicio 4
class Contador
  def self.veces_llamado
    @veces_llamado ||= 0
    @veces_llamado += 1
  end
end
puts Contador.veces_llamado
puts Contador.veces_llamado
puts Contador.veces_llamado
# OJO: aca hay 2 lineas, no una. La primera asegura que @veces_llamado empiece en 0
# si es nil. La segunda SIEMPRE suma 1 y lo devuelve (no usa ||=, por eso SI cambia cada vez)
# => 1
# => 2
# => 3

# Ejercicio 5
class TarificadorPREF
  def self.precio_base
    @precio_base ||= calcular_precio_base
  end

  def self.calcular_precio_base
    puts "Ejecutando calculo pesado"
    5000
  end
end
TarificadorPREF.precio_base
TarificadorPREF.precio_base
# Solo la primera llamada ejecuta calcular_precio_base (e imprime el mensaje).
# La segunda ya tiene @precio_base guardado, asi que ni siquiera llama al metodo.
# => "Ejecutando calculo pesado" (solo una vez)
# => 5000 (ambas veces)



=begin
¿Que es memoizacion?
#patron de calcular un valor una sola vez, y reusarlo cada vez subsiguiene que se necesite, en vez de recalcularlo cada vez que lo pides.

La idea con una analogía simple: imagina que te preguntan "¿cuánto es 347 × 892?" La primera vez, sacas la calculadora, lo calculas, y respondes. Si te preguntan lo mismo 10 segundos después, no vuelves a sacar la calculadora — ya sabes la respuesta, la dices de memoria. Eso es memoización: la primera vez cuesta trabajo, las siguientes veces es gratis porque ya "recuerdas" el resultado.
=end

class FixtureLoader
  def self.datos_junio
    @datos_junio ||= "fixture parseado una sola vez"
  end
end

=begin
class FixtureLoader — define una clase, nada nuevo.
def self.datos_junio — esto si es distinto. el 'self.' antes del nombre significa que este es un metodo de clase, no un metodo de instancia. La diferencia se ve en como se llama:
=end

# metodo de INSTANCIA (lo que siempre hemos visto)
class Persona
  def saludar
    puts "hola"
  end
end
p = Persona.new     # <- primero hay que crear un objeto
p.saludar            # <- y llamarlo desde el objeto

# metodo de CLASE (self.)
class FixtureLoader
  def self.datos_junio
    "algo"
  end
end
FixtureLoader.datos_junio   # <- se llama DIRECTO sobre la clase, sin .new

=begin
@datos_junio — dentro de un método de clase, @datos_junio no pertenece a ningún objeto instanciado (no hicimos .new). Pertenece a la clase misma. Esto suena raro, pero en Ruby, una clase también es un objeto (FixtureLoader es en sí mismo un objeto de tipo Class), y como todo objeto, puede tener sus propias variables de instancia.

||= — este es el operador clave de la memoización. Es un atajo que significa: "si la variable de la izquierda todavía no tiene un valor (es nil), asígnale este valor; si ya tiene un valor, no hagas nada, déjala como está".
=end

@datos_junio ||= "fixture parseado una sola vez"
# esto es EQUIVALENTE a escribir:
@datos_junio = @datos_junio || "fixture parseado una sola vez"

#Ejecutando el ejemplo paso a paso
puts FixtureLoader.datos_junio   # primera llamada
puts FixtureLoader.datos_junio   # segunda llamada

=begin
# Primera llamada — FixtureLoader.datos_junio:
1. Ruby entra al método self.datos_junio
2. Llega a @datos_junio ||= "fixture parseado una sola vez"
3. Revisa: ¿@datos_junio ya tiene un valor? No, es nil (nunca se le asignó nada antes)
4. Como es nil, ejecuta la asignación: @datos_junio = "fixture parseado una sola vez"
5. El método devuelve ese string

# Segunda llamada — FixtureLoader.datos_junio:

1. Ruby entra al método otra vez
2. Llega a la misma línea @datos_junio ||= "fixture parseado una sola vez"
3. Revisa: ¿@datos_junio ya tiene un valor? Sí — quedó guardado de la llamada anterior ("fixture parseado una sola vez")
4. Como ya tiene valor, ||= no hace nada — no vuelve a ejecutar el lado derecho
5. El método simplemente devuelve el valor que ya estaba guardado

Resultado: ambas líneas imprimen lo mismo, pero la segunda vez Ruby "se ahorró" el trabajo de recalcular — solo leyó lo que ya tenía guardado.
=end

=begin
Por qué importa en la práctica (el motivo real de usar esto)

En el ejemplo del documento, el string "fixture parseado una sola vez" es trivial — no cuesta nada calcularlo. Pero imagina que en vez de un string simple, esa línea hiciera algo caro:
=end
class FixtureLoader
  def self.datos_junio
    @datos_junio ||= JSON.parse(File.read("fixture_gigante.json"))
  end
end

=begin
Sin ||=, cada vez que llamaras FixtureLoader.datos_junio volverías a leer el archivo del disco y parsearlo entero, aunque el contenido no haya cambiado — un desperdicio de tiempo. Con ||=, solo se lee y parsea la primera vez; todas las llamadas siguientes son instantáneas porque ya está guardado en @datos_junio.
=end

=begin
Por qué específicamente lo usan en tests (como menciona el documento): si un test necesita ese mismo archivo fixture 50 veces a lo largo de la suite de tests, sin memoización leerías el archivo 50 veces del disco — con memoización, lo lees una sola vez y las otras 49 usan la copia guardada, haciendo que los tests corran mucho más rápido.
=end

#--------------------------------------------
#--------------------------------------------
#--------------------------------------------
##2. Variables de clase (@@) - el bug real de tev

class ControllerConBug
  @@paniol_seleccionado = nil

  def seleccionar(paniol)
    @@paniol_seleccionado = paniol
  end

  def paniol_actual
    @@paniol_seleccionado
  end
end

#5 ejercicios explicados (reproduciendo el bug con otro dominio):
# Ejercicio 1
class SesionSocio
  @@ultimo_campus_buscado = nil
  def buscar(campus)
    @@ultimo_campus_buscado = campus
  end
  def campus_actual
    @@ultimo_campus_buscado
  end
end
socio1 = SesionSocio.new
socio2 = SesionSocio.new
socio1.buscar("Punta Arenas")
puts socio2.campus_actual
# socio2 nunca busco nada, pero @@ultimo_campus_buscado es UNA sola variable
# compartida por TODAS las instancias -> ve lo que socio1 guardo
# => Punta Arenas

# Ejercicio 2
class ContadorGlobal
  @@total_requests = 0
  def registrar
    @@total_requests += 1
  end
  def total
    @@total_requests
  end
end
r1 = ContadorGlobal.new
r2 = ContadorGlobal.new
r1.registrar
r2.registrar
r2.registrar
puts r1.total
# Aca @@total_requests SI tiene sentido compartirla (es un contador global real),
# por eso funciona "bien" en este caso, pero sigue siendo la misma variable para ambos
# => 3

# Ejercicio 3
class CarritoCompra
  @@ultimo_producto_agregado = nil
  def agregar(producto)
    @@ultimo_producto_agregado = producto
  end
end
carrito_usuario_a = CarritoCompra.new
carrito_usuario_b = CarritoCompra.new
carrito_usuario_a.agregar("Cemento")
carrito_usuario_b.agregar("Bloques")
puts carrito_usuario_a.instance_variable_get(:@@ultimo_producto_agregado) rescue puts "revisemos con metodo normal"
# Por mas que sean carritos DISTINTOS de usuarios distintos, @@ultimo_producto_agregado
# es una sola variable -> el valor de A queda sobreescrito por B

# Ejercicio 4 (la version CORRECTA, usando @ en vez de @@)
class SesionSocioCorregida
  def initialize
    @ultimo_campus_buscado = nil
  end
  def buscar(campus)
    @ultimo_campus_buscado = campus
  end
  def campus_actual
    @ultimo_campus_buscado
  end
end
socio1 = SesionSocioCorregida.new
socio2 = SesionSocioCorregida.new
socio1.buscar("Punta Arenas")
puts socio2.campus_actual
# Ahora cada instancia tiene SU PROPIO @ultimo_campus_buscado, aislado
# => nil (correcto: socio2 nunca busco nada)

# Ejercicio 5
class InventarioPREF
  @@stock_total = 100
  def vender(cantidad)
    @@stock_total -= cantidad
  end
  def stock
    @@stock_total
  end
end
venta1 = InventarioPREF.new
venta2 = InventarioPREF.new
venta1.vender(30)
puts venta2.stock
# Igual que el contador, aca @@ SI tiene sentido (el stock es genuinamente
# compartido entre todas las "ventanillas" de venta) -> es el caso correcto de usar @@
# => 70



=begin
@@paniol_seleccionado = nil — recordando lo que ya vimos de variables de clase: esto crea una sola variable, compartida por todas las instancias que se creen de ControllerConBug. No es "una por objeto" como sería con @paniol (una arroba) — es una única caja, y cualquier objeto de esta clase escribe y lee de esa misma caja.

def seleccionar(paniol) — un método normal que recibe un parámetro paniol, y lo guarda en @@paniol_seleccionado.

def paniol_actual — un método normal que solo lee y devuelve lo que haya en @@paniol_seleccionado.

##Simulando el contexto real — por qué esto es un controller

En Rails (y esto es clave para entender el bug), cada vez que llega una petición HTTP al servidor, Rails crea una instancia nueva del controller para atenderla. Si dos personas distintas hacen una petición al mismo tiempo, son dos objetos distintos de la misma clase controller.
=end
usuario_a = ControllerConBug.new   # simula: llega el request de la persona A
usuario_b = ControllerConBug.new   # simula: llega el request de la persona B, distinta

#Hasta acá, son dos objetos separados — uno para cada persona, cada uno atendiendo su propia petición.

#Ahora, el bug en acción
usuario_a.seleccionar("Paniol Norte")
puts usuario_b.paniol_actual

=begin
Paso a paso:

1. La persona A elige "Paniol Norte" en su pantalla → se llama usuario_a.seleccionar("Paniol Norte")
2. Dentro de seleccionar, se ejecuta @@paniol_seleccionado = "Paniol Norte"
3. Acá está el problema: como @@paniol_seleccionado es de la clase, no del objeto usuario_a, este cambio no queda "guardado dentro de usuario_a" — queda guardado en un lugar compartido por absolutamente todas las instancias de ControllerConBug
4. Ahora, la persona B — que nunca eligió nada, ni siquiera sabe que existe "Paniol Norte" — consulta usuario_b.paniol_actual
5. Ese método lee @@paniol_seleccionado — y como es la misma caja compartida, devuelve "Paniol Norte", el valor que la persona A eligió
=end




#--------------------------------------------
#--------------------------------------------
#--------------------------------------------
##3. Variables globales ($variable)
def procesar_con_salida(mensaje, out: $stdout)
  out.puts "Procesando: #{mensaje}"
end

=begin
El punto clave del documento: en tev no existen variables globales propias - el unico $ que usan es $tsdout, que ya viene predefinida por Ruby, y la usan como 'valor por defecto de un parametro', no como variable global manipulada directamente.

Por qué es útil este patrón exacto — permite testear sin tocar la salida real:
=end
require "stringio"
salida_de_prueba = StringIO.new
procesar_con_salida("factura 123", out: salida_de_prueba)
puts salida_de_prueba.string
# => Procesando: factura 123
# En el test, "out" nunca toco la consola real ($stdout) - se redirigio a un objeto de prueba

# Ejercicio 1
def log_evento(mensaje, salida: $stdout)
  salida.puts "[LOG] #{mensaje}"
end
log_evento("Ticket CORD-95 cerrado")
# out no se paso -> usa el default $stdout (la consola real)
# => [LOG] Ticket CORD-95 cerrado

# Ejercicio 2
require "stringio"
buffer = StringIO.new
def log_evento(mensaje, salida: $stdout)
  salida.puts "[LOG] #{mensaje}"
end
log_evento("Test de exportacion", salida: buffer)
puts buffer.string
# Aca SI se paso "salida", entonces usa buffer en vez de $stdout
# => [LOG] Test de exportacion

# Ejercicio 3
def reporte_diario(datos, destino: $stdout)
  datos.each { |d| destino.puts d }
end
reporte_diario(["Socio A", "Socio B"])
# Sin destino explicito -> imprime en consola real
# => Socio A
# => Socio B

# Ejercicio 4
def validar_stock(producto, cantidad, log: $stdout)
  if cantidad <= 0
    log.puts "ERROR: #{producto} sin stock"
  else
    log.puts "OK: #{producto} con #{cantidad} unidades"
  end
end
validar_stock("Cemento", 0)
# => ERROR: Cemento sin stock

# Ejercicio 5
require "stringio"
def exportar_excel(filas, writer: $stdout)
  filas.each { |f| writer.puts "Fila exportada: #{f}" }
end
buffer_test = StringIO.new
exportar_excel(["PAL-01", "PAL-02"], writer: buffer_test)
puts buffer_test.string.lines.count
# Cuenta cuantas lineas se "escribieron" en el buffer de prueba, sin tocar la consola real
# => 2






#--------------------------------------------
#--------------------------------------------
#--------------------------------------------
###4. private / protected / public
=begin
Ya viste el caso básico de private y el caso de protected comparando dos instancias (Rendimiento#mejor_que?). El caso nuevo es forwarding de bloque entre métodos privados "hermanos":
=end
class LectorArchivo
  def initialize(extension)
    @extension = extension
  end

  def leer(&block)
    procesar(&block)
  end

  private

  def procesar(&block)
    @extension == ".xlsx" ? leer_xlsx(&block) : leer_csv(&block)
  end

  def leer_xlsx
    yield "fila desde xlsx"
  end

  def leer_csv
    yield "fila desde csv"
  end
end

=begin
procesar(&block) recibe el bloque capturado y lo reenvia a otro metodo privado (leer_xlsx o leer_csv), que a su vez lo ejecuta con yield. Es la combinación de las dos técnicas que ya viste (&block y yield) trabajando juntas, pasando el bloque de método en método sin perderlo.
=end
# Ejercicio 1
class ServicioSimple
  def initialize(valor)
    @valor = valor
  end
  def call
    formatear(@valor)
  end
  private
  def formatear(valor)
    "Valor: #{valor}"
  end
end
s = ServicioSimple.new(10)
puts s.call
# call() es publico, puede usar formatear() (privado) porque esta LLAMANDO
# desde adentro del mismo objeto (sin especificar receptor)
# => Valor: 10

# Ejercicio 2
class Comparador
  def initialize(puntaje)
    @puntaje = puntaje
  end
  def gana_a?(otro)
    puntaje > otro.puntaje
  end
  protected
  def puntaje
    @puntaje
  end
end
c1 = Comparador.new(80)
c2 = Comparador.new(60)
puts c1.gana_a?(c2)
# gana_a? necesita leer @puntaje de "otro" (otra instancia). Con protected,
# c1 SI puede llamar otro.puntaje porque otro es de la MISMA clase (Comparador)
# => true

#La función real de protected en el proyecto: sirve específicamente para el caso de comparar o combinar datos internos entre dos instancias de la misma clase, manteniendo esos datos ocultos para el resto del mundo (nadie afuera puede hacer c1.puntaje directo), pero permitiendo que los objetos "entre ellos" se consulten datos internos entre sí cuando necesitan compararse.

# Ejercicio 3
class ProcesadorPedido
  def procesar(id)
    validar(id)
    "Pedido #{id} procesado"
  end
  private
  def validar(id)
    raise "ID invalido" if id.nil?
  end
end
p = ProcesadorPedido.new
puts p.procesar(101)
# procesar (publico) llama validar (privado) desde adentro -> funciona
# => Pedido 101 procesado

# Ejercicio 4
class LectorDatos
  def initialize(formato)
    @formato = formato
  end
  def leer(&block)
    despachar(&block)
  end
  private
  def despachar(&block)
    @formato == "json" ? leer_json(&block) : leer_texto(&block)
  end
  def leer_json
    yield "dato en json"
  end
  def leer_texto
    yield "dato en texto plano"
  end
end
LectorDatos.new("json").leer { |d| puts "Recibido: #{d}" }
# leer() recibe el bloque, lo reenvia a despachar() (privado), que decide
# a cual metodo interno reenviarlo, y ese metodo finalmente lo ejecuta con yield
# => Recibido: dato en json

# Ejercicio 5 (mostrando el error si intentas llamar el privado desde afuera)
class Calculadora
  def resultado
    sumar(2, 3)
  end
  private
  def sumar(a, b)
    a + b
  end
end
calc = Calculadora.new
puts calc.resultado    # funciona, llamado desde adentro
# calc.sumar(2, 3)      # esto rompe: NoMethodError (private method 'sumar')
# => 5