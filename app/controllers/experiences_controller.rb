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
    @book = Book.find_by_asin params[:asin]
    if @book
     @experience = Experience.create do |experience|
        experience.book_id = @book.id
        experience.user_id = current_user.id
        experience.started_at = Time.now 
        experience.code = params[:code]
      end
    end
  end

  # PUT /experiences/1
  # PUT /experiences/1.json
  def update
    # TODO security, only the owner can do this
    @experience = Experience.find(params[:id])
    @experience.update_attributes(params[:experience])
    render :update
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

  def recommend
    @book = Book.find params[:id]
    @experience = Experience.find(params[:id])
    @friends = []
    @friends_with_experience = []
    uid_people_have_read = @book.cache_people_have_read.map{|user| user[:uid]}
    uid_people_are_reading = @book.cache_people_are_reading.map{|user| user[:uid]}
    uid_people_will_read = @book.cache_people_will_read.map{|user| user[:uid]}
    uid_people_with_recommendations = @book.cache_people_with_recommendations.map{|user| user[:uid]}
    current_user.friends.each do |friend| 
      if uid_people_have_read.include?(friend['id']) || uid_people_are_reading.include?(friend['id'])  || uid_people_will_read.include?(friend['id']) || uid_people_with_recommendations.include?(friend['id']) 
        @friends_with_experience << friend
      else
        @friends << friend
      end
    end
    

    # TODO REMOVE ME or DIE
    #50.times { @friends << {'id' => rand(1000000).to_s, 'name' => 'tasfsd' } }
    
  end

  def create_recommendations

    @book = Book.find params[:id]
    @friends_in = []
    @friends_out = []
    @selected_friends = current_user.friends?(params[:uid])
    if !@selected_friends.empty? && @book
      @selected_friends.each do |friend|
        user = User.find_by_uid(friend['id'])
        user = User.create(:uid => friend['id'], :name => friend['name'] ) unless user
        @friends_in << friend if user.token
        @friends_out << friend unless user.token
        begin 
          Experience.create do |experience|
           experience.book_id = @book.id
           experience.user_id = user.id
           experience.recommender_id = current_user.id
            experience.started_at = Time.now 
            experience.code = 3
          end
        rescue Experience::DuplicatedExperience => e
          logger.error("ERROR #{e.message}")

        end
      end
    end
  end

end
