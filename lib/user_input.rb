# frozen_string_literal: true

require 'pry-byebug'

class UserInput

  def self.answer
    gets.chomp.strip
  end

  def initialize(answer)
    @answer = answer
  end

  def valid_letter?
    true
  end

  def letter
    @answer
  end

  def valid_guess?
    letter? && !too_many_characters?
  end

  def response_is_not_a_letter?

  end

  def too_many_characters?
    @answer.length > 1
  end

end
