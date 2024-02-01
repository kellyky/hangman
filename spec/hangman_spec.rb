# frozen_string_literal: true

require './lib/hangman'
require 'pry-byebug'

RSpec.describe Hangman do
  subject { described_class.new(wordlist) }
  let(:wordlist) { ['a', 'asdfasdfasdfasdf', 'banana'] }

  describe '.play' do
    it 'should call play' do
      expect(subject).to receive(:play)
      subject.play
    end
  end

  describe '#play' do
    it 'calls evaluate_guess_count' do
    end

    it 'calls player_turn' do
    end

    it 'checks if whole word is guessed' do
    end

    context 'when the word was guessed' do
      # before { allow(subject).to receive(:whole_word_guessed).and_return(true) }
      # it 'calls announce_winner' do
      #   expect(subject).to receive(:announce_winner)
      #   subject.play
      # end
    end

    context 'when the word was not yet guessed' do
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

  describe '#welcome_player' do
  end

  describe '#player_turn' do
    before { allow(subject).to receive(:answer).and_return('a') }
    it 'something' do
    end
  end

  describe '#guess_letter' do
  end

  describe '#try_again' do
  end

  describe '#valid_guess?' do
  end

  describe '#update_guessed_word' do
  end

  describe '#decrement_guesses' do
    let!(:initial_guess_count) { subject.wrong_guesses_remaining }
    it 'decrements remaining guesses by 1' do
      subject.decrement_guesses
      expect(subject.wrong_guesses_remaining).to eq(initial_guess_count - 1)
    end
  end

  describe '#letter_in_word?' do
    context 'when the letter does not appear in the word' do
      it 'asdf' do
        expect(subject.letter_in_word?('z')).to be(false)
      end
    end

    context 'when the letter appears in the word' do
      it 'asdf' do
        expect(subject.letter_in_word?('a')).to be(true)
      end
    end
  end

  describe '#whole_word_guessed?' do
  end

  describe '#announce_winner' do
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

  # does this actually test answer though?
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
