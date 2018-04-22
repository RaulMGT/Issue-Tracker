class IssuesController < ApplicationController
  before_action :set_issue, only: [:show, :edit, :update, :destroy]

  # GET /issues
  # GET /issues.json
  def index

    @issues = []
    filtered = false
    if params[:status]
      @status = Status.where('lower(name) = ?', params[:status].downcase).first 
      @issues = @issues.concat(Issue.where(status_id: @status.id))
      filtered = true
    end

    if params[:responsible]
      @user = User.where('lower(email) = ?', params[:responsible].downcase).first 
      @issues = @issues.concat(Issue.where(user_id_2: @user.id))
      filtered = true
    end
    if params[:responsiblename]
      @user = User.where('lower(name) = ?', params[:responsiblename].downcase).first
      @issues = @issues.concat(Issue.where(user_id_2: @user.id))
      filtered = true
    end
    if params[:kind]
      @kind = Kind.where('lower(name) = ?', params[:kind].downcase).first 
      @issues = @issues.concat(Issue.where(kind_id: @kind.id))
      filtered = true
    end
    if params[:priority]
      @priority = Priority.where('lower(name) = ?', params[:priority].downcase).first 
      @issues = @issues.concat(Issue.where(priority_id: @priority.id))
      filtered = true
    end

    if params[:watching]
      @user = User.where('lower(email) = ?', params[:watching].downcase).first
      @issues = @issues.concat(Issue.joins(:watches).where('watches.user_id' => @user))
      filtered = true
    end

    @issues = filtered ? @issues.uniq : Issue.all


    @watch = Watch.new

  end

  # GET /issues/1
  # GET /issues/1.json
  def show
    @comment = Comment.new
    @comments = Comment.where issue_id: params[:id]
    @comments = [] if @comments.nil?
    @vote = Vote.new
    @watch = Watch.new
    @status = Status.all
  end

  # GET /issues/new
  def new
    @issue = Issue.new
  end

  # GET /issues/1/edit
  def edit
  end

  # POST /issues
  # POST /issues.json
  def create
    @issue = Issue.new(issue_params)
    @issue.status_id = 1;
    respond_to do |format|
      if @issue.save
        watch = Watch.new
        watch.issue_id = @issue.id;
        watch.user_id = @issue.user_id;
        watch.save
        if (!@issue.user_id_2.nil?)
          if (@issue.user_id != @issue.user_id_2)
            watch2 = Watch.new
            watch2.issue_id = @issue.id;
            watch2.user_id = @issue.user_id_2;
            watch2.save
          end
        end
        format.html { redirect_to @issue }
        format.json { render :show, status: :created, location: @issue }
      else
        format.html { render :new }
        format.json { render json: @issue.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete_attachment
    @issue = Issue.find(params[:id])
    @issue.attachment = nil
    @issue.save
    redirect_to @issue
end

  # PATCH/PUT /issues/1
  # PATCH/PUT /issues/1.json
  def update
    respond_to do |format|
      if @issue.update(issue_params)
        if (!@issue.user_id_2.nil?)
          if (Watch.find_by(issue_id: @issue.id, user_id: @issue.user_id_2).nil?)
            watch = Watch.new
            watch.issue_id = @issue.id;
            watch.user_id = @issue.user_id_2;
            watch.save
          end
        end
        format.html { redirect_to @issue }
        format.json { render :show, status: :ok, location: @issue }
      else
        format.html { render :edit }
        format.json { render json: @issue.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /issues/1
  # DELETE /issues/1.json
  def destroy
    @issue.destroy
    respond_to do |format|
      format.html { redirect_to issues_url }
      format.json { head :no_content }
    end
  end

  def status_edit
    issue = Issue.find(params[:issue_id])
    issue.update(status_id: params[:status_id])
    redirect_to request.referer
  end

  def spam
    issue = Issue.find(params[:issue_id])
    issue.update(spam: !issue.spam)
    redirect_to request.referer
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_issue
      @issue = Issue.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def issue_params
      params.require(:issue).permit(:user_id, :user_id_2, :title, :description, :kind_id, :priority_id, :status_id, :spam, :attachment)
    end
end
