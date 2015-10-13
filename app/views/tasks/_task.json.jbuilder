json.id task.id
json.name task.name
json.start_time task.start_time.strftime("%l:%M %p") unless task.start_time.nil?
json.end_time task.end_time.strftime("%l:%M %p") unless task.end_time.nil?
json.notes task.notes