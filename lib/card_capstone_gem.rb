require "card_capstone_gem/version"
require 'unirest'
require 'twilio-ruby'
# require 'rubygems'

module CardCapstoneGem


module CardsController

    def cards_index_action
        response = Unirest.get('http://localhost:3000/cards')
        cards = response.body

        cards_index_view(cards)
    end


    def cards_show_action
        print "Enter the ID of the card to see: "
        input_id = gets.chomp

        if input_id != ""
            response = Unirest.get("http://localhost:3000/cards/#{input_id}")
            card = response.body
            card_show_view(card)

            print "Press 'c' to show the comments on this card, 'p' to see its prices, or press 'enter' to continue: "
            com_choice = gets.chomp

            if com_choice == 'c'
                comments_show_action(input_id)
            elsif com_choice == 'p'
                prices_index_action(input_id)
            end
        end
    end

    def card_create_action
        puts "Enter the following information to create a new card"

        client_params = {}

        print "Name: "
        client_params[:name] = gets.chomp

        if client_params[:name] != ""

            print "Description: "
            client_params[:description] = gets.chomp

            print "Attribute: "
            client_params[:element] = gets.chomp

            print "Card Type: "
            client_params[:race] = gets.chomp

            print "Rarity: "
            client_params[:rarity] = gets.chomp

            response = Unirest.get(
                                    "http://localhost:3000/cards",
                                    parameters: client_params
                                    )

            card = response.body

            user_card_create_action(card)
        end
    end

    def card_update_action(input_id)
        client_params = {}

        response = Unirest.get("http://localhost:3000/cards/#{input_id}")
        card_json = response.body


        print "Name (#{card_json["name"]}): "
        client_params[:name] = gets.chomp

        print "Description (#{card_json["description"]}): "
        client_params[:description] = gets.chomp

        print "Attribute (#{card_json["element"]}): "
        client_params[:element] = gets.chomp

        print "Card Type (#{card_json["race"]}): "
        client_params[:race] = gets.chomp

        print "Rarity (#{card_json["rarity"]}): "
        client_params[:rarity] = gets.chomp

        client_params.delete_if { |key, value| value.empty?}

        update_response = Unirest.patch(
                                        "http://localhost:3000/cards/#{input_id}",
                                         parameters: client_params
                                        )

        card = update_response.body

        card_show_view(card)
    end

    def card_destroy_action
        print "What is the ID the card you want to remove: "
        input_id = gets.chomp
        response = Unirest.delete("http://localhost:3000/cards/#{input_id}")

        json_data = response.body
        puts json_data["message"]
    end

    def cards_search_action
        print "Enter the name to search for: "
        search_term = gets.chomp

        if search_term != ""
            response = Unirest.get("http://localhost:3000/cards/?search=#{search_term}")
            cards = response.body     

            # p cards        
            cards_index_view(cards)
        else
            puts "Sorry, but there were no results for that."
        end
    end

    def cards_sort_action(sort)
        card_hashs = get_request("/cards?sort=#{sort}")
        cards = Card.convert_hashs(card_hashs)

        cards_search_view(cards)
    end
end
    

    # def cards_community_action
    #     respone = Unirest.get("http://localhost:3000/cards")
    #     cards = response.body
        
    #     cards_community_view(cards)
    # end
module CommentsController
  def comments_index_action
    response = Unirest.get("http://localhost:3000/comments")
    comments = response.body

    comments_index_view(comments)
    
  end

  def comment_create_action
    client_params = {}
    print "Enter the ID of the card to comment on: "
    input_id = gets.chomp 
    client_params[:commentable_id] = input_id

    puts "Comment: "
    client_params[:text] = gets.chomp

    response = post_request(
                            "/comments",
                            parameters: client_params
                            )
    comment = response.body

    comment_show_view(comment)
  end

  def comments_show_action(card_id)
      response = Unirest.get("http://localhost:3000/comments/?search=#{card_id}")
      comments = response.body
      # p comments
      comments_index_view(comments)
  end
end
module DecksController
  def decks_index_action
    response = Unirest.get('http://localhost:3000/decks')
    decks = response.body
    # p decks 
    decks_index_view(decks)
    print "Would which deck would you like to look at: "
    deck_id = gets.chomp
    if deck_id != ""
      deck_show_action(deck_id)
    end
  end

  def deck_show_action(deck_id)
    response = Unirest.get("http://localhost:3000/decks/#{deck_id}")
    deck = response.body
    # p deck
    deck_cards_view(deck)
  end

  def deck_add_card_action
    response = Unirest.get('http://localhost:3000/decks')
    decks = response.body
    # p decks 
    decks_index_view(decks)
    print "Enter the ID of the deck you'd like to add to: "
    deck_id = gets.chomp

    if deck_id != ""
      deck_show_action(deck_id)
      print "Is this the deck you'd like to add too? ('y' or 'n'): "
      input_option = gets.chomp

      if input_option == 'y'
        deck_card_create_action(deck_id)
      end
    end
  end

  def deck_delete_card_action
    response = Unirest.get('http://localhost:3000/decks')
    decks = response.body
    # p decks 
    decks_index_view(decks)
    print "Enter the ID of the deck you'd like to delete a card from: "
    deck_id = gets.chomp

    if deck_id != ""
      deck_show_action(deck_id)
      print "Enter the ID of the card you would like to remove: "
      card_id = gets.chomp

      if card_id != ""
        deck_card_delete_action(card_id)
      end
    end
  end

  def deck_create_action
    client_params = {}

    print "What is the name of your deck: "
    client_params[:name] = gets.chomp
    if client_params[:name] != ""
      print "Enter a description of what will be in the deck: "
      client_params[:info] = gets.chomp

      response = Unirest.post(
                              'http://localhost:3000/decks',
                              parameters: client_params
                              )
      deck = response.body
      # p deck

      deck_show_view(deck)
    end
  end

end

module DeckCardsController
  def deck_card_create_action(deck_id)
    # p deck_id
    client_params = {}
    client_params[:deck_id] = deck_id

    response = Unirest.get("http://localhost:3000/user_cards")
    cards = response.body
    user_cards_index_view(cards)
    print "Which card would you like to add to this deck? "
    client_params[:card_id] = gets.chomp

    response = Unirest.post(
                            'http://localhost:3000/deck_cards',
                            parameters: client_params
                            )
    deck_card = response.body
    p deck_card
    deck_card_create_view(card)
  end

  def deck_card_delete_action(card_id)
    p card_id

    response = Unirest.delete("http://localhost:3000/deck_cards/#{card_id}")
    data = response.body
    puts data["message"]

  end
end

module UsersController
  def user_create_action
    puts "Signup!"
    puts
    client_params = {}

    print "Name: "
    client_params[:name] = gets.chomp
    
    print "Email: "
    client_params[:email] = gets.chomp
    
    print "Password: "
    client_params[:password] = gets.chomp
    
    print "Password confirmation: "
    client_params[:password_confirmation] = gets.chomp
    
    response = Unirest.post("http://localhost:3000/users", parameters: client_params)
    puts JSON.pretty_generate(response.body)
  end

  def user_update_action
      client_params = {}
      response = Unirest.get("http://localhost:3000/users/1")
      user = response.body
      input_id = user["id"]
      p user

      print "Name (#{user["name"]}): "
      client_params[:name] = gets.chomp

      print "Email (#{user["email"]}): "
      client_params[:email] = gets.chomp
      
      print "Password (#{user["password"]}): "
      client_params[:password] = gets.chomp
      
      print "Password confirmation (#{user["password_confirmation"]}): "
      client_params[:password_confirmation] = gets.chomp

      client_params.delete_if { |key, value| value.empty?}

      update_response = Unirest.patch(
                                        "http//localhost:3000/users/#{input_id}",
                                        parameters: client_params
                                        )
      user = update_response.body
  end
end

module PricesController
  def prices_index_action(input_id)
    response = Unirest.get("http://localhost:3000/prices?search=#{input_id}")
    prices = response.body
    prices_index_view(prices)
  end

  def price_create_action
    print "Enter the ID of the card to leave a price on: "

    client_params = {}
    input_id = gets.chomp
    client_params[:card_id] = input_id

    response = Unirest.get("http://localhost:3000/cards/#{input_id}")
    card = response.body
    card_show_view(card)

    print "How much do you think the card costs? "
    client_params[:value] = gets.chomp

    print "What condition does the card appear to be in? "
    client_params[:condition] = gets.chomp

    print "What source is your information from? "
    client_params[:source] = gets.chomp

    print "How rare do you believe this card actually is? "
    client_params[:style] = gets.chomp

    response = Unirest.post(
                            "http://localhost:3000/prices",
                            parameters: client_params
                            )
    price = response.body
    price_show_view(price)

  end

  def price_average_action
    print "Enter the ID of the card who's average price you want to see: "
    input_id = gets.chomp

    response = Unirest.get("http://localhost:3000/cards/#{input_id}")
    card = response.body

    market_response = Unirest.get('http://yugiohprices.com/api/price_for_print_tag/' + card['user_card']["print_tag"])
    market_average = market_response.body["data"]['price_data']['price_data']['data']['prices']['average']
    # p card⁄
    average = card["average_price"]
    # p average
    
    price_average_view(average, market_average)
  end

end

module UserCardsController

  def user_cards_index_action
    response = Unirest.get("http://localhost:3000/user_cards")
    cards = response.body

    # p cards
    user_cards_index_view(cards)

    print "Would you like to add another card [1], remove a card [2], view one of your cards [3],  or continue [enter]: "
    cards_choice = gets.chomp

    user_cards_decision(cards_choice)
  end


  def user_cards_decision(cards_choice)
    if cards_choice == '1'
      card_create_action
    elsif cards_choice == '2'
      user_card_destroy_action
    elsif cards_choice == '3'
      user_card_show_action
    end
  end

  def user_card_show_action
    print "Enter the ID of your card: "
    input_id = gets.chomp
    response = Unirest.get("http://localhost:3000/user_cards/#{input_id}")
    user_card = response.body
    # p user_card

    user_card_show_view(user_card)
  end

  def user_card_create_action(card)
    client_params = {}
    puts "What condition is it in? "
    client_params[:condition] = gets.chomp

    puts "What is the Print Tag? "
    client_params[:print_tag] = gets.chomp
    client_params[:card_id] = card["id"]

    response = Unirest.post(
                            "http://localhost:3000/user_cards",
                            parameters: client_params
                            )
    user_card = response.body
    # p user_card
    user_cards_create_view(user_card)
  end

  def user_card_update_action
    response = Unirest.get("http://localhost:3000/user_cards")
    cards = response.body
    
    user_cards_simple_view(cards)
    
    print "Which card would you like to get edit (ID:)? "
    input_id = gets.chomp
    
    if input_id != ""
      card_update_action(input_id)
    end
  end

  def user_card_destroy_action
    response = Unirest.get("http://localhost:3000/user_cards")
    cards = response.body
    
    user_cards_simple_view(cards)

    print "Which card would you like to get rid of (ID:)? "
    input_id = gets.chomp

    if input_id != ""
    response_first = Unirest.delete("http://localhost:3000/cards/#{input_id}")
    response = Unirest.delete("http://localhost:3000/user_cards/#{input_id}")

    json_data = response.body
    puts json_data["message"]
    end
  end

end

module YuGiOhController

  # def yugioh_name_price_search
  #   print "What is the name of your card? (Be careful for spelling and punctuation): "
  #   card_name = "Blue-Eyes White Dragon" 
  #   response = Unirest.get("http://yugiohprices.com/api/get_card_prices/" + card_name)
    
  #   p response
  # end

  def yugioh_card_details_search
    print "Enter the name of the card you are searching for: "
    card_name = gets.chomp
    response = Unirest.get("http://yugiohprices.com/api/card_data/" + card_name)
    response_status = response.body["status"]
    card = response.body['data']

    if response_status != "fail"
      puts '='* 50
      puts "Name: #{card["name"]}"
      puts '-' * 30
      puts "Description: #{card["text"]}"
      puts "Attribute: #{card["type"]}"
      puts "Element: #{card["family"]}"
      puts
    else
      puts "'#{card_name}' was not found, please check your spelling"
    end
  end
    
end

module CardsViews

  def cards_index_view(cards)
    cards.each do |card|
      card_show_view(card)
    end
  end

  def card_show_view(card)
    # p card
    puts
    puts "Card Name: #{card["name"]} (ID: #{card["id"]})"
    puts "Owner: #{card["user"]["name"]}"
    puts "-" * 80
    puts "Card Description: #{card["description"]}"
    puts "Card Element: #{card["element"]}"
    puts "Card Attribute: #{card["race"]}"
    puts "Card Rarity: #{card["rarity"]}"
    puts "Card Condition: #{card["user_card"]["condition"]}"
    puts "Print Tag: #{card["user_card"]["print_tag"]}"
    puts
  end

  def cards_search_view(cards)
    cards.each do |card|
      # p card
      puts 
      puts "Card Name: #{card.name} (ID: #{card.id})"
      puts "-" * 80
      puts "Card Description: #{card.description}"
      puts "Card Element: #{card.element}"
      puts "Card Attribute: #{card.race}"
      puts "Card Rarity: #{card.rarity}"
    end
  end
end

module CommentsViews
  def comment_show_view(comment)
    # p comment
    puts
    puts "=" * 50
    puts "Comment From: #{comment["user"]["name"]}"
    puts "On Card: #{comment["card_id"]}"
    puts "At: #{comment["created_at"]}"
    puts "-" * 50
    puts "#{comment["text"]}"
    puts
  end

  def comments_index_view(comments)
    comments.each do |comment|
      # p comment
      comment_show_view(comment)
     # puts "=" * 50
     # puts "Your [#{comment["id"]}] comment"
     # puts "Card ID: #{comment["commentable_id"]}"
     # puts "#{comment["text"]}"
     # puts
    end
  end
end

module PricesViews 
  def price_show_view(price)
    puts
    puts "=" * 50
    puts "The card is in #{price["condition"]} condition"
    puts "And its rarity is '#{price["style"]}'"
    puts "Total Worth: #{price["value"]}"
  end

  def prices_index_view(prices)
    if prices != []
      # p 'prices is running'
      prices.each do |price|
        price_show_view(price)
      end
    else
      puts
      puts "There are no prices listed yet for this card" 
    end
  end

  def price_average_view(average, market_average)
    puts 
    puts "The average price of this card is $#{average}"
    puts "The Market Average of this card id $#{market_average}"    
  end
end

module UserCardsViews
  def user_cards_index_view(cards)
    puts "Users Cards"
    puts "=" * 50
    cards.each do |card|
      p card
      puts "#{card["card"]["id"]}"
      puts "Card Name: #{card["card"]["name"]}"
      puts "-" * 80
      puts "Card Description: #{card["card"]["description"]}"
      puts "Card Element: #{card["card"]["element"]}"
      puts "Card Race: #{card["card"]["race"]}"
      puts "Card Rarity: #{card["card"]["rarity"]}"
      puts "Card Condition: #{card["card"]["user_card"]["condition"]}"
      puts "Print Tag: #{card["card"]["user_card"]["print_tag"]}"
      puts
    end
  end

  def user_card_show_view(card)
    # p card
    puts
    puts "=" * 50
    puts "Card Name: #{card["card"]["name"]}"
    puts "-" * 50
    puts "Card Description: #{card["card"]["description"]}"
    puts "Card Element: #{card["card"]["element"]}"
    puts "Card Attribute: #{card["card"]["race"]}"
    puts "Card Rarity: #{card["card"]["rarity"]}"
    puts "Card Condition: #{card["card"]["user_card"]["condition"]}"
    puts "Print Tag: #{card["card"]["user_card"]["print_tag"]}"
  end

  def user_cards_create_view(user_card)
    p user_card
    puts
    puts "=" * 50
    puts "Card Owner: #{user_card["user_name"]}"
    puts
    puts "Card Name: #{user_card["card_name"]}"
    puts "-" * 50
    puts "Card Description: #{user_card["card_description"]}"
    puts "Card Element: #{user_card["element"]}"
    puts "Card Attribute: #{user_card["race"]}"
    puts "Card Rarity: #{user_card["rarity"]}"
    puts "Card Condition: #{user_card["condition"]}"
    puts "Print Tag: #{user_card["print_tag"]}"
  end

  def user_cards_simple_view(cards)
     puts "    Your Cards:"
    cards.each do |card|
      # p card
      puts "=" * 50
      puts "Card ID: #{card["card"]["id"]}"
      puts "Card Name: #{card["card"]["name"]}"
      puts
    end
  end

end

module DecksViews
  def deck_show_view(deck)
    # p deck
    puts
    puts '=' * 50
    puts "Deck Id: #{deck["id"]}"
    puts "Deck Name: #{deck["name"]}"
    puts "Deck Price: #{deck["price"]}"
    puts "Info: #{deck["info"]}"
  end

  def deck_cards_view(deck)
    deck_show_view(deck)
    puts "Contains: "
    index = 0
    deck["cards"].each do |card|
      # p card
      puts "-" * 20
      puts "#{card["name"]}:  ID of #{deck["deck_cards"][index]["id"]}"
      index += 1
    end
  end

  def decks_index_view(decks)
    decks.each do |deck|
      deck_show_view(deck)
    end
  end
end

module DeckCardsViews
  def deck_card_create_view(card)
    puts 
    puts "You added #{card["card"]["name"]} to the deck list."
  end
end

module YuGiOhViews

end

class Card
  attr_accessor :id, :name, :description, :element, :race, :rarity
  def initialize(input_options)
    @id = input_options["id"]
    @name = input_options["name"]
    @description = input_options["description"]
    @element = input_options["element"]
    @race = input_options["race"]
    @rarity = input_options["rarity"]
  end





  def self.convert_hashs(card_hashs)
    collection = [ ]

    card_hashs.each do |card_hash|
      collection << Card.new(card_hash)
    end 
    collection
  end
end

class Frontend

  include CardsController
  include CommentsController
  include UsersController
  include PricesController
  include UserCardsController
  include DecksController
  include DeckCardsController
  include YuGiOhController
  
  include CardsViews
  include CommentsViews
  include PricesViews
  include UserCardsViews
  include DecksViews
  include DeckCardsViews
  include YuGiOhViews

  def run
    while true
      

      system 'clear'
      puts "Welcome to My Card Capstone"
      puts "=" * 80
      puts

      puts "Enter [signup] to create a new user account"
      puts "Enter [login] to login to your account"
      # puts "      Enter [user] to update user information"
      puts "Enter [logout] to logout of your account"
      puts
      puts "Enter [remove] to remove your account"
      puts "-" * 50
      puts
      puts "Enter [cards] to display your cards"
      puts
      puts "Press [1] to show all cards"
      puts "    Press [1.1] to search by name"
      puts "    Press [1.2] to sort by Element"
      puts "    Press [1.3] to sort by Type"
      puts "    Press [1.4] to sort by Alphabetical Name Order"
      puts "Press [2] to show a specific card"
      puts "----Press [2.1] to leave a price on a card"
      puts "------Press [2.11] to see average card cost"
      puts "----Press [2.2] to leave a comment on a card"
      puts "Press [3] to create a new card"
      puts "Press [4] to update a card"
      puts "Press [5] to delete one of your cards"
      puts "-" * 50
      puts  
      puts 'Press [d] to create a new deck'
      puts 'Press [ds] to show all your decks'
      puts 'Press [dc] to add a card to a deck'
      puts 'Press [dd] to remove a card from a deck'
      puts 
      puts 'Press [yuname] to get price info by card name'
      puts 'Press [cs] to search for card details by name'
      puts
      puts "Enter [comments] to display all comments"
      puts
      puts "Press [q] to quit"
      user_choice = gets.chomp


      if user_choice == "1"
        cards_index_action

      elsif user_choice == "1.1"
        cards_search_action

      elsif user_choice == "1.2"
        cards_sort_action("element")

      elsif user_choice == "1.3"
        cards_sort_action("race")

      elsif user_choice == "1.4"
        cards_sort_action("name")
        

      elsif user_choice == "2"
        cards_show_action

      elsif user_choice == "2.1"
        price_create_action

      elsif user_choice == "2.11"
        price_average_action
          
      elsif user_choice == "2.2"
        comment_create_action
        
      elsif user_choice == "3"
        card_create_action

      elsif user_choice == "4"
        # card_update_action
        user_card_update_action

      elsif user_choice == "5"
        user_card_destroy_action

      elsif user_choice == "cards"



        user_cards_index_action

      elsif user_choice == "d"
        deck_create_action

      elsif user_choice == "ds"
        decks_index_action  

      elsif user_choice == "dc"
        deck_add_card_action

      elsif user_choice == "dd"
        deck_delete_card_action




      elsif user_choice == "yuname"
        yugioh_name_price_search

      elsif user_choice == "cs"
        yugioh_card_details_search



      elsif user_choice == "comments"
        comments_index_action





      elsif user_choice == "signup"
        user_create_action

      elsif user_choice == "login"
        puts "Login"
        puts 
        print "Email: "
        input_email = gets.chomp

        print "Password: "
        input_password = gets.chomp

        response = Unirest.post(
                                "http://localhost:3000/user_token",
                                parameters: { 
                                              auth: {
                                                      email: input_email,
                                                      password: input_password
                                                      }
                                              }
                                )
        jwt = response.body["jwt"]
        Unirest.default_header("Authorization", "Bearer #{jwt}")

      # elsif user_choice == "user"
      #     user_update_action

      elsif user_choice == "logout"
        jwt = ""
        Unirest.clear_default_headers

      elsif user_choice == "remove"
        print "What is your user id? "
        user_id = gets.chomp
        response = Unirest.delete("http://localhost:3000/users/#{user_id}")

        p response.body["message"]


      elsif user_choice == "q"
        puts "Thank you for using my Card App!!!"
        jwt = ""
        Unirest.clear_default_headers
        exit
      end
    user_choice = gets.chomp
    end
  end


# i'll use this for when im too lazy to actually lype out the URLs. We'll see if i transfer over. Just in case though.
private
    def get_request(url, client_params={})
      Unirest.get("http://localhost:3000#{url}", parameters: client_params).body
    end

    def post_request(url, client_params={})
      Unirest.post("http://localhost:3000#{url}", parameters: client_params).body
    end

    def patch_request(url, client_params={})
      Unirest.patch("http://localhost:3000#{url}", parameters: client_params).body
    end

    def delete_request(url, client_params={})
      Unirest.delete("http://localhost:3000#{url}", parameters: client_params).body
    end
end

end
