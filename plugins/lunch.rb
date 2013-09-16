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
                "Bangkok Joe's",
                "Basil Thai",
                "Booeymonger",
                "Cafe Cantina",
                "Cafe Tu-o-Tu",
                "Cheap Chinese Place",
                "Chipotle",
                "Farmers Fishers Bakers",
                "Five Guys",
                "George's King of Falafel",
                "Georgetown Dinette",
                "Good Stuff Eatery"
                "Johnny Rockets",
                "Little Viet Garden",
                "Moby Dick",
                "Old Glory",
                "Quick Pita"
                "Shophouse",
                "Smelly Deli",
                "Snap",
                "Tackle Box",
                "Tbsp",
                "Thunder Burger",
                "TJ's",
                "Wingo's",
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


