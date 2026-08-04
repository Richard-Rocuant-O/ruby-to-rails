class CommentsController < ApplicationController
    def index
        @article = Article.find(params[:article_id])
        @comments = @article.comments
    end

    def new
        @article = Article.find(params[:article_id])
        @comment = @article.comments.build
    end

    def show
        @article = Article.find(params[:article_id])
        @comment = @article.comments.find(params[:id])
    end

    def create
        @article = Article.find(params[:article_id])
        @comment = @article.comments.build(comment_params)
        if @comment.save
            redirect_to article_comment_path(@article, @comment)
        else
            render :new
        end
    end

    private

    def comment_params
        params.require(:comment).permit(:body)
    end
end

=begin
1. @article.comments: es la asociacion definida por 'has_many :comments' en el modelo Article - devuelve algo como una colección de comentarios de ese artículo.

2. .build (equivalente a 'new' cuando se llama sobre una asociacion) instancia un Comment nuevo y ya le setea article_id = @article.id. Lo mismo que hacer.
@comment = Comment.new(article_id: @article.id)


=end
