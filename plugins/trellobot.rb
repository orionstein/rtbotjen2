require 'cinch'
require 'trello'
require 'json'
require 'resolv'



module Cinch
  module Plugins
    class TrelloBot
	    include Trello
	    include Trello::Authorization
	    include Cinch::Plugin 

	    match /trello:(.*)/i,	method: :trellopull
	    match /trello (.*)/i,	method: :trellopull
	    

	    def given_short_id_return_long_id(short_id)
		  long_ids = $board.cards.collect { |c| c.id if c.url.match(/\/(\d+)$/)[1] == short_id.to_s}
		  long_ids.delete_if {|e| e.nil?}
		end

		def get_list_by_name(name)
		  $board.lists.find_all {|l| l.name.casecmp(name.to_s) == 0}
		end

		def sync_board
		  return $board.refresh! if $board
		  $board = Trello::Board.find(ENV['TRELLO_BOARD_ID'])
		  $add_cards_list = $board.lists.detect { |l| l.name.casecmp(ENV['TRELLO_ADD_CARDS_LIST']) == 0 }
		end

		def say_help(msg)
		  msg.reply "I can tell you the open cards on the lists on your Trello board. Just address me with the name of the list (it's not case sensitive)."
		  msg.reply "For example - trellobot: ideas"
		  msg.reply "I also understand the these commands : "
		  msg.reply "  -> 1. help - shows this!"
		  msg.reply "  -> 2. sync - resyncs my cache with the board."
		  msg.reply "  -> 3. lists - show me all the board list names"
		  msg.reply "  -> 4. card add this is a card - creates a new card named: \'this is a card\' in a list defined in the TRELLO_ADD_CARDS_LIST env variable or if it\'s not present in a list named To Do"
		  msg.reply "  -> 5. card <id> comment this is a comment on card <id> - creates a comment on the card with short id equal to <id>"
		  msg.reply "  -> 6. card <id> move to Doing - moves the card with short id equal to <id> to the list Doing"
		  msg.reply "  -> 7. card <id> add member joe - assign joe to the card with short id equal to <id>."
		  msg.reply "  -> 8. cards joe - return all cards assigned to joe"
		end

	    def initialize(*args)
        	super
		
		$board = nil
		$add_cards_list = nil
       		Trello::Authorization.const_set :AuthPolicy, OAuthPolicy
		OAuthPolicy.consumer_credential = OAuthCredential.new ENV['TRELLO_API_KEY'], ENV['TRELLO_API_SECRET']
		OAuthPolicy.token = OAuthCredential.new ENV['TRELLO_API_ACCESS_TOKEN_KEY'], nil

	    end

	    def trellopull(m,message)
		   
		    sync_board unless $board
		    unless $board
		      m.reply "I can't seem to get the list of ideas from Trello, sorry. Try here: https://trello.com/board/#{ENV['TRELLO_BOARD_ID']}"
		      #bot.halt
		    end

		    # trellobot: what up?  <- The bit we are interested in is past the ':'
		    parts = message
		    searchfor = parts.strip.downcase

		    case message
		    when /debug/
		      debugger
		    when /^card add/
		      if $add_cards_list.nil?
			m.reply "Can't add card. It wasn't found any list named: #{ENV['TRELLO_ADD_CARDS_LIST']}."
		      else
			m.reply "Creating card ... "
			name = searchfor.strip.match(/^card add (.+)$/)[1]
			card = Trello::Card.create(:name => name, :list_id => $add_cards_list.id)
			m.reply "Created card #{card.name} with id: #{card.short_id}."
		      end
		    when /^card \d+ comment/
		      m.reply "Commenting on card ... "
		      card_regex = searchfor.match(/^card (\d+) comment (.+)/)
		      card_id = given_short_id_return_long_id(card_regex[1])
		      if card_id.count == 0
			m.reply "Couldn't be found any card with id: #{card_regex[1]}. Aborting"
		      elsif card_id.count > 1
			m.reply "There are #{list.count} cards with id: #{regex[1]}. Don't know what to do. Aborting"
		      else
			comment = card_regex[2]
			card = Trello::Card.find(card_id[0].to_s)
			card.add_comment comment
			m.reply "Added \"#{comment}\" comment to \"#{card.name}\" card"
		      end
		    when /^card \d+ move to \w+/
		      m.reply "Moving card ... "
		      regex = searchfor.match(/^card (\d+) move to (\w+)/)
		      list = get_list_by_name(regex[2].to_s)
		      card_id = given_short_id_return_long_id(regex[1].to_s)
		      if card_id.count == 0
			m.reply "Couldn't be found any card with id: #{regex[1]}. Aborting"
		      elsif card_id.count > 1
			m.reply "There are #{list.count} cards with id: #{regex[1]}. Don't know what to do. Aborting"
		      else
			if list.count == 0
			  m.reply "Couldn't be found any list named: \"#{regex[2].to_s}\". Aborting"
			elsif list.count > 1
			  m.reply "There are #{list.count} lists named: #{regex[2].to_s}. Don't know what to do. Aborting"
			else
			  card = Trello::Card.find(card_id[0])
			  list = list[0]
			  if card.list.name.casecmp(list.name) == 0
			    m.reply "Card \"#{card.name}\" is already on list \"#{list.name}\"."
			  else
			    card.move_to_list list
			    m.reply "Moved card \"#{card.name}\" to list \"#{list.name}\"."
			  end
			end
		      end
		    when /^card \d+ add member \w+/
		      m.reply "Adding member to card ... "
		      regex = searchfor.match(/^card (\d+) add member (\w+)/)
		      card_id = given_short_id_return_long_id(regex[1].to_s)
		      if card_id.count == 0
			m.reply "Couldn't be found any card with id: #{regex[1]}. Aborting"
		      elsif card_id.count > 1
			m.reply "There are #{list.count} cards with id: #{regex[1]}. Don't know what to do. Aborting"
		      else
			card = Trello::Card.find(card_id[0])
			membs = card.members.collect {|m| m.username}
			begin
			  member = Trello::Member.find(regex[2])
			rescue
			  member = nil
			end
			if member.nil?
			  m.reply "User \"#{regex[2]}\" doesn't exist in Trello."
			elsif membs.include? regex[2]
			  m.reply "#{member.full_name} is already assigned to card \"#{card.name}\"."
			else
			  card.add_member(member)
			  m.reply "Added \"#{member.full_name}\" to card \"#{card.name}\"."
			end
		      end
		    when /^cards \w+/
		      username = searchfor.match(/^cards (\w+)/)[1]
		      cards = []
		      $board.cards.each do |card|
			members = card.members.collect { |mem| mem.username }
			if members.include? username
			  cards << card
			end
		      end
		      inx = 1
		      if cards.count == 0
			m.reply "User \"#{username}\" has no cards assigned."
		      end
		      cards.each do |c|
			m.reply "  ->  #{inx.to_s}. #{c.name} (id: #{c.short_id}) from list: #{c.list.name}"
			inx += 1
		      end
		    when /lists/
		      $board.lists.each { |l|
			m.reply "  ->  #{l.name}"
		      }
		    when /help/
		      say_help(m)
		    when /\?/
		      say_help(m)
		    when /sync/
		      sync_board
		      m.reply "Ok, synced the board, #{m.user.nick}."
		    else
		      if searchfor.length > 0
			# trellobot presumes you know what you are doing and will attempt
			# to retrieve cards using the text you put in the message to him
			# at least the comparison is not case sensitive
			list = $board.lists.detect { |l| l.name.casecmp(searchfor) == 0 }
			if list.nil?
			  m.reply "There's no list called <#{searchfor}> on the board, #{m.user.nick}. Sorry."
			else
			  cards = list.cards
			  if cards.count == 0
			    m.reply "Nothing doing on that list today, #{m.user.nick}."
			  else
			    ess = (cards.count == 1) ? "" : "s"
			    m.reply "I have #{cards.count} card#{ess} today in list #{list.name}"
			    inx = 1
			    cards.each do |c|
			      membs = c.members.collect {|m| m.full_name }
			      if membs.count == 0
				m.reply "  ->  #{inx.to_s}. #{c.name} (id: #{c.short_id})"
			      else
				m.reply "  ->  #{inx.to_s}. #{c.name} (id: #{c.short_id}) (members: #{membs.to_s.gsub!("[","").gsub!("]","").gsub!("\"","")})"; inx += 1
			      end
			      inx += 1
			    end
			  end
			end
		      else
			say_help(m)
		      end
		    end
	    end
    end
  end
end



