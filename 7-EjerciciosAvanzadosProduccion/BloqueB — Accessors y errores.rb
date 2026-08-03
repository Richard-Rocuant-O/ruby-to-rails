###Bloque B — Accessors y errores
# 5. attr_reader/writer/accessor — con setter capado
#el patron: exponer lectura, pero bloquear escritura desde afuera

class LoaderSimulado
    attr_accessor :datos
    private :datos=

  def initialize
    @datos = { cargado: true }
  end
end

=begin
attr_accessor :datos — genera dos métodos: datos (getter) y datos= (setter), ambos públicos por defecto.

private :datos = -esta linea toma el metodo 'datos=' (que attr_accessor acaba de crear) y lo vuelve privado. 'private' acepta simbolos como argumento - puedes pasarle el nombre de cualquier metodo ya existente para volverlo privado, no solo usarlo como "todo lo de abajo es privado"

Resultado neto: datos (leer) sigue siendo público, pero datos= (escribir) queda bloqueado desde afuera.
=end
loader = LoaderSimulado.new
p loader.datos          # => {cargado: true}   (funciona, getter publico)
loader.datos = {}       # ERROR: private method 'datos=' called

# Patrón adicional del documento — test double con attr_reader

class ClienteFalso
    attr_reader :llamadas
    def initialize (respuesta)
        @respuesta = respuesta
        @llamadas = []
    end
    def consultar(desde,hasta)
        @llamadas <<[desde,hasta]
        @respuesta
    end
end

#attr_reader :llamadas expone un array que se va llenando cada vez que se usa consultar, permitiendo que un test verifique después con qué argumentos fue llamado el método — sin necesitar una gema de mocking.

# 5 ejercicios explicados (orientados a Cordenap/PREF):

# Ejercicio 1
class ConfigFacturacion
  attr_accessor :billing_start
  private :billing_start=

  def initialize(fecha)
    @billing_start = fecha
  end

  def actualizar_por_admin(nueva_fecha)
    self.billing_start = nueva_fecha  # esto SI funciona, porque se llama desde ADENTRO de la clase
  end
end
config = ConfigFacturacion.new("2026-01-01")
puts config.billing_start
config.actualizar_por_admin("2026-02-01")
puts config.billing_start
# config.billing_start = "2026-03-01"  # esto rompe: setter privado, no se puede desde afuera
# El getter (billing_start) sigue publico, pero solo un metodo INTERNO puede reescribir el valor
# => 2026-01-01
# => 2026-02-01

# Ejercicio 2
class InventarioPalet
  attr_accessor :stock
  private :stock=

  def initialize(cantidad)
    @stock = cantidad
  end

  def descontar(cantidad)
    self.stock -= cantidad
  end
end
inv = InventarioPalet.new(100)
inv.descontar(30)
puts inv.stock
# El stock solo puede bajar a traves de descontar(), nunca reasignado directo desde afuera
# => 70

# Ejercicio 3 (test double, patron real de testing)
class ExportadorFalso
  attr_reader :llamadas

  def initialize
    @llamadas = []
  end

  def exportar(ticket_id, formato)
    @llamadas << [ticket_id, formato]
    "exportado"
  end
end
exportador = ExportadorFalso.new
exportador.exportar("CORD-95", "xlsx")
exportador.exportar("CORD-96", "pdf")
p exportador.llamadas
# El test puede verificar despues CON QUE argumentos se llamo exportar(), sin pegarle a un exportador real
# => [["CORD-95", "xlsx"], ["CORD-96", "pdf"]]

# Ejercicio 4
class Socio
  attr_reader :nombre, :id
  attr_accessor :estado
  private :estado=

  def initialize(id, nombre, estado)
    @id = id
    @nombre = nombre
    @estado = estado
  end

  def marcar_moroso
    self.estado = "moroso"
  end
end
socio = Socio.new(1, "Juan", "activo")
socio.marcar_moroso
puts socio.estado
# nombre e id son solo lectura (nunca deberian cambiar). estado se lee libre,
# pero solo se escribe a traves de metodos controlados como marcar_moroso
# => moroso

# Ejercicio 5 (test double con respuesta simulada)
class ClienteApiFalso
  attr_reader :llamadas

  def initialize(respuesta_simulada)
    @respuesta_simulada = respuesta_simulada
    @llamadas = []
  end

  def consultar_tarifa(pagador_id)
    @llamadas << pagador_id
    @respuesta_simulada
  end
end
cliente = ClienteApiFalso.new({tarifa: 1500})
resultado = cliente.consultar_tarifa(42)
p resultado
p cliente.llamadas
# Se simula la respuesta de una API real, y ademas se puede verificar
# que consultar_tarifa fue llamado exactamente con pagador_id=42
# => {tarifa: 1500}
# => [42]




########################
########################
########################
# 6. Excepciones personalizadas — con namespacing en módulo

module DocumentoAdjuntos
  class LimiteAdjuntosExcedido < StandardError; end
end

def agregar_adjunto(cantidad_actual,maximo)
    raise DocumentoAdjuntos::LimiteAdjuntosExcedido,"Se supero el limite de #{maximo} adjuntos" if cantidad_actual >= maximo
    "Adjunto agregado"
end

=begin
Lo nuevo respecto a lo que ya viste: La excepcion no esta 'suelta' (class MiError < StandardError), sino anidada dentro de un modulo - usando el '::' que ya vimos. Esto agrupa la excepcion bajo el do9mibnio al que pertenece (DocumentoAdjuntos), evitando choques de nombre si otra parte del codigo tambien define un error generico llamado 'LimiteExcedido'
=end
begin
  agregar_adjunto(5, 5)
rescue DocumentoAdjuntos::LimiteAdjuntosExcedido => e
  puts "Error: #{e.message}"
end
#Al recatar, tienes que usar el mismo path completo (Modulo::Excepcion), igual que al lanzarla

# 5 ejercicios explicados:
# Ejercicio 1

module CordenapErrors
  class SocioDuplicadoError < StandardError; end
end

def crear_socio(rut, ruts_existentes)
  raise CordenapErrors::SocioDuplicadoError, "El RUT #{rut} ya esta registrado" if ruts_existentes.include?(rut)
  "Socio creado"
end

begin
  crear_socio("12345678-9", ["12345678-9"])
rescue CordenapErrors::SocioDuplicadoError => e
  puts "Error: #{e.message}"
end
# => Error: El RUT 12345678-9 ya esta registrado

# Ejercicio 2
module PrefErrors
  class StockInsuficienteError < StandardError; end
end

def despachar_palet(cantidad, stock_disponible)
  raise PrefErrors::StockInsuficienteError, "Solo hay #{stock_disponible} unidades" if cantidad > stock_disponible
  "Despacho realizado"
end

begin
  despachar_palet(50, 30)
rescue PrefErrors::StockInsuficienteError => e
  puts "Error: #{e.message}"
end
# => Error: Solo hay 30 unidades

# Ejercicio 3
module LmaErrors
  class CapacidadExcedidaError < StandardError; end
end

def asignar_electivo(inscritos, capacidad_maxima)
  raise LmaErrors::CapacidadExcedidaError, "Capacidad maxima de #{capacidad_maxima} alcanzada" if inscritos >= capacidad_maxima
  "Electivo asignado"
end

begin
  asignar_electivo(30, 30)
rescue LmaErrors::CapacidadExcedidaError => e
  puts "Error: #{e.message}"
end
# => Error: Capacidad maxima de 30 alcanzada

# Ejercicio 4 (dos excepciones en el mismo modulo, rescatadas juntas)
module CordenapErrors
  class SocioDuplicadoError < StandardError; end
  class SocioInactivoError < StandardError; end
end

def validar_acceso(socio_activo, rut_duplicado)
  raise CordenapErrors::SocioDuplicadoError, "RUT duplicado" if rut_duplicado
  raise CordenapErrors::SocioInactivoError, "Socio inactivo" unless socio_activo
  "Acceso permitido"
end

begin
  puts validar_acceso(false, false)
rescue CordenapErrors::SocioDuplicadoError, CordenapErrors::SocioInactivoError => e
  puts "Error: #{e.message}"
end
# Se pueden rescatar VARIAS excepciones del mismo modulo en un solo rescue, separadas por coma
# => Error: Socio inactivo

# Ejercicio 5
module PrefErrors
  class CuradoIncompletoError < StandardError; end
end

def despachar_si_curado(horas_curado, minimo_requerido)
  raise PrefErrors::CuradoIncompletoError, "Faltan #{minimo_requerido - horas_curado}h de curado" if horas_curado < minimo_requerido
  "Palet listo para despacho"
end

begin
  puts despachar_si_curado(20, 48)
rescue PrefErrors::CuradoIncompletoError => e
  puts "Error: #{e.message}"
end
# => Error: Faltan 28h de curado
