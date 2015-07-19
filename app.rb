require 'github/markdown'
require 'sinatra'
require 'sinatra-websocket'

set :server, 'thin'
set :sockets, []

get '/' do
  if !request.websocket?
    erb :index
  else
    request.websocket do |ws|
      ws.onopen do
        settings.sockets << ws
      end
      ws.onclose do
        settings.sockets.delete(ws)
      end
    end
  end
end

get %r{\A\/(plain|gfm)\z} do |renderer|
  request.websocket do |ws|
    ws.onmessage do |msg|
      if renderer == 'gfm'
        html = GitHub::Markdown.render_gfm(msg)
      else
        html = GitHub::Markdown.render(msg)
      end
      EM.next_tick do
        settings.sockets.each{|s| s.send(html) }
      end
    end
  end
end
