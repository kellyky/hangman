# frozen_string_literal: false

require_relative 'hangman'
require 'rainbow'
require 'yaml'
require 'pry-byebug'

# Logic for saved games
class SavedGameData
  def self.exist?
    Dir.children('saved').any?
  end

  def self.files
    Dir.children('saved')
  end

  def self.display_game_options
    saved_games.each do |option_number, game_name|
      puts "  - [#{option_number}] #{game_name}"
    end
    puts "\n\n"
  end

  def self.saved_games
    files.each_with_object({}).with_index do |(file, games), i|
      games[(i + 1).to_s] = file.gsub('.txt', '')
    end
  end

  def self.save_current_game(data)
    puts "\n\nWhat would you like to call this game? For example, your name.\n"
    game_name = gets.chomp.downcase.strip
    file_name = game_name.empty? ? 'saved_game' : game_name

    File.open("saved/#{file_name}.txt", 'w') { |file| file.write(data) }

    puts "\nGot it! Your game will be called #{file_name}. Let's call it a day for now!"
    exit
  end

  def initialize(file)
    @data = YAML.load_file(file)
    @word = @data[:word]
  end

  def play
    recap_game_for_player
    Hangman.new(@word, @data).play
  end

  def recap_game_for_player
    puts Rainbow("\n\nGreat! Picking up where you left off on your saved game:\n\n").mediumturquoise
    puts "  - You have #{wrong_guesses_left} wrong guesses left"
    puts "  - You've already guessed: #{guessed_letters}"
    puts "\n\n You've got this!\n\n\n"
  end

  def guessed_letters
    Rainbow(@data[:letters_already_guessed].join(', ').to_s).cyan
  end

  def wrong_guesses_left
    Rainbow(@data[:wrong_guesses_remaining].to_s).red
  end
end
