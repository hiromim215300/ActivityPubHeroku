require 'fediverse/notifier'
require 'net/https'

class NotifyInboxJob < ApplicationJob
  queue_as :default

  def perform(activity)
    puts(activity)
    puts("perform(activity) start!!")
    activity.reload
    Fediverse::Notifier.post_to_inboxes(activity)
#    uri = URI.parse("http://192.168.2.103:3000/federation/actors/1/inbox")
    uri = URI.parse("http://43.206.44.205:3000/federation/actors/1/inbox")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = false
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Post.new(uri.path)
    puts("marking")
    http.ca_file = "./cacert.pem.2"
    data = ApplicationController.renderer.new.render(
      template: 'federation/activities/show',
      locals: { :@activity => activity },
      format:   :json
    )
    puts(data)
#    data2 = 
    Faraday.post("http://43.206.44.205:3000/federation/actors/1/inbox", data)
#    Faraday.post "https://192.168.2.102:3000/federation/actors/1/inbox", data, 'Content-Type' => 'application/json', 'Accept' => 'application/json'
#    apipost(data)
#    req.set_form_data(data)
#    res = http.request(req)
#    res = http.post(uri.path, data)
#    puts("end time = #{Time.now}")
  end
end

