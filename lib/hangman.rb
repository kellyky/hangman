# frozen_string_literal: false

require 'rainbow'
require 'yaml'
require 'pry-byebug'

# A text-based game of hangman
class Hangman
  attr_reader :wrong_guesses_remaining

  def self.play
    self.print_intro
    if self.saved_games?
      print "\nYou have saved games. Choose a game to play:\n\n"
      self.saved_game_option
    else
      self.new_game
    end
  end

  def self.print_intro
    puts "\n====================== Welcome to hangman! ====================== \n\n"
    wrong_guesses_allowed = Rainbow("5").red
    puts "Here's how to play:\n\n"
    puts '  - The computer will choose a word. Your goal is to guess the word, one letter at a time.'
    puts '  - If you do guess all the letters in time, you win!'
    puts "  - If you guess incorrectly " + wrong_guesses_allowed + " times, you lose.\n\n"
    puts "\n======================  <<><><> <> <><><>>  ====================== \n\n"
  end

  def self.saved_game_option

    files = self.files
    saved_games = self.saved_games(files)
    saved_games.each { |option, name| puts "  - [#{option}] #{name}" }

    puts "  - or select [Return/Enter] key to start a new game\n\n"
    user_response = self.user_response
    self.parse_input(user_response, saved_games)
  end

  def self.user_response
    gets.chomp.strip
  end

  def self.files
    Dir.children('saved')
  end

  def self.saved_games(files)
    files.each_with_object({}).with_index do |(file, games), i|
      games[(i + 1).to_s] = file.gsub('.txt', '')
    end
  end

  def self.new_game
    word = self.wordlist.select { |word| word.length >= 5 && word.length <= 12 }.shuffle.pop
    new(word).play
  end

  def self.wordlist
    File.read('google-10000-english-no-swears.txt').split
  end

  def self.parse_input(user_response, saved_games)
    return self.new_game if user_response.empty?

    if saved_games.keys.none?(user_response)
      puts "\n\nI don't have any games saved for '#{user_response}'.\n\n"
      puts "Please choose from the games shown - or press [ENTER/RETURN] to start a new game.\n\n"
      self.saved_game_option
    end

    saved_file = saved_games[user_response]
    filename = File.join('saved/', saved_file + ".txt")
    self.resume_saved_game(filename)
  end

  def self.resume_saved_game(file)
    binding.pry
    data = YAML.load_file(file)

    game = Hangman.new(
      data[:word],
      data[:guesses_used],
      data[:guessed_word],
      data[:wrong_guesses_remaining],
      data[:letters_already_guessed]
    )

    self.game_recap(
      data[:word].length.to_s,
      data[:guessed_word].chars.join(' '),
      data[:letters_already_guessed].join(', '),
      data[:wrong_guesses_left]
    )
    game.play
  end

  def self.game_recap(word_length, guessed_word, guessed_letters, wrong_guesses_left)
    puts "\n\nGreat! Picking up where you left off:\n\n"
    puts "  - Your word has #{Rainbow("#{word_length} letters").green}"
    puts "  - Here are the letters you've already guessed: #{Rainbow(guessed_letters).cyan}, "
    puts "  - You have #{Rainbow("#{wrong_guesses_left} wrong guesses").red} left."
    puts "  - Here's your word so far: " + Rainbow(guessed_word).yellow
    puts "\n\n You've got this!\n\n"
  end

  def self.saved_games?
    Dir.children('saved').any?
  end

  def initialize(word, guesses_used=0, guessed_word=nil, wrong_guesses_remaining=5, letters_already_guessed=[])
    @word = word
    @guesses_used = guesses_used
    @wrong_guesses_remaining = wrong_guesses_remaining
    @guessed_word = guessed_word ||''.rjust(@word.length, '_')
    @letters_already_guessed = letters_already_guessed
  end

  def play
    puts "\n\nYour word has #{@word.length} letters:\n\n #{prettified_guessed_word}\n\n"
    game_over if game_over?
    player_turn
    whole_word_guessed? ? announce_winner : play
  end

  def game_over?
    @wrong_guesses_remaining.zero?
  end

  def player_turn
    letter = guess_letter
    letter_in_word?(letter) ? correct_guess(letter) : incorrect_guess(letter)
    @guesses_used += 1
    @letters_already_guessed << letter
    puts prettified_guessed_word
  end

  def correct_guess(letter)
    puts "\nThat letter is in the word!\n\n"
    update_guessed_word(letter)
  end

  def incorrect_guess(letter)
    puts "\n...\n\nHm, no #{letter}'s.\n\n"
    decrement_wrong_guesses
    puts "You have " + red_text(@wrong_guesses_remaining) + " wrong guesses left. Try again."
  end

  def prettified_guessed_word
    yellow_text "\n#{@guessed_word.chars.join(' ')}\n\n\n"
  end

  def guess_letter
    print "Pick a letter (or type 'save' to save your progress)... "
    letter = answer.downcase.strip
    return save_game if save_game?(letter)
    valid_guess?(letter) ? letter : guess_letter
  end

  def save_game?(letter)
    letter == 'save'
  end

  def save_game
    puts "\n\nWhat would you like to call this game? For example, your name.\n"
    game_name = answer.downcase.strip

    file_name = game_name.empty? ? 'saved_game' : game_name

    data = YAML.dump({
      word: @word,
      guesses_used: @guesses_used,
      wrong_guesses_remaining: @wrong_guesses_remaining,
      guessed_word: @guessed_word,
      letters_already_guessed: @letters_already_guessed
    })

    File.open("saved/#{file_name}.txt", 'w') do |file|
      file.write(data)
    end

    puts "\nGot it! Your game will be called #{file_name}. Let's call it a day for now!"
    exit end

  def valid_guess?(letter)
    case
    when already_guessed?(letter) then already_guessed_message(letter)
    when !letter?(letter) then non_letter_message(letter)
    when too_many_characters?(letter) then too_many_characters_message(letter)
    else return true
    end
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

  def already_guessed_message(letter)
    print "\nYou already guessed #{letter}. "
    print "Here are all the letters you've guessed so far: #{@letters_already_guessed.join(", ")}\n\n"
  end

  def non_letter_message(letter)
    puts "\nOpe, #{letter} is not an option. You need to guess a letter.\n\n"
  end

  def too_many_characters_message(letter)
    puts "\nOops! that's #{letter.length} letters. You need to choose just one letter.\n\n"
  end

  def update_guessed_word(letter)
    indices = []
    @word.chars.each.with_index do |char, i|
      indices << i if letter == char
    end

    indices.each do |index|
      @guessed_word[index] = letter
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
    puts green_text('You guessed it - great job!')
    play_again? ? Hangman.play : exit_game
  end

  def game_over
    puts "You ran out of turns. You lost this round. The word was " + purple_text(@word) + ".\n\n"
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

  private

  def red_text(text)
    Rainbow(text).red
  end

  def yellow_text(text)
    Rainbow(text).yellow
  end

  def green_text(text)
    Rainbow(text).green
  end

  def purple_text(text)
    Rainbow(text).purple
  end
end

