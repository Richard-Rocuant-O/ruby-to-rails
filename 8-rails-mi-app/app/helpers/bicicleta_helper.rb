module BicicletaHelper
  def mostrar_estado(bicicleta)
    bicicleta.activa? ? "Activa" : "Inactiva"
  end
end
