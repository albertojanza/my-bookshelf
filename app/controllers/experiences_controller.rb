class ExperiencesController < ApplicationController
  # GET /experiences
  # GET /experiences.json
  def index
    @experiences = Experience.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @experiences }
    end
  end

  # GET /experiences/1
  # GET /experiences/1.json
  def show
    @experience = Experience.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @experience }
    end
  end

  # GET /experiences/new
  # GET /experiences/new.json
  def new
    @experience = Experience.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @experience }
    end
  end

  # GET /experiences/1/edit
  def edit
    @experience = Experience.find(params[:id])
  end

  # POST /experiences
  # POST /experiences.json
  def create
    book = Book.find_by_asin params[:asin]
    if book
     Experience.create do |experience|
        experience.adventure_id = book.adventure.id
        experience.user_id = current_user.id
        if params[:now]
        experience.started_at = Time.now 
        experience.code = 1
        end
      end

    end
  end

  # PUT /experiences/1
  # PUT /experiences/1.json
  def update
    # TODO security, only the owner can do this
    @experience = Experience.find(params[:id])
    @experience.update_attributes(params[:experience])
    render :create
  end

  # DELETE /experiences/1
  # DELETE /experiences/1.json
  def destroy
    @experience = Experience.find(params[:id])
    @experience.destroy

    respond_to do |format|
      format.html { redirect_to experiences_url }
      format.json { head :ok }
    end
  end
end
