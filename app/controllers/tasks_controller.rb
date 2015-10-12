class TasksController < ApplicationController

  respond_to :json

  def daily_tasks
    @tasks = Task.all
  end

  def task_params
    params.require(:task).permit(:name, :start_time, :end_time, :notes)
  end
end
