json.set! '@context', 'https://www.w3.org/ns/activitystreams'

json.id actor.federated_url
json.name actor.name
json.type 'Person'
json.inbox actor.inbox_url
json.outbox actor.outbox_url
json.url actor_url(actor)

