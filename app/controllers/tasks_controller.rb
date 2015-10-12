class TasksController < ApplicationController

  respond_to :json

  def daily_tasks
    unless(params[:date].nil?)
      today = DateTime.strptime(params[:date], '%m/%d/%y %l:%M:%S %p')
      @tasks = Task.where('start_time BETWEEN ? AND ?', today.beginning_of_day, today.end_of_day).all
    else
      @tasks = Task.all
    end
  end

  def task_params
    params.require(:task).permit(:name, :start_time, :end_time, :notes, :date)
  end

  def edit
    task = Task.find(params[:id])
    task.notes = params[:notes]
  end
end
