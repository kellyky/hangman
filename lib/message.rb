# frozen_string_literal: false

require 'rainbow'
# require 'yaml'
require 'pry-byebug'

# Messages to player
# TODO: improve classname
class Message
  def self.introduction
    puts "\n====================== Welcome to hangman! ====================== \n\n"
    wrong_guesses_allowed = Rainbow("5").red
    puts "Here's how to play:\n\n"
    puts '  - The computer will choose a word. Your goal is to guess the word, one letter at a time.'
    puts '  - If you do guess all the letters in time, you win!'
    puts "  - If you guess incorrectly #{wrong_guesses_allowed} times, you lose.\n\n"
    puts "\n======================  <<><><> <> <><><>>  ====================== \n\n"
  end

  def self.saved_games
    print "\nYou have saved games. Choose a game to play:\n\n"
  end

  def self.game_does_not_exist(user_response)
    puts "\n\nI don't have any games saved for '#{user_response}'.\n\n"
    puts "Please choose from the games shown - or press [ENTER/RETURN] to start a new game.\n\n"
  end

  def self.saved_game_recap(data)
    word_length = data[:word].length.to_s
    guessed_word = data[:guessed_word].chars.join(' ')
    guessed_letters = data[:letters_already_guessed].join(', ')
    wrong_guesses_left = data[:wrong_guesses_left]
    puts "\n\nGreat! Picking up where you left off:\n\n"
    puts "  - Your word has #{Rainbow("#{word_length} letters").green}"
    puts "  - Here are the letters you've already guessed: #{Rainbow(guessed_letters).cyan}, "
    puts "  - You have #{Rainbow("#{wrong_guesses_left} wrong guesses").red} left."
    puts "  - Here's your word so far: #{Rainbow(guessed_word).yellow}"
    puts "\n\n You've got this!\n\n"
  end

  def self.wrong_letter_and_guesses_left(letter, guesses)
    puts "\n...\n\nHm, no #{letter}'s.\n\n"
    puts "You have #{Rainbow(guesses).red} wrong guesses left. Try again."
  end

  def self.red_text(text)
    Rainbow(text).red
  end

  def self.yellow_text(text)
    Rainbow(text).yellow
  end

  def self.green_text(text)
    Rainbow(text).green
  end

  def self.purple_text(text)
    Rainbow(text).purple
  end
end
