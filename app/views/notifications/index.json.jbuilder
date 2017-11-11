json.array! @notifications do |notification| 
    json.id notification.id
    json.actorable notification.actorable.name
    json.actor notification.action
    json.type notification.notifiable.class.to_s.underscore.humanize.downcase
end 
