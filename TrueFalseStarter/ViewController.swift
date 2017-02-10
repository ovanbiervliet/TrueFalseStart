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
    
    var gameSound: SystemSoundID = 0
    
    // Setup a trivia provider
    // & prepare first trivia
    let triviaProvider = TriviaProvider()
    var currentTrivia = Trivia(question: "", choices: [], answer: "")
    
    @IBOutlet weak var questionField: UILabel!
    @IBOutlet var answerButtons: [UIButton]!
    @IBOutlet weak var playAgainButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Prepare game
        loadGameStartSound()
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
    
    
    func displayQuestion() {
        // Get a new trivia
        currentTrivia = triviaProvider.randomTrivia()
        
        questionField.text = currentTrivia.question
        let numAnswers = currentTrivia.choices.count
        for index in 0..<maxAnswers {
            // reference current button
            let button = answerButtons[index]
            
            // set visibility of button
            button.isHidden = index >= numAnswers
            
            // if this is an active button, set title
            if index < numAnswers {
                button.setTitle(currentTrivia.choices[index], for: UIControlState.normal)
            }
        }
        
        playAgainButton.isHidden = true
    }
    
    func displayScore() {
        // Hide the answer buttons
        hideAnswerButtons()
        
        // Display play again button
        playAgainButton.isHidden = false
        
        questionField.text = "Way to go!\nYou got \(correctQuestions) out of \(questionsPerRound) correct!"
        
    }
    
    @IBAction func checkAnswer(_ sender: UIButton) {
        // Increment the questions asked counter
        questionsAsked += 1
        

        // the chosen answer is the title of the button that is pushed
        let answer = sender.currentTitle
        
        if (answer == currentTrivia.answer) {
            correctQuestions += 1
            questionField.text = "Correct!"
        } else {
            questionField.text = "Sorry, wrong answer!"
        }
        
        loadNextRoundWithDelay(seconds: 2)
    }
    
    func nextRound() {
        if questionsAsked == questionsPerRound {
            // Game is over
            displayScore()
        } else {
            // Continue game
            displayQuestion()
        }
    }
    
    @IBAction func playAgain() {
        questionsAsked = 0
        correctQuestions = 0
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

