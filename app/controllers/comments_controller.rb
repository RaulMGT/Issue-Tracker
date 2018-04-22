class CommentsController < ApplicationController
  def index
    render text: 'ohai'
  end

  # POST /comments
  # POST /comments.json
  def create
    comment = Comment.create(comment_params)
    issue = Issue.find comment[:issue_id]

    comment.save
    redirect_to issue
  end

  def destroy
    Comment.delete params[:comment_id]
    issue = Issue.find params[:issue_id]
    redirect_to issue
  end

  def update
    comment = Comment.find params[:comment_id]
    comment.description = params[:description]
    comment.save
    issue = Issue.find params[:issue_id]
    redirect_to issue
  end

  def spam
    comment = Comment.find(params[:comment_id])
    comment.update(spam: !comment.spam)
    redirect_to request.referer
  end

  private

  def comment_params
    params.require(:comment).permit(:description, :issue_id, :user_id)
  end

end
