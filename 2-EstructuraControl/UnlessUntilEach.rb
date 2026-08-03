#=========================
#UNLESS (bloque) - 5 ejercicios
#=========================
socio = false
unless socio
  puts "No es socio"
end

stock_disponible = 0
unless stock_disponible > 0
  puts "No hay stock disponible"
end

pr_aprobado = false
unless pr_aprobado
  puts "El proyecto no fue aprobado"
end

factura_pagada = true
unless factura_pagada
    puts "La factura no ha sido pagada"
end

palet_curado = false
unless palet_curado
    puts "El palet no ha sido curado"
end

# ==========================================
# UNTIL - 3 ejercicios
# ==========================================
ticket = 90
until ticket >95
    puts "El ticket es menor a 95"
    ticket += 1
end

palets_producidos = 0
until palets_producidos >= 5
    puts "Se han producido menos de 5 palets"
    palets_producidos += 1
end

sesiones_creadas = 0
until sesiones_creadas == 3
    puts "Se han creado menos de 3 sesiones"
    sesiones_creadas += 1
end

# ==========================================
# EACH - 5 ejercicios
# ==========================================
tickets = [90, 91, 92, 93, 94]
tickets.each do |t|
    puts "El ticket es #{t}"
end

socios = ["Juan", "Pedro", "Maria"]
socios.each do |s|
    puts "El socio es #{s}"
end

campus = ["Campus A", "Campus B", "Campus C"]
campus.each do |c|
    puts "El campus es #{c}"
end

observaciones_alex = [ "Observacion 1", "Observacion 2", "Observacion 3" ]
observaciones_alex.each do |o|
    puts "La observacion es #{o}"
end

pallets = [ "Palet 1", "Palet 2", "Palet 3" ]
pallets.each do |p|
    puts "El palet es #{p}"
end


# ==========================================
# MODIFICADOR UNLESS (una linea) - 5 ejercicios
# ==========================================
tiene_contractor = false
puts "no tiene contractor" unless tiene_contractor
#Esta es la forma "en una linea" (modificador de sentencia) del unless

campus_asignado = true
puts "Mostrar campo Campamento" unless campus_asignado

migracion_aplicada = false
puts "Falta aplicar la migracion" unless migracion_aplicada

usuario_activo = true
puts "El usuario no esta activo" unless usuario_activo

palet_curado = false
puts "El palet no ha sido curado" unless palet_curado