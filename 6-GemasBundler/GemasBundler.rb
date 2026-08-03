### Gemas: pequeñas cajas de herramientas que otros develops han creado y compartido
###Bundler: un administrador que se asegura que todas esas cajas (gemas) esten organizadas o esten listas para el proyecto
###RubyGems: sistema oficial de ruby para compartir e instalar gemas

#gemas conocidas
#pry: consola de ruby mejorado 

require 'bundler/setup'
require 'pry'
require 'faker'

puts Faker::Name.name
binding.pry