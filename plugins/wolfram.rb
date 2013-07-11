require 'cinch'
require 'wolfram'


module Cinch
  module Plugins
    class WolframC
	    include Cinch::Plugin

	    match /wolfram:(.*)/i,	method: :wolframc
	    match /wolfram (.*)/i,	method: :wolframc

	    def initialize(*args)
        	super

       		Wolfram.appid = ENV['WOLFRAM_API']
	    end

	    def wolframc(m,wolfy)
		    query = wolfy
		    result = Wolfram.fetch(query)
	       
		    # to see the result as a hash of pods and assumptions:
		
		    hash = Wolfram::HashPresenter.new(result).to_hash
		    m.reply hash
	    end
    end
  end
end


