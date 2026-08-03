class LinksController < ApplicationController
  def index
    @link  = Link.new
    @links = Link.newest_first
  end

  def show
    @link = Link.find(params[:id])
  end

  def create
    @link = Link.new(link_params)

    if @link.save
      redirect_to root_path, notice: "Shortened to /#{@link.slug}."
    else
      @links = Link.newest_first
      render :index, status: :unprocessable_content
    end
  end

  def destroy
    Link.find(params[:id]).destroy!

    redirect_to root_path, notice: "Link deleted.", status: :see_other
  end

  private
    def link_params
      params.expect(link: [ :url, :slug ])
    end
end
