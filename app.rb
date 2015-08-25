require 'sinatra'
require 'sinatra-websocket'
require 'task_list/filter'
require './helpers'

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

pipeline = HTML::Pipeline.new [
  HTML::Pipeline::MarkdownFilter,
  HTML::Pipeline::SanitizationFilter,
  HTML::Pipeline::EmojiFilter,
  TaskList::Filter,
  MarkdownHub::SyntaxHighlightFilter
], {:asset_root => '/images'}

get %r{\A\/(plain|gfm)\z} do |renderer|
  request.websocket do |ws|
    ws.onmessage do |msg|
      result = pipeline.call(msg, :gfm => renderer == 'gfm')
      EM.next_tick do
        settings.sockets.each{|s| s.send(result[:output].to_s) }
      end
    end
  end
end
