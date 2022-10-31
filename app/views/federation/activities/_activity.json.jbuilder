context = true unless context == false
json.set! '@context', 'https://www.w3.org/ns/activitystreams' if context

json.id federation_actor_activity_url activity.actor, activity
json.type activity.action
json.actor activity.actor.federated_url
json.to ['https://www.w3.org/ns/activitystreams#Public']
json.object 'http://192.168.2.100:3000/federation/actors/1/notes/1.json'

