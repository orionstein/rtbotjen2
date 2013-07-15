require 'cinch'

module Cinch
  module Plugins
    class Lunch
	    include Cinch::Plugin

	    match /lunch/i,	method: :lunchtime

	    def initialize(*args)
        	super
        	places = ["TJ's","Bangkok Joe's","Tackle Box","Café Cantina","Farmers Fishers Bakers","Moby Dick","Johnny Rockets","Tbsp","Muncheez Mania","Old Glory","Chipotle","Shophouse","Café Tu-o-Tu","Georgetown Dinette","Cheap Chinese Place"]
	    end

	    def lunchtime()
	    	index = 1 + rand(places.length)
		    m.reply places[index]
	    end
    end
  end
end


