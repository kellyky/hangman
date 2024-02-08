# frozen_string_literal: false

require './lib/hangman'
require 'pry-byebug'

RSpec.describe Hangman do
  subject { described_class.new(wordlist) }
  let(:wordlist) { %w[a asdfasdfasdfasdf banana] }

  describe '.play' do
    it 'should call play' do
      expect(subject).to receive(:play)
      subject.play
    end
  end

  describe '#play' do
    before do
      allow(subject).to receive(:whole_word_guessed?).and_return(false)
      allow(subject).to receive(:answer).and_return('a')
    end

    context 'when whole_word_guessed is true' do
      before { allow(subject).to receive(:whole_word_guessed?).and_return(true) }
      it 'calls play' do
        expect(subject).to receive(:announce_winner)
        subject.play
      end
    end

    context 'when whole_word_guessed is false' do
      it 'calls play' do
        expect(subject).to receive(:play)
        subject.play
      end
    end
  end

  describe '#evaluate_guess_count' do
    context 'when it is the first guess' do
      it 'calls welcome sequence' do
        subject.instance_variable_set(:@guesses_used, 0)
        expect(subject).to receive(:welcome_player)
        subject.evaluate_guess_count
      end
    end

    context 'when the player is out of wrong guesses' do
      it 'calls game_over' do
        subject.instance_variable_set(:@guesses_used, 5)
        subject.instance_variable_set(:@wrong_guesses_remaining, 0)
        expect(subject).to receive(:game_over)
        subject.evaluate_guess_count
      end
    end
  end

  describe '#player_turn' do
    before { allow(subject).to receive(:answer).and_return(letter) }
    context 'when the player guesses a correct letter' do
      let(:letter) { 'a' }
      it 'calls the correct_guess process' do
        expect(subject).to receive(:correct_guess).with(letter)
        subject.player_turn
      end
    end

    context 'when the player guesses an incorrect letter' do
      let(:letter) { 'z' }
      it 'calls the correct_guess process' do
        expect(subject).to receive(:incorrect_guess).with(letter)
        subject.player_turn
      end
    end
  end

  describe '#correct_guess' do
    it 'should call update_guessed_word to update it with the correct letter' do
      letter = 'a'
      expect(subject).to receive(:update_guessed_word).with(letter)
      subject.correct_guess(letter)
    end
  end

  describe '#incorrect_guess' do
    it 'should call decrement_wrong_guesses' do
      expect(subject).to receive(:decrement_wrong_guesses)
      subject.incorrect_guess('z')
    end
  end

  describe '#prettified_guessed_word' do
    let(:guessed_word) { 'ab_' }
    before { subject.instance_variable_set(:@guessed_word, guessed_word) }

    it 'prints the letters and/or "_" characters with a space between them' do
      expect(subject.prettified_guessed_word.match?("a b _")).to be(true)
    end
  end

  describe '#guess_letter' do
    before { allow(subject).to receive(:answer).and_return('a') }
    it 'should call answer (a method that gets player input)' do
      expect(subject).to receive(:answer)
      subject.guess_letter
    end
  end

  describe '#save_game?' do
    context 'when the player typed "save"' do
      let(:letter) { 'save' }
      it { expect(subject.save_game?(letter)).to be true }
    end

    context 'when the player typed something else' do
      let(:letter) { 'e' }
      it { expect(subject.save_game?(letter)).to be false }
    end
  end

  describe '#save_game' do
    # test code that saves game
  end

  describe '#valid_guess?' do
    context 'when the letter was already guessed' do
      let(:letter) { 'a' }
      before { subject.instance_variable_set(:@letters_already_guessed, 'a') }

      it 'should call already_guessed_message' do
        expect(subject).to receive(:already_guessed_message).with(letter)
        subject.valid_guess?(letter)
      end
    end

    context 'when the guess is not a letter' do
      let(:letter) { ';' }
      it 'should call non_letter_message' do
        expect(subject).to receive(:non_letter_message).with(letter)
        subject.valid_guess?(letter)
      end
    end

    context 'when the guess has too many characters' do
      let(:letter) { 'asdf123gfgb;' }
      it 'should call too_many_characters_message' do
        expect(subject).to receive(:too_many_characters_message).with(letter)
        subject.valid_guess?(letter)
      end
    end

    context 'when the letter is otherwise valid and not yet guessed' do
      it 'should return true' do
        expect(subject.valid_guess?('a')).to be(true)
      end
    end
  end

  describe '#update_guessed_word' do
    it 'should update the guessed_word with the correctly-guessed letter' do
      guessed_word = '______'
      subject.instance_variable_set(:@guessed_word, guessed_word)
      subject.update_guessed_word('a')
      expect(guessed_word).to eq('_a_a_a')
    end
  end

  describe '#decrement__wrong_guesses' do
    let!(:initial_guess_count) { subject.wrong_guesses_remaining }
    it 'decrements remaining guesses by 1' do
      subject.decrement_wrong_guesses
      expect(subject.wrong_guesses_remaining).to eq(initial_guess_count - 1)
    end
  end

  describe '#letter_in_word?' do
    context 'when the letter does not appear in the word' do
      it { expect(subject.letter_in_word?('z')).to be(false) }
    end

    context 'when the letter appears in the word' do
      it { expect(subject.letter_in_word?('a')).to be(true) }
    end
  end

  describe '#whole_word_guessed?' do
    context 'when all letters have been guessed' do
      it 'returns true' do
        subject.instance_variable_set(:@guessed_word, 'banana')
        expect(subject.whole_word_guessed?).to be(true)
      end
    end

    context 'when NOT all letters have been guessed' do
      it 'returns false' do
        subject.instance_variable_set(:@guessed_word, '_anana')
        expect(subject.whole_word_guessed?).to be(false)
      end
    end
  end

  describe '#announce_winner' do
    context 'when the player wants to play again' do
      before { allow(subject).to receive(:play_again?).and_return(true) }
      it 'should call Hangman.play to start a new game' do
        expect(described_class).to receive(:play)
        subject.announce_winner
      end
    end

    context 'when the player does not want to play again' do
      before { allow(subject).to receive(:play_again?).and_return(false) }
      it 'should call byebye to exit' do
        expect(subject).to receive(:byebye)
        subject.announce_winner
      end
    end
  end

  describe '#game_over' do
    context 'when the player wants to play again' do
      before { allow(subject).to receive(:play_again?).and_return(true) }
      it 'should start a new game' do
        expect(described_class).to receive(:play)
        subject.game_over
      end
    end

    context 'when the player does not want to play again' do
      before { allow(subject).to receive(:play_again?).and_return(false) }
      it 'should call byebye' do
        expect(subject).to receive(:byebye)
        subject.game_over
      end
    end
  end

  describe '#play_again' do
    context 'when the player selects 1 to play again' do
      before { allow(subject).to receive(:answer).and_return('1') }
      it { expect(subject.play_again?).to be(true) }
    end

    context 'when the player selects something other than 1 to exit' do
      before { allow(subject).to receive(:answer).and_return('x') }
      it { expect(subject.play_again?).to be(false) }
    end
  end

  describe '#answer' do
    it 'returns what the user entered' do
      allow($stdin).to receive(:gets).and_return('yo')
      answer = $stdin.gets
      expect(answer).to eq('yo')
    end
  end

  describe '#byebye' do
    it { expect { subject.byebye }.to raise_exception SystemExit }
  end
end
