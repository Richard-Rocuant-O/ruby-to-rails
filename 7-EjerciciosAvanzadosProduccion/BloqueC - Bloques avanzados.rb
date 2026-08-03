###Bloque C — Bloques avanzados

#7.Bloques / Proc / Lambda - casos de produccion

#Caso nuevo 1 - Lambda multilinea con 'do...end'
condicion_activo = lambda do |dato|
  dato[:fecha_salida].nil? || dato[:fecha_salida] > "2026-01-01"
end
puts condicion_activo.call({ fecha_salida: nil })

=begin
Por qué importa dónde vive esto en Rails real: el documento menciona que aparece en has_many con condición SQL larga — en Rails, un scope necesita ser un lambda/-> (no un valor directo) porque tiene que evaluarse de nuevo en cada consulta (la fecha de "ahora" cambia con el tiempo), no una sola vez cuando se carga la clase.
=end

# Caso nuevo 2 — lambda como "espía" en tests
llamadas_registradas = []
espia = lambda do |vehiculo_id, fecha|
  llamadas_registradas << [vehiculo_id, fecha]
  nil
end

espia.call(10, "2026-06-01")
espia.call(11, "2026-06-02")
p llamadas_registradas

=begin
La idea: en vez de una gema de mocking (RSpec Mocks, Mocha), usas una lambda simple que, cada vez que se llama, se registra a sí misma en un array externo (llamadas_registradas) antes de devolver su resultado. Después del test, revisas ese array para verificar qué se llamó, cuántas veces, y con qué argumentos exactos.
=end

# 5 ejercicios explicados:
# Ejercicio 1 - lambda multilinea, condicion de negocio
socio_habilitado = lambda do |socio|
  socio[:moroso] == false && socio[:activo] == true
end
puts socio_habilitado.call({moroso: false, activo: true})
# Evalua las 2 condiciones y devuelve el resultado del && (true solo si ambas son true)
# => true

# Ejercicio 2 - lambda multilinea con varias validaciones
palet_listo = lambda do |palet|
  return false if palet[:curado] == false
  return false if palet[:horas] < 48
  true
end
puts palet_listo.call({curado: true, horas: 50})
puts palet_listo.call({curado: true, horas: 20})
# Cada return corta la ejecucion apenas encuentra un problema. Si pasa ambos checks, llega al true final.
# => true
# => false

# Ejercicio 3 - lambda como espia, contando llamadas
llamadas = []
notificador_falso = lambda do |socio_id, tipo|
  llamadas << [socio_id, tipo]
end
notificador_falso.call(1, "bienvenida")
notificador_falso.call(2, "recordatorio_pago")
puts llamadas.length
p llamadas
# Cada .call agrega una entrada al array externo, permitiendo verificar despues cuantas veces se llamo
# => 2
# => [[1, "bienvenida"], [2, "recordatorio_pago"]]

# Ejercicio 4 - lambda espia verificando argumentos especificos
llamadas_export = []
exportador_espia = lambda do |ticket_id, formato|
  llamadas_export << {ticket: ticket_id, formato: formato}
  "ok"
end
exportador_espia.call("CORD-95", "xlsx")
fue_llamado_con_xlsx = llamadas_export.any? { |l| l[:formato] == "xlsx" }
puts fue_llamado_con_xlsx
# Se combina el espia con select/any? para verificar una condicion especifica sobre las llamadas
# => true

# Ejercicio 5 - lambda multilinea usada como scope simulado (patron real de ActiveRecord)
palets_curados = ->(lista) do
  lista.select { |p| p[:horas_curado] >= 48 }
end
palets = [{codigo: "PAL-01", horas_curado: 50}, {codigo: "PAL-02", horas_curado: 20}]
puts palets_curados.call(palets)
# La lambda encapsula la logica de filtrado, lista para reusarse en cualquier consulta futura
# => [{codigo: "PAL-01", horas_curado: 50}]