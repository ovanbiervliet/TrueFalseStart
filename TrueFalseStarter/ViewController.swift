//
//  ViewController.swift
//  TrueFalseStarter
//
//  Created by Pasan Premaratne on 3/9/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import UIKit
import GameKit
import AudioToolbox

class ViewController: UIViewController {
    
    @IBOutlet weak var questionField: UILabel!
    @IBOutlet var answerButtons: [UIButton]!
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var emojiLabel: UILabel!
    
    let questionsPerRound = 4
    var questionsAsked = 0
    var correctQuestions = 0
    var indexOfSelectedQuestion: Int = 0
    let maxAnswers = 4
    var highScore = 0
    let buttonNormalColor = UIColor(red: 0x49 / 255, green: 0x50 / 255, blue: 0x57 / 255, alpha: 1.0)
    let buttonChosenColor = UIColor(red: 0xC9 / 255, green: 0x2A / 255, blue: 0x2A / 255, alpha: 1.0)
    let buttonCorrectColor = UIColor(red: 0x2F / 255, green: 0x9E / 255, blue: 0x44 / 255, alpha: 1.0)
    enum emoji: String {
        case score0 = "🙁"
        case score1 = "😕"
        case score2 = "😐"
        case score3 = "🙂"
        case score4 = "😀"
    }
    
    
    var gameSound: SystemSoundID = 0
    
    // Setup a trivia provider
    // & prepare first trivia
    let triviaProvider = TriviaProvider()
    var shuffledTrivia: [Trivia] = []
    var currentTrivia = Trivia(question: "", choices: [], answer: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get an array of shuffled Trivia questions
        shuffledTrivia = triviaProvider.shuffledTrivia()
        
        // Prepare game
        loadGameStartSound()
        playGameStartSound()
        
        // Setup button title color when disabled
        for button in answerButtons {
            button.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .disabled)
        }

        // Hide the score emoji
        emojiLabel.isHidden = true
        
        // Start game
        displayQuestion()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// Hides the answer buttons when game level is finished
    func hideAnswerButtons() {
        for button in answerButtons {
          button.isHidden = true
        }
        emojiLabel.isHidden = false
    }
    
    /// Locks answer buttons after one was tapped,
    /// to avoid accidental extraneous taps.
    func lockAnswerButtons(_ locked: Bool) {
        for button in answerButtons {
            button.isEnabled = !locked
        }
    }
    
    /// Fetches and displays a question
    func displayQuestion() {
        // Get a new trivia
        //currentTrivia = triviaProvider.randomTrivia()
        
        // Try to get a new Trivia
        if let currentTrivia = triviaProvider.nextTrivia(from: &shuffledTrivia) {
            // Setup the question
            questionField.text = currentTrivia.question
            
            // Determine number of answers
            let numAnswers = currentTrivia.choices.count
            
            // Configure the buttons
            for index in 0..<maxAnswers {
                
                // reference current button
                let button = answerButtons[index]
                
                // if this is an active button, set title
                if index < numAnswers {
                    button.setTitle(currentTrivia.choices[index], for: UIControlState.normal)
                    button.backgroundColor = buttonNormalColor
                    
                    // Set tag to 1 if button contains correct answer,
                    // otherwise set it to zero
                    button.tag = (index + 1 == currentTrivia.answer) ? 1 : 0
                }
                
                // set visibility of button
                button.isHidden = index >= numAnswers
            }
            playAgainButton.isHidden = true
            lockAnswerButtons(false)
        } else {
            // there are no more Trivia questions
            displayFinalScore()
        }
        
    }
    
    /// Updates the in-game score display
    func updateScore() {
        //if (scoreLabel.isHidden) { scoreLabel.isHidden = false }
        scoreLabel.text = "Score: \(correctQuestions)\nHigh Score: \(highScore)"
    }
    
    /// Gets called when one of the answer buttons is tapped
    @IBAction func checkAnswer(_ sender: UIButton) {
        // Increment the questions asked counter
        questionsAsked += 1
        
        // the chosen answer is correct when its tag == 1
        let answer = sender.tag

        if (answer == 1) {
            correctQuestions += 1
            if (correctQuestions > highScore) { highScore = correctQuestions }
            questionField.text = "Correct!"
        } else {
            questionField.text = "Sorry, wrong answer!"
        }
        
        showCorrectAnswer(answer: sender, triviaAnswer: currentTrivia.answer)

        updateScore()
        
        loadNextRoundWithDelay(seconds: 2)
    }
    
    /// Shows color-coded buttons based on chosen and correct answers
    func showCorrectAnswer(answer: UIButton, triviaAnswer: Int) {

        // check every button and change styling to show
        // the correct answer
        for button in answerButtons {
            
            // set correct answer green, others neutral
            button.tag == 1
                ? (button.backgroundColor = buttonCorrectColor)
                : (button.backgroundColor = buttonNormalColor)
            
            // if answer was wrong, make it red
            if (answer.tag != 1) {
                answer.backgroundColor = buttonChosenColor
            }
            
        }
        // prevent additional clicks
        lockAnswerButtons(true)
    }
    
    func nextRound() {
        if questionsAsked == questionsPerRound {
            // Game is over
            displayFinalScore()
        } else {
            // Continue game
            displayQuestion()
        }
    }
    
    @IBAction func playAgain() {
        emojiLabel.isHidden = true
        questionsAsked = 0
        correctQuestions = 0
        updateScore()
        nextRound()
    }
    
    /// Displays the score when game is finished
    func displayFinalScore() {
        // Hide the answer buttons
        hideAnswerButtons()
        
        // Hide the small score label
        //scoreLabel.isHidden = true
        
        // Show correct emoji
        let scorePercent = Int(100 * correctQuestions / questionsAsked)
        switch scorePercent {
        case 0 ..< 25:
            emojiLabel.text = emoji.score0.rawValue
        case 25 ..< 50:
            emojiLabel.text = emoji.score1.rawValue
        case 50 ..< 75:
            emojiLabel.text = emoji.score2.rawValue
        case 75 ..< 100:
            emojiLabel.text = emoji.score3.rawValue
        case 100:
            emojiLabel.text = emoji.score4.rawValue
        default:
            emojiLabel.text = "🦑"
        }
        emojiLabel.isHidden = false
        
        
        // Display play again button
        playAgainButton.isHidden = false
        
        questionField.text = "You got \(correctQuestions) out of \(questionsAsked) correct!"
        
    }
    

    
    // MARK: Helper Methods
    
    func loadNextRoundWithDelay(seconds: Int) {
        // Converts a delay in seconds to nanoseconds as signed 64 bit integer
        let delay = Int64(NSEC_PER_SEC * UInt64(seconds))
        // Calculates a time value to execute the method given current time and delay
        let dispatchTime = DispatchTime.now() + Double(delay) / Double(NSEC_PER_SEC)
        
        // Executes the nextRound method at the dispatch time on the main queue
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            self.nextRound()
        }
    }
    
    func loadGameStartSound() {
        let pathToSoundFile = Bundle.main.path(forResource: "GameSound", ofType: "wav")
        let soundURL = URL(fileURLWithPath: pathToSoundFile!)
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &gameSound)
    }
    
    func playGameStartSound() {
        AudioServicesPlaySystemSound(gameSound)
    }
}

