# frozen_string_literal: false

require 'pry-byebug'

# A text-based game of hangman
class Hangman
  attr_reader :wrong_guesses_remaining

  def self.play
    new(File.read('google-10000-english-no-swears.txt').split).play
  end

  def initialize(wordlist)
    @word = wordlist.select { |word| word.length >= 5 && word.length <= 12 }.shuffle.pop
    @guesses_used = 0
    @wrong_guesses_remaining = 5
    @guessed_word = ''.rjust(@word.length, '_')
  end

  def play
    evaluate_guess_count
    player_turn
    whole_word_guessed? ? announce_winner : play
  end

  def evaluate_guess_count
    if @guesses_used.zero?
      welcome_player
    elsif @wrong_guesses_remaining.zero?
      game_over
    end
  end

  def welcome_player
    puts "\nWelcome to hangman!\n\n\nHere's how to play:\n\n"
    puts '  - The computer will choose a word. Your goal is to guess the word, one letter at a time.'
    puts '  - If you do guess all the letters in time, you win!'
    puts "  - If you guess incorrectly #{wrong_guesses_remaining} times, you lose.\n\n"
    puts "The word has #{@word.length} letters.\n\n\n"
  end

  def player_turn
    letter = guess_letter
    letter_in_word?(letter) ? correct_guess(letter) : incorrect_guess(letter)
    @guesses_used += 1
    pretty_print_guessed_word
  end

  def correct_guess(letter)
    puts "\nThat letter is in the word!\n\n"
    update_guessed_word(letter)
  end

  def incorrect_guess(letter)
    puts "\n...\n\nHm, no #{letter}'s.\n\n"
    decrement_wrong_guesses
    puts "You have #{@wrong_guesses_remaining} wrong guesses left. Try again"
  end

  def pretty_print_guessed_word
    puts "\n#{@guessed_word.chars.join(' ')}\n\n\n"
  end

  def guess_letter
    print 'Pick a letter... '
    letter = answer
    puts "\nOk, let's see if there are any '#{letter}'s..."
    valid_guess?(letter) ? letter : try_again
  end

  def try_again
    puts 'Ope, that\'s not an option. Try again.'
    guess_letter
  end

  def valid_guess?(letter)
    letter.downcase.match?(/[a-z]/)
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
    puts 'You guessed it - great job!'
    play_again? ? Hangman.play : byebye
  end

  def game_over
    puts "You ran out of turns. The word was '#{@word}'.\n\n"
    puts "Better luck next time!\n\n"
    play_again? ? Hangman.play : byebye
  end

  def play_again?
    puts "\nWould you like to play again? Press '1' for yes and any other key to exit."
    answer == '1'
  end

  def answer
    gets.chomp
  end

  def byebye
    puts "\nOk, let's call it a day. Have a good one!"
    exit
  end
end
