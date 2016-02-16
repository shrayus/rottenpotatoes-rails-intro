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
    
    #invalid params
    if !params[:ratings] and session[:ratings]
      if params[:sort]
        session[:sort] = params[:sort]
      end
      flash.keep
      redirect_to movies_path(:sort=>session[:sort], :ratings=>session[:ratings])
    end
    
    #Ratings Section
    @all_ratings = Movie.get_ratings
    ratings = params[:ratings]
    @ratings = ratings.nil? ? @all_ratings : ratings
    @movies = @movies.find_all {|m| @ratings.include?(m.rating)}
    
    #Sort by Title/Release
    if(params[:sort] == 'title' or session[:sort] == 'title')
      @movies = @movies.sort_by{|m| m.title }
    elsif(params[:sort] == 'release' or session[:sort] == 'release')
      @movies = @movies.sort_by{|m| m.release_date.to_s }
    else
      params[:sort] = ''
    end
    
    #save current session
    session[:ratings] = @ratings
    session[:sort] = params[:sort]
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
