require 'rubygems'
require 'em-websocket'
 
EventMachine.run do
    @channels = {}
	mappa= Hash.new()
     
    EventMachine::WebSocket.start(
      :host => "0.0.0.0", :port => 8080) do |ws|     
 
      ws.onmessage do |msg|
        command, params = msg.split(":",2)
		if(command == "c")
			room, chiamante = params.split(":",2)
			@channels[room] ||= EM::Channel.new 
			sid = @channels[room].subscribe{ |msg| ws.send msg }
			printf  "avviato canale %d con id %d\n",room,sid
			mappa.store(room+":"+chiamante,sid)		
		elsif (command == "d")
			begin
				room, chiamante = params.split(":",2)
				@channels[room].unsubscribe(mappa[params])
				@channels.delete(ws)
				printf  "chiusura canale %d con id %d\n",room,mappa[params]
				mappa.delete(room+":"+chiamante)
				ary = Array.new
				ary = mappa.keys
				if(ary.count < 1)
					printf "chiavi eliminate \n"
					@channels = {}
				else
					printf "array di chiavi "
				end
			rescue
			end
		elsif (command == "g")
			printf "chiavi resettate \n"
			@channels = {}
        else
			room, message = params.split(":",2)
			printf  "messaggio %s sul canale %d \n",message, room
			@channels[room].push message
			printf  "messaggio %s sul canale %d \n",message, room
        end
      end  
    end
     
end