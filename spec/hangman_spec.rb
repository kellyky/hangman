# frozen_string_literal: false

require './lib/hangman'
require 'pry-byebug'

RSpec.describe Hangman do
  subject { described_class.new('banana') }

  describe '.play' do
    context 'when there ARE saved games' do
      it 'should go through the saved_games_options' do
        allow(described_class).to receive(:saved_games_exist?).and_return(true)
        expect(described_class).to receive(:saved_game)
        described_class.play
      end
    end

    context 'when there are NO saved games' do
      it 'should call new_game' do
        allow(described_class).to receive(:saved_games_exist?).and_return(false)
        expect(described_class).to receive(:new_game)
        described_class.play
      end
    end
  end

  describe '.saved_games_exist?' do
    context 'when there are saved games' do
      before { allow(Dir).to receive(:children).with('saved').and_return(['saved/file.txt']) }
      it { expect(described_class.saved_games_exist?).to be true}
    end

    context 'when there are no saved games' do
      before { allow(Dir).to receive(:children).with('saved').and_return([]) }
      it { expect(described_class.saved_games_exist?).to be false}
    end
  end

  describe '.new_game' do
    it 'should call play' do
      expect(subject).to receive(:play)
      subject.play
    end
  end

  describe '.wordlist' do
    it 'should return an array/list of words' do
      expect(described_class.wordlist.class).to be(Array)
    end
  end

  describe '.saved_game' do
    let(:files) { ['file_a.txt', 'file_b.txt'] }
    let(:saved_games) { { '1' => 'file_a', '2' => 'file_b' } }
    let(:user_response) { '1' }

    before do
      allow(Dir).to receive(:children).with('saved').and_return(files)
      allow(described_class).to receive(:saved_games).with(files).and_return(saved_games)
      allow(described_class).to receive(:user_response).and_return(user_response)
    end

    it 'calls parse_input, passing in the user response & saved games hash as args' do
      expect(described_class).to receive(:parse_input).with(user_response, saved_games)
      described_class.saved_game
    end
  end

  describe '.user_response' do
    context 'when input is empty' do
      it 'returns what the user entered' do
        allow(described_class).to receive(:gets).and_return('')
        expect(described_class.user_response).to be_empty
      end
    end

    context 'when there is whitespace' do
      it 'returns what the user entered - stripped of whitespace' do
        allow(described_class).to receive(:gets).and_return(' 4 ')
        expect(described_class.user_response).to eq('4')
      end
    end

    context 'when there is no whitespace' do
      it 'returns what the user entered' do
        allow(described_class).to receive(:gets).and_return('1')
        expect(described_class.user_response).to eq('1')
      end
    end
  end

  describe '.files' do
    let!(:files) { ['file_a.txt', 'file_b.txt'] }

    before { allow(Dir).to receive(:children).with('saved').and_return(files) }
    it 'creates an array of files in saved directory' do
      expect(described_class.files).to eq(files)
    end
  end

  describe '.saved_games' do
    let(:files) { ['file_a.txt', 'file_b.txt'] }
    let(:expected_saved_games) { {"1"=>"file_a", "2"=>"file_b"} }

    before { allow(Dir).to receive(:children).with('saved').and_return(files) }
    it 'returns a hash' do
      expect(described_class.saved_games(files)).to eq(expected_saved_games)
    end
  end

  describe '.parse_input' do
    let(:saved_games) { {"1"=>"file_a", "2"=>"file_b"} }

    context 'when user input is empty' do
      let(:user_response) { '' }

      it 'calls self.new_game' do
        expect(described_class).to receive(:new_game)
        described_class.parse_input(user_response, saved_games)
      end
    end

    context 'when user selects a valid option' do
      let(:user_response) { '2' }
      let(:files) { ['file_a.txt', 'file_b.txt'] }

      before { allow(Dir).to receive(:children).with('saved').and_return(files) }

      it 'calls resume_saved_game, passing in the selected file' do
        file = 'saved/file_b.txt'
        expect(described_class).to receive(:resume_saved_game).with(file)
        described_class.parse_input(user_response, saved_games)
      end
    end

    # context 'when user selects an invalid option' do
    #   # don't think my code handles this yet
    #   let(:user_response) { '3' }
    #   let(:files) { ['file_a.txt', 'file_b.txt'] }

    #   before { allow(Dir).to receive(:children).with('saved').and_return(files) }

    #   it 'calls resume_saved_game, passing in the selected file' do
    #     file = 'saved/file_b.txt'
    #     expect(described_class).to receive(:resume_saved_game).with(file)
    #     described_class.parse_input(user_response, saved_games)
    #   end
    # end
  end

  # how to test this one though?
  describe '.resume_saved_game' do
  end

  describe '.game_recap' do
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

  # TODO
  describe '#show_word_length' do
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
      it 'should call exit_game' do
        expect(subject).to receive(:exit_game)
        subject.game_over
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

  describe '#display_already_guessed_letters' do
  end

  describe '#save_game?' do
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

  describe '#already_guessed?' do
  end

  describe '#letter?' do
  # non letter should be false
  # letter should be true
  end

  describe '#too_many_characters?' do
    context 'when 2 or more characters are entered' do
      it 'should return true' do
      end
    end

    context 'when 1 character is entered' do
      it 'should return false' do
      end
    end
  end

  describe '#guessed_letters' do
  # undecided about this method
  # currently sorts the array and joins with a comma

  end

  describe '#already_guessed_message' do
    # probably not testing this - just a string with interpolation
  end

  describe '#non_letter_message' do
    # probably not testing this - just a string with interpolation
  end

  describe '#too_many_characters_message' do
    # probably not testing this - just a string with interpolation
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
      it 'should call exit_game to exit' do
        expect(subject).to receive(:exit_game)
        subject.announce_winner
      end
    end
  end

  describe '#game_over' do
    context 'when the player chooses to play_again' do
      # should call Hangman.play
    end

    context 'when the player chooses to stop playing' do
      # should call exit_game
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

  describe '#exit_game' do
    it { expect { subject.exit_game }.to raise_exception SystemExit }
  end
end
