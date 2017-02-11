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
    
    let questionsPerRound = 4
    var questionsAsked = 0
    var correctQuestions = 0
    var indexOfSelectedQuestion: Int = 0
    let maxAnswers = 4
    let buttonNormalColor = UIColor(red: 0x49 / 255, green: 0x50 / 255, blue: 0x57 / 255, alpha: 1.0)
    let buttonChosenColor = UIColor(red: 0xC9 / 255, green: 0x2A / 255, blue: 0x2A / 255, alpha: 1.0)
    let buttonCorrectColor = UIColor(red: 0x2F / 255, green: 0x9E / 255, blue: 0x44 / 255, alpha: 1.0)
    
    
    var gameSound: SystemSoundID = 0
    
    // Setup a trivia provider
    // & prepare first trivia
    let triviaProvider = TriviaProvider()
    var currentTrivia = Trivia(question: "", choices: [], answer: 0)
    
    @IBOutlet weak var questionField: UILabel!
    @IBOutlet var answerButtons: [UIButton]!
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Prepare game
        loadGameStartSound()
        
        // Setup button colors when disabled
        for button in answerButtons {
            button.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .disabled)
        }

        // Start game
        playGameStartSound()
        
        displayQuestion()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func hideAnswerButtons() {
        for button in answerButtons {
          button.isHidden = true
        }
    }
    
    func lockAnswerButtons(_ locked: Bool) {
        for button in answerButtons {
            button.isEnabled = !locked
        }
    }
    
    func showCorrectAnswer(answer: Int, triviaAnswer: Int) {
        // check every button and change styling to show
        // the correct answer
        for button in answerButtons {
            // show choosen answer
            button.tag == answer
                ? (button.backgroundColor = buttonChosenColor)
                : (button.backgroundColor = buttonNormalColor)
            
            // show correct answer
            if (button.tag == triviaAnswer) {
                button.backgroundColor = buttonCorrectColor
            }
            
        }
        // prevent additional clicks
        lockAnswerButtons(true)
    }
    
    func displayQuestion() {
        // Get a new trivia
        currentTrivia = triviaProvider.randomTrivia()
        
        // Setup the question and buttons
        questionField.text = currentTrivia.question
        let numAnswers = currentTrivia.choices.count
        for index in 0..<maxAnswers {
            // reference current button
            let button = answerButtons[index]
            
            // if this is an active button, set title
            if index < numAnswers {
                button.setTitle(currentTrivia.choices[index], for: UIControlState.normal)
                button.backgroundColor = buttonNormalColor
            }

            // set visibility of button
            button.isHidden = index >= numAnswers
        }

        playAgainButton.isHidden = true
        lockAnswerButtons(false)
    }
    
    func updateScore() {
        if (scoreLabel.isHidden) { scoreLabel.isHidden = false }
        scoreLabel.text = "Score: \(correctQuestions)"
    }
    
    func displayFinalScore() {
        // Hide the answer buttons
        hideAnswerButtons()
        
        // Hide the small score label
        scoreLabel.isHidden = true
        
        // Display play again button
        playAgainButton.isHidden = false
        
        questionField.text = "You got \(correctQuestions) out of \(questionsPerRound) correct!"
        
    }
    
    @IBAction func checkAnswer(_ sender: UIButton) {
        // Increment the questions asked counter
        questionsAsked += 1
        
        // the chosen answer is the title of the button that is pushed
        let answer = sender.tag

        showCorrectAnswer(answer: answer, triviaAnswer: currentTrivia.answer)
        
        if (answer == currentTrivia.answer) {
            correctQuestions += 1
            questionField.text = "Correct!"
        } else {
            questionField.text = "Sorry, wrong answer!"
        }
        
        updateScore()
        
        loadNextRoundWithDelay(seconds: 2)
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
        questionsAsked = 0
        correctQuestions = 0
        updateScore()
        nextRound()
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

