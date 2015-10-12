class TasksController < ApplicationController

  respond_to :json
  skip_before_action :verify_authenticity_token

  def daily_tasks
    unless(params[:date].nil?)
      today = DateTime.strptime(params[:date], '%m/%d/%y %l:%M:%S %p')
      @tasks = Task.where('start_time BETWEEN ? AND ?', today.beginning_of_day, today.end_of_day).all
    else
      @tasks = Task.all
    end
    render 'tasks/index'
  end

  def edit
    @task = Task.find(params[:id])
    @task.notes = params[:notes]
    @task.save
    render 'tasks/show'
  end

  def create
    formatted_start = DateTime.strptime(params[:start_time], '%m/%d/%y %l:%M:%S %p') unless params[:start_time].nil?
    formatted_end = DateTime.strptime(params[:end_time], '%m/%d/%y %l:%M:%S %p') unless params[:end_time].nil?
    @task = Task.create(name: params[:name], start_time: formatted_start, end_time: formatted_end, notes: params[:notes])
    render 'tasks/show'
  end

  def task_params
    params.require(:task).permit(:name, :start_time, :end_time, :notes, :date)
  end

  def index
    @tasks = Task.order("start_time DESC")
  end

end
