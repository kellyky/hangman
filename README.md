# Hangman
A text-based version of the classic game, Hangman to play in your terminal.

The computer chooses a word (5-12 charaters). To win, guess all letters in the word. If you guess incorrectly 5 times, you lose and the game is over.

## Setup
This game was written in Ruby and you'll need Ruby to play if you do not have it. 
1. Clone this repo `git clone git@github.com:kellyky/hangman.git`
2. cd into this repo `cd hangman`

## Gameplay
You play the game in your terminal. 

To play:
```
ruby play_hangman.rb
```

## Features
- Play a new game
- Save a game to play later
- Play a saved game picking up where you left off
- New game has hidden kid-mode (my friend's kids made a list of words).
  - To play kid-mode, type 'sierra' instead of either selecting a saved game or pressing return to start a new game in standard mode
- Standard mode uses google's 10k most commonly used words

## TODOs
- Update test coverage
- Handle saved games that are played and completed
