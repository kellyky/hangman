# frozen_string_literal: false

require 'rainbow'
require 'yaml'
require 'pry-byebug'

# A text-based game of hangman
class Hangman
  attr_reader :wrong_guesses_remaining

  def self.play
    print_intro
    return new_game_standard_mode unless saved_games_exist?

    print "\n\u{1F913} You have saved games \u{1F913}. "
    print Rainbow('Press ENTER/RETURN for a NEW game').greenyellow
    print ' or '
    print Rainbow("choose from the following:\n\n").mediumturquoise
    saved_game
  end

  def self.print_intro
    puts "\n\n"
    puts Rainbow(" <<>> Welcome to Hangman! <<>>\n").royalblue.bright.center(80)
    puts 'Your goal is to guess the word, one letter at a time:'
    puts "#{Rainbow(' - To win,').teal.bright} guess the word before you run out of guesses\n"

    puts " - If you guess incorrectly #{Rainbow('5').crimson} times, you #{Rainbow('you lose').crimson.bright}"

    print Rainbow("\n\nA tip before we start: You can save your game.").mediumvioletred.italic
    print Rainbow(" To do so, simply type 'save' when prompted for a letter.\n\n").mediumvioletred.italic
  end

  def self.saved_games_exist?
    Dir.children('saved').any?
  end

  def self.new_game_kids_mode
    print Rainbow("\nGreat! A new word for a new game in kids mode.").greenyellow
    word = wordlist_kids.shuffle.pop
    new(word).play
  end

  def self.new_game_standard_mode
    print Rainbow("\nGreat! A new word for a new game.").greenyellow
    word = wordlist_standard.select { |el| el.length >= 5 && el.length <= 12 }.shuffle.pop
    new(word).play
  end

  def self.new_game
    new(word).play
  end

  def self.wordlist_standard
    File.read('google-10000-english-no-swears.txt').split
  end

  def self.wordlist_kids
    File.read('kids-words.txt').split
  end

  def self.saved_game
    files = self.files
    saved_games = self.saved_games(files)
    saved_games.each { |option, name| puts "  - [#{option}] #{name}" }

    user_response = self.user_response
    parse_input(user_response, saved_games)
  end

  def self.files
    Dir.children('saved')
  end

  def self.saved_games(files)
    files.each_with_object({}).with_index do |(file, games), i|
      games[(i + 1).to_s] = file.gsub('.txt', '')
    end
  end

  def self.user_response
    gets.chomp.strip
  end

  def self.secret_mode_key
    'sierra'
  end

  def self.parse_input(user_response, saved_games)
    return new_game_kids_mode if user_response == secret_mode_key
    return new_game_standard_mode if user_response.empty?

    if saved_games.keys.none?(user_response)
      puts "\n\nI don't have any games saved for '#{user_response}'.\n\n"
      puts "Please choose from the games shown - or press [ENTER/RETURN] to start a new game.\n\n"
      saved_game
    end

    saved_file = saved_games[user_response]
    resume_saved_game("saved/#{saved_file}.txt")
  end

  def self.resume_saved_game(file)
    data = YAML.load_file(file)
    game_recap(data)
    Hangman.new(data[:word], data).play
  end

  def self.game_recap(game_data)
    word_length = game_data[:word].length
    guessed_word = game_data[:guessed_word].chars.join(' ')
    guessed_letters = game_data[:letters_already_guessed].join(', ')
    wrong_guesses_left = game_data[:wrong_guesses_remaining]

    puts Rainbow("\n\nGreat! Picking up where you left off on your saved game:\n\n").mediumturquoise
    puts "  - You have #{Rainbow("#{wrong_guesses_left} wrong guesses").red} left."
    puts "  - Your word has #{Rainbow("#{word_length} letters").green}"
    puts "  - You've already guessed: #{Rainbow(guessed_letters).cyan}, "
    puts "  - Here's what you have: #{Rainbow(guessed_word).yellow}"
    puts "\n\n You've got this!\n\n"
  end

  def initialize(word, saved_game_data = {})
    @word = word
    @guesses_used = saved_game_data[:guessed_used] || 0
    @wrong_guesses_remaining = saved_game_data[:wrong_guesses_remaining] || 5
    @guessed_word = saved_game_data[:guessed_word] || ''.rjust(@word.length, '_')
    @letters_already_guessed = saved_game_data[:letters_already_guessed] || []
  end

  def play
    show_word_length if @guesses_used.zero?
    game_over if game_over?
    player_turn
    whole_word_guessed? ? announce_winner : play
  end

  def show_word_length
    print " Your word has #{@word.length} letters:   #{prettified_guessed_word}\n"
  end

  def game_over?
    @wrong_guesses_remaining.zero?
  end

  def player_turn
    letter = guess_letter
    letter_in_word?(letter) ? correct_guess(letter) : incorrect_guess(letter)
    @guesses_used += 1
    @letters_already_guessed << letter
  end

  def correct_guess(letter)
    update_guessed_word(letter)
    puts "\nWoohoo! #{Rainbow("'#{letter.upcase}'").green} is in the word: #{prettified_guessed_word}"
  end

  def incorrect_guess(letter)
    decrement_wrong_guesses
    print Rainbow("\n\nHm, no #{letter}'s. ").orange
    print "You have #{Rainbow(@wrong_guesses_remaining.to_s).red} wrong guesses left. "
    print "Try again\n\n"
  end

  def prettified_guessed_word
    Rainbow("#{@guessed_word.chars.join(' ')}\n\n\n").yellow
  end

  def guess_letter
    print Rainbow("\nPick a letter... ").hotpink
    display_already_guessed_letters unless @letters_already_guessed.empty?
    letter = answer.downcase.strip
    return save_game if save_game?(letter)

    valid_guess?(letter) ? letter : guess_letter
  end

  def display_already_guessed_letters
    print Rainbow(' | Letters already guessed: ').royalblue
    print Rainbow("#{guessed_letters}\n\n").cyan.bright
  end

  def save_game?(letter)
    letter == 'save'
  end

  def save_game
    puts "\n\nWhat would you like to call this game? For example, your name.\n"
    game_name = answer.downcase.strip

    file_name = game_name.empty? ? 'saved_game' : game_name

    File.open("saved/#{file_name}.txt", 'w') { |file| file.write(game_data_dump) }

    puts "\nGot it! Your game will be called #{file_name}. Let's call it a day for now!"
    exit
  end

  def game_data_dump
    YAML.dump({
                word: @word,
                guesses_used: @guesses_used,
                wrong_guesses_remaining: @wrong_guesses_remaining,
                guessed_word: @guessed_word,
                letters_already_guessed: @letters_already_guessed
              })
  end

  def valid_guess?(letter)
    return already_guessed_message(letter) if already_guessed?(letter)
    return non_letter_message(letter) unless letter?(letter)
    return too_many_characters_message(letter) if too_many_characters?(letter)

    true
  end

  def already_guessed?(letter)
    @letters_already_guessed.include?(letter)
  end

  def letter?(letter)
    letter.match?(/[a-z]/)
  end

  def too_many_characters?(letter)
    letter.length != 1
  end

  def guessed_letters
    @letters_already_guessed.sort.join(', ')
  end

  def already_guessed_message(letter)
    print "\nYou already guessed #{letter}. "
    print 'Try a new letter!'
  end

  def non_letter_message(letter)
    puts "\nOpe, #{letter} is not an option. You need to guess a letter.\n\n"
  end

  def too_many_characters_message(letter)
    puts "\nOops! that's #{letter.length} letters. You need to choose just one letter.\n\n"
  end

  def update_guessed_word(letter)
    @word.chars.each.with_index do |char, i|
      @guessed_word[i] = char if letter == char
    end
  end

  def decrement_wrong_guesses
    @wrong_guesses_remaining -= 1
  end

  def letter_in_word?(letter)
    @word.include?(letter)
  end

  def whole_word_guessed?
    @guessed_word == @word
  end

  def announce_winner
    puts Rainbow('You guessed it - great job!').green
    play_again? ? Hangman.play : exit_game
  end

  def game_over
    puts 'You ran out of turns. You lost this round. '
    print " The word was #{Rainbow(@word.to_s).purple}.\n\n"
    puts "Better luck next time!\n\n"
    play_again? ? Hangman.play : exit_game
  end

  def play_again?
    puts "\nWould you like to play again? Press '1' for yes and any other key to exit."
    answer == '1'
  end

  def answer
    gets.chomp
  end

  def exit_game
    puts "\nOk, let's call it a day. Have a good one!"
    exit
  end
end
