require 'csv'
require 'json'

class Game
    attr_accessor :word, :mistakesleft, :status, :guessed
    def initialize
        @word = CSV.read('google-10000-english-no-swears.txt')[rand(0..9893)][0]
        @mistakesleft = 7
        @guessed = []
        @status = Array.new(word.length, '_')
    end
end

GAME = Game.new

def play_game
    puts "~~Welcome to Hangman! If you would like to load a previous game, please enter '-' now. Otherwise please type any other character to begin a new game! "
    load_game if gets.chomp == '-'
    puts "Your word to guess is #{GAME.word.length} characters long. You can make #{GAME.mistakesleft} #{GAME.mistakesleft > 1 ? 'mistakes' : 'mistake'} before you lose.\nYou may enter '-' at any prompt to save your game.\nPlease begin by guessing one letter. Good Luck!"
    if GAME.guessed.length > 0
        puts "Word Status: #{GAME.status.join('')}"
        puts "Already Guessed: #{GAME.guessed.join(', ')}"
    end 
    until GAME.mistakesleft == 0 or !GAME.status.include? '_'
        guess = get_guess
        return save_game if guess == '-'
        process_guess(guess)
        if GAME.mistakesleft > 0
            puts "Word Status: #{GAME.status.join('')}"
            puts "Already Guessed: #{GAME.guessed.join(', ')}"
            puts "Mistakes Left: #{GAME.mistakesleft}\n\n"
        end
    end
    if !GAME.status.include? '_'
        puts 'You Win!'
    else
        puts "Sorry, you lose. The word was: #{GAME.word}"
    end
end

def get_guess
    letter = gets.chomp.downcase
    until letter.match?(/^[a-z]$|^\-$/) && letter.length == 1
        puts "Please enter 1 letter."
        letter = gets.chomp.downcase
    end
    letter
end

def process_guess(guess)
    if GAME.guessed.include? guess
        puts 'Already guessed.'
        return
    end
    GAME.guessed.push(guess)
    if !GAME.word.include? guess
        GAME.mistakesleft -= 1
    else
        GAME.word.split('').each_with_index do |letter, i|
            if letter == guess
                GAME.status[i] = letter
            end
        end
    end
end

def save_game
    data = {
        word: GAME.word,
        mistakesleft: GAME.mistakesleft,
        guessed: GAME.guessed,
        status: GAME.status
    }
    Dir.mkdir('saves') unless Dir.exist?('saves')
    File.open('saves/saved_game', 'w') do |file|
        file.puts JSON.dump(data)
    end
end

def load_game
    if File.exist?('saves') and File.file?('saves/saved_game')
        file = File.open('saves/saved_game')
        data = JSON.load(file)
        GAME.word = data['word']
        GAME.mistakesleft = data['mistakesleft']
        GAME.guessed = data['guessed']
        GAME.status = data['status']
        puts "\nGame Loaded!\n"
    else
        puts 'No save found.'
    end
end

play_game