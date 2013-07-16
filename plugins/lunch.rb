require 'cinch'

module Cinch
  module Plugins
    class Lunch
	    include Cinch::Plugin

	    match /lunch/i,	method: :lunchtime

	    def initialize(*args)
        	super
        	places = ["TJ's","Bangkok Joe's","Tackle Box","Cafe Cantina","Farmers Fishers Bakers","Moby Dick","Johnny Rockets","Tbsp","Muncheez Mania","Old Glory","Chipotle","Shophouse","Cafe Tu-o-Tu","Georgetown Dinette","Cheap Chinese Place"]
	    end

	    def lunchtime(m)
		    m.reply places.sample
	    end
    end
  end
end


