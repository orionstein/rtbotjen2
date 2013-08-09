require 'cinch'
require 'date'

module Cinch
  module Plugins
    class Lunch
	    include Cinch::Plugin

	    match /lunch/i,	method: :lunchtime

	    def initialize(*args)
        	super
        	places = [
        		"TJ's",
        		"Bangkok Joe's",
        		"Tackle Box",
        		"Cafe Cantina",
        		"Farmers Fishers Bakers",
        		"Moby Dick",
        		"Johnny Rockets",
        		"Tbsp",
        		"Muncheez Mania",
        		"Old Glory",
        		"Chipotle",
        		"Shophouse",
        		"Cafe Tu-o-Tu",
        		"Georgetown Dinette",
        		"Cheap Chinese Place",
        		"Snap",
        		"Good Stuff Eatery"
        	]
	    end

	    def lunchtime(m)
		    m.reply getPlace
	    end

	    def getPlace()
	    	today = Date.today
	    	place = places.sample
	    	if place == 'Tackle Box' then
	    		if today.strftime('%A') == 'Wednesday' then
	    			return place
	    		else
	    			return getPlace
	    		end
	    	else
	    		return place
	    	end
	    end

    end
  end
end


