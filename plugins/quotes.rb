require 'cinch'
require 'jimson'


module Cinch
  module Plugins
    class Quotes
      include Cinch::Plugin

      match /addquote (.+)/i, method: :addquote
      match /quote (.+)/i, method: :quote
      match "quote", method: :randquote
      
      

      def initialize(*args)
        super

        
      end

      def addquote(m, quote)
        
	user = $client.addquote(m.user.nick,quote)
        # send reply that quote was added
        m.reply "#{m.user.nick}: Quote successfully added as ##{user + 1}."
      end

      def quote(m,quote)
	 response = $client.quote(quote)
	 m.reply "#{m.user.nick}: #{response}"
      end

      def randquote(m)
	 response = $client.randquote()
	 m.reply "#{m.user.nick}: #{response}"
      end


      
     

      #--------------------------------------------------------------------------------
      # Protected
      #--------------------------------------------------------------------------------
      
      

    end
  end
end

