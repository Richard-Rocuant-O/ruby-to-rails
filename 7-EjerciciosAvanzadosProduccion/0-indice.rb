###Diferencia entre concurrente, paralelo, distruido

#1.Concurrente: Sucediendo en el mismo intervalo de tiempo. En los inicios de Unix, cuando habia un solo CPU, todos los procesos que corrian en un momento dado recibian "porciones" de tiempo procesador. Eran concurrenntes pero no paralelos - no habia comunicacion simultanea real, solo altenancia rapida que parecia simultanea.

#2.Paralelo: El procesamiento paralelo es una tecnica de computacion donde multiples operaciones o tareas se ejecutan simultaneamente en vez de secuencialmente. Se divide un problema en partes mas pequeñas, y esas partes se ejecutan de verdad al mismo tiempo, aprovechando multiples nucleos/procesadores de una sola maquina

#3.Distribuido - La computación distribuida divide un problema en tareas que se distribuyen entre multiples computadoras interconectadas que se comunican por ed para resolver un problema comun. La diferencia clave es que el paralelo usa múltiples procesadores en un computador, mientras que el distribuido usa múltiples computadores interconectados.

#La forma más simple de recordarlo, con ejemplo cotidiano:

#Concurrente: varias tareas avanzan en el mismo periodo, pero no necesariamente
#Paralelo: varias tareas ocurren literalemtne al mismo tiempo, en la misma maquina
#Distribuido: El trabajo se reparte entre máquinas distintas, que se coordinan por red

#Plan propuesto - 16 categorias

#Bloque A - Estado y visibilidad (ya se vio la mita, pero con datos Variables de instancia (con el caso nuevo: memoización a nivel de clase @datos_junio ||=)

#Variables de clase (@@) — el bug real
#Variables globales ($stdout)
#private / protected / public (con el caso nuevo de forwarding de bloque entre privados)

#Bloque B — Accessors y errores
#5. attr_reader/writer/accessor (con el patrón nuevo: accessor + setter capado con private, y el patrón test double)
#6. Excepciones personalizadas (con namespacing dentro de módulo)

#Bloque C - Bloques avanzados
#7. Bloques/Proc/Lambda (con los casos nuevos: lambda multilinea, lamda como espia de test)

#Bloque D - Metaprogramacion de produccion
#8. define_singleton_method, send+respond_to?, class_eval, lookup dinamico con hash de constantes

#Bloque E - Organizacion y utiliades funcionales
#9.Módulos como namespace + module_function
#10.OpenStruct
#11. Duck typing con respond_to?

#Bloque F - Seguridad de datos y sintaxis moderna
#12.Freeze
#13. Safe navigation (&.) y .tap
#14. Keyword arguments avanzados (splat, defaults, mezclas)

#Bloque G - Rendimiento y reflexion avanzada
#15.Set
#16.instance_variable_set/get y const_get