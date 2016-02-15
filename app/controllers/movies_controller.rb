class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @movies = Movie.all
    
    #Ratings Section
    @all_ratings = Movie.get_ratings
    ratings = params[:ratings]
    @ratings = ratings.nil? ? Movie.get_ratings : ratings.keys
    
    begin
      rating_list = "(" + @ratings.to_s[1..-2] + ")" #Because sql arrays have parens instead of brackets T_T 
      @movies = @movies.where("movies.rating in " + rating_list) #generate sql query for the website
    rescue UndefinedTable, UndefinedColumn
    
    end
    
    #Sorting by Title/Release
    if(params[:sort].to_s == 'title')
      @movies = @movies.sort_by{|m| m.title }
    elsif(params[:sort].to_s == 'release')
      @movies = @movies.sort_by{|m| m.release_date.to_s }
    else
      params[:sort] = ''
    end
    
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
