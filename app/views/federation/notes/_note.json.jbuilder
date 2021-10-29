context = true unless context == false
json.set! '@context', 'https://www.w3.org/ns/activitystreams' if context

json.id note.federated_url
json.type 'Note'
json.url note_url note
json.attributedTo note.actor.federated_url
json.content note.content

