class WidgetsController < ApplicationController
  helper :hot_glue
  include HotGlue::ControllerHelper

  before_action :authenticate_user!
  
  before_action :load_widget, only: [:show, :edit, :update, :destroy]
  after_action -> { flash.discard }, if: -> { request.format.symbol ==  :turbo_stream }



  

  



  def load_widget
    @widget = current_user.widgets.find(params[:id])
  end
  

  def load_all_widgets
    @widgets = current_user.widgets.page(params[:page])
  end

  def index
    load_all_widgets
    respond_to do |format|
       format.html
    end
  end

  def new 
    @widget = Widget.new(user: current_user)
   
    respond_to do |format|
      format.html
    end
  end

  def create
    modified_params = modify_date_inputs_on_params(widget_params.dup.merge!(user: current_user ) , current_user)
    @widget = Widget.create(modified_params)

    if @widget.save
      flash[:notice] = "Successfully created #{@widget.name}"
      load_all_widgets
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to widgets_path }
      end
    else
      flash[:alert] = "Oops, your widget could not be created."
      respond_to do |format|
        format.turbo_stream
        format.html
      end
    end
  end

  def show
    respond_to do |format|
      format.html
    end
  end

  def edit
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def update

    if @widget.update(modify_date_inputs_on_params(widget_params, current_user))
      flash[:notice] = (flash[:notice] || "") << "Saved #{@widget.name}"
    else
      flash[:alert] = (flash[:alert] || "") << "Widget could not be saved."

    end

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def destroy
    begin
      @widget.destroy
    rescue StandardError => e
      flash[:alert] = "Widget could not be deleted"
    end
    load_all_widgets
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to widgets_path }
    end
  end

  def widget_params
    params.require(:widget).permit( [:name] )
  end

  def default_colspan
    1
  end

  def namespace
    ""
  end
end


