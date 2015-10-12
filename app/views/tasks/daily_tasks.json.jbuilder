json.tasks do
  json.array! @tasks, partial: 'task', as: :task
end