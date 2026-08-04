class PagesController < ApplicationController
  def hola
    render plain: "Hola desde rails y el controlador pages"
  end

  def about
    @message = "Bienvenido a la pagina de about"
  end
end
