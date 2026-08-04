class ArticlesController < ApplicationController
    def index
        @articles = Article.all
    end

    def show
        @article = Article.find(params[:id])
    end

    def new
        @article = Article.new
    end

    def create
        @article = Article.new(article_params)
        if @article.save
            redirect_to @article
        else
            render :new
        end
    end

    private

    def article_params
        params.require(:article).permit(:title, :content)
    end
end

#params es un hash (tecnimanete un objeto 'ActionController::Parameters, pero se comporta como un hash) que contiene todos los datos que llegaton en la peticion HTTP - tanto los datos que llegaron en la peticion HTTP - tanto los que vienen en la URL como los del formulario/body
#params[:id] especificamente saca el valor de ':id' que viene de la URL,  gracias al patrón de la ruta.
#Recordá la ruta que generó resources :articles:
=begin
GET /articles/:id -> articles#show

Ese id en la ruta es un placeholder - cuando alguien visita /articles/5, rails automaticmaente captura ese '5' y lo mete en 'params[:id]'

entonces:
@article = Article.find(params[:id])
Se lee: "buscá el Article cuyo id sea el que vino en la URL". Si visitás /articles/5, esto ejecuta el equivalente a Article.find(5) → busca en la tabla articles el registro con id = 5.
=end
