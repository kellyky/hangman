# frozen_string_literal: false

require 'rainbow'

# Prints basic how to play - text only / no logic
class Introduction
  def self.display
    puts "\n\n"
    print_welcome
    puts "\n\n"
    how_to_play
  end

  def self.print_welcome
    print Rainbow(" <<>> Welcome to Hangman! <<>>\n").royalblue.bright.center(80)
  end

  def self.how_to_play
    puts 'Your goal is to guess the word, one letter at a time:'
    puts "#{Rainbow(' - To win,').teal.bright} guess the word before you run out of guesses\n"
    puts " - If you guess incorrectly #{Rainbow('5').crimson} times, you #{Rainbow('you lose').crimson.bright}"
  end

  def self.how_to_save_progress
    print Rainbow("\n\nA tip before we start: You can save your game.").mediumvioletred.italic
    print Rainbow(" To do so, type 'save' when prompted for a letter.\n\n").mediumvioletred.italic
  end
end
