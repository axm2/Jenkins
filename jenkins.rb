#!/usr/bin/env ruby
#encoding: utf-8
require 'mumble-ruby'
require 'ruby-mpd'
#require 'cinch'
require 'colorize'
require 'rspotify'

RSpotify.authenticate("#######", "#######")
HOST = '127.0.0.1'
PORT = '6600'
mpd = MPD.new(HOST,PORT, {callbacks: true})
begin
        mpd.connect
        #mpd.password('chandler243')
    puts "Woot! Successfully linked to MPD"
rescue
        puts "Oh, crap. Looks like we couldn't communicate with the MPD server at #{HOST}:#{PORT}."
end

# No longer needed. Legacy code.
# cli = Mumble::Client.new('node.chandlershax.com', 64738, 'Jenkins')

Mumble.configure do |conf|
        conf.sample_rate = 48000
        conf.bitrate = 96000
end

cli = Mumble::Client.new('########') do |conf|
        conf.username = 'music_bot'
	conf.password = '#########'
end


#bot = Cinch::Bot.new do
 # configure do |c|
   # c.server = "irc.freenode.org"
   # c.channels = ["#ChandlersHax"]
  #end

  #on :message, "hello" do |m|
    #m.reply "Hello, #{m.user.nick}"
    #$channel = "Turtle Mumble"
  #end
#end


cli.connect
sleep(2)

stream = cli.player.stream_named_pipe('/tmp/mpd.fifo')
#stream.volume = 10
$vol = 100
VERSION = 0.3
#CHILL = false
SHUFFLE = true

$channel = "music"
cli.join_channel('music')
cli.text_channel($channel,"music_bot Version #{VERSION} Successfully Initialized.")
yt = "null"
system 'mpc repeat on'
mpd.on :song do |song|
        song = mpd.current_song
        puts "Hey, look! We are now playing #{song.file}"
end
$trackArtist=[]
$trackName=[]
$trackURI=[]
cli.on_text_message do |msg|
        case msg.message
        when "!skip"
                mpd.next
		sleep(1)
                song = `mpc current`
            cli.text_channel($channel,"Song skipped, now playing: "+ song)
        when "!uptime"
                uptime = `uptime -p | sed 's/up //'`
                cli.text_channel($channel,"Server has been up for "+ uptime)
        when "!reset"
                exec("~/Projects/Jenkins/jenkins.rb")
        when "!next"
                $channel = "music"
                print("Coming up: #{mpd.queue(1..10)}")
        when "!help"
                cli.text_channel($channel , "<br><center><strong>music_bot Commands</strong></center>
                        <dl>
                        <dt>Volume</dt>
                        <dd> - Run the commands !volume # !volUp and !volDown to adjust volume</dd>
                        <dt>Playback</dt>
                        <dd> - Use !skip and !play # to modify playback</dd>
                        <dt>Status</dt>
                        <dd> - Looking for the current status of the bot? !status to get detailed information</dd>
                        </dl>
                <strong>axm - 10/8/17</strong>")
        #when "!toggle"
                #system 'mpc toggle'
        when "!donger"
                #system 'mpc clear && mpc --host chandler243@localhost load gaben && mpc --host chandler243@localhost play'
                # mpd.clear
                # mpd.playlist.load('gaben')
                cli.text_channel($channel,"work it ᕙ༼ຈل͜ຈ༽ᕗ harder")
                cli.text_channel($channel,"make it (ง •̀_•́)ง better")
                cli.text_channel($channel,"do it ᕦ༼ຈل͜ຈ༽ᕤ faster")
                cli.text_channel($channel,"raise ur ヽ༼ຈل͜ຈ༽ﾉ donger")
        when "!clear"
                system 'mpc crop'
                cli.text_channel($channel,"Queue has been cleared of all songs except the current one")
	when "!song"
		song = `mpc current`
		cli.text_channel($channel, "The current song is: "+ song)
	when "!volup"
		system 'mpc volume +10'
		cli.text_channel($channel, "Volume has been increased by 10")
	when "!voldown"
		system 'mpc volume -10'
		cli.text_channel($channel, "Volume has been decreased by 10")
        #when "!resume"
                #system 'mpc  clear && mpc --host chandler243@localhost load derp && mpc --host chandler243@localhost random on && mpc --host chandler243@localhost play'
            #song = `mpc --host chandler243@localhost current`
                #cli.text_channel($channel, "Now resuming normal playback, starting off with " + song)
        #when "!loop"
                #system 'mpc repeat'
        when "!queue"
                queue = `mpc playlist -f "[%position%) %artist% - %title%]"`
            cli.text_channel($channel,queue)
        when "!status"
                status = `mpc`
            cli.text_channel($channel,status)
        #when "!song"
                #currentsong = `mpc current`
            #cli.text_channel($channel,currentsong)
        #when "!bigqueue"
                #cli.text_channel($channel,"Please standby, recompiling the queue...")
                #system "mpc --host chandler243@localhost clear"
                #system "mpc --host chandler243@localhost update"
                #system "mpc --host chandler243@localhost listall | mpc --host chandler243@localhost add"
                #sleep(2)
                #system "mpc --host chandler243@localhost play"
                #cli.text_channel($channel,"Finished compiling the queue. All songs added. Enjoy!")
        when "!shuffle" #Toggle Shuffle Status
                if SHUFFLE == true
                        cli.text_channel($channel, "Now shuffling songs, !shuffle again to stop.")
                        system `mpc random on`
                        SHUFFLE = !SHUFFLE
                else
                   cli.text_channel($channel, "No longer shuffling songs. !shuffle to start again.")
                        system `mpc random off`
                        SHUFFLE = !SHUFFLE
                end
        else
                 if /!yt./.match(msg.message)
                    yt = msg.message.match(/http[s]?:\/\/(.+?)\"/).to_s.chop
                    print(yt)
                    #yt = yt[4, 100]
                    system "mpc add yt:#{yt}"
                    cli.text_channel($channel, "The video located at #{yt}" + " has been successfully added to the current playlist")
		 
		 elsif /!seek./.match(msg.message)
			 seek = msg.message
			 seek = seek[6,100]
			 system "mpc seek #{seek}"
			 cli.text_channel($channel, "seeking...")
		 
		 elsif /!play./.match(msg.message)
			 play = msg.message
			 play = play[5,100]
			 system "mpc play #{play}"
			 cli.text_channel($channel, "Playing # #{play}" + " in the queue")
		 
		 elsif /!spotify./.match(msg.message)
                        spotify = msg.message
                        print(spotify)
                        spotify = spotify[1,100]
                        system "mpc add #{spotify}"
                        cli.text_channel($channel, "The song(s) located at #{spotify} has been successfully added to the current playlist")
                 
		 elsif /!volume./.match(msg.message)
                        volume = msg.message
			volume = volume[8,100]
			print(volume)
			system "mpc volume #{volume}"
                 
		 elsif /!ss./.match(msg.message)
			ss = msg.message
			ss = ss[4,100]
			searchTrack=ss
			track = RSpotify::Track.search(searchTrack)

			for i in 0..track.length - 1
				artist = track[i].artists[0]
				$trackArtist[i]=artist.name
				$trackName[i]=track[i].name
				$trackURI[i]=track[i].uri
			end

			for i in 0.. track.length - 1
				cli.text_channel($channel, (i+1).to_s + ") " + $trackName[i] + " By: " + $trackArtist[i] + "\n")
			end
			puts $trackURI

		 elsif /!sa./.match(msg.message)
			sa = msg.message
			sa = sa[4,100]
			sa = sa.to_i - 1
			uri = $trackURI[sa]
			system "mpc add #{uri}" 

		 else
                        print("Diagnostic Message:".yellow + "Non-command message was sent in the channel. Ignoring.\n")
                 
		 end
        end
end


puts "\e[H\e[2J"
print "music_bot revision #{VERSION} is now properly loaded. Press enter to force shutdown.\n".green;
gets
cli.disconnect
