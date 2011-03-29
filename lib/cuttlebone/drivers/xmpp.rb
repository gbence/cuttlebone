require 'xmpp4r/client'
require 'xmpp4r/roster'
require File.expand_path('../../../../vendor/rexml_utf8_fix', __FILE__)

class Cuttlebone::Drivers::XMPP < Cuttlebone::Drivers::Base
  @@jid      = 'cuttlebone@localhost'
  @@password = 'cuttlebone'

  def self.jid= jid
    @@jid = jid
  end

  def self.password= password
    @@password = password
  end

  def run
    client = Jabber::Client.new(@@jid)
    client.connect()
    client.auth(@@password)
    client.send(Jabber::Presence.new.set_type(:available))

    roster = Jabber::Roster::Helper.new(client)

    client.add_message_callback do |message|
      unless message.composing? or message.body.nil?
        begin
          session = sessions[message.from]
        rescue Cuttlebone::Session::NotFound
          session = sessions.create(:id => message.from)
        end

        begin
          _, _, output, error = session.call(message.body.force_encoding("UTF-8"))
        rescue
          output, error = nil, $!.message
        end

        result          = Jabber::Message.new
        result.to       = message.from
        result.body     = output.join("\n") if output
        result.body    += %{<<#{error}>>} if error
        client.send(result)
      end
    end

    roster.add_subscription_request_callback do |item,presence|
      roster.accept_subscription(presence.from)
      client.send(Jabber::Presence.new.set_type(:subscribe).set_to(presence.from))
      
      m      = Jabber::Message.new
      m.to   = presence.from
      m.body = "Registered!"
      client.send(m)
    end

    Thread.stop

    client.close
  end
end
