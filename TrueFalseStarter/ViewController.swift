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
    @IBOutlet weak var progressBar: UIProgressView!
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
    let viewBackgroundColor = UIColor(red: 0x0 / 255, green: 0x0 / 255, blue: 0x0 / 255, alpha: 1.0)
    let viewLightningColor = UIColor(red: 0xF5 / 255, green: 0x9F / 255, blue: 0x00 / 255, alpha: 1.0)

    var timer = Timer()
    
    enum emoji: String {
        case score0 = "🙁"
        case score1 = "😕"
        case score2 = "😐"
        case score3 = "🙂"
        case score4 = "😀"
    }
    
    var gameInitSound: SystemSoundID = 0
    var gameOverSound: SystemSoundID = 1
    var triviaRightSound: SystemSoundID = 2
    var triviaWrongSound: SystemSoundID = 3
    
    // Setup a trivia provider
    // & prepare first trivia
    let triviaProvider = TriviaProvider()
    var shuffledTrivia: [Trivia] = []
    var currentTrivia = Trivia(question: "", choices: [], answer: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prepare sounds
        loadGameSounds()

        // Setup button title color when disabled
        for button in answerButtons {
            button.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .disabled)
            button.titleLabel!.numberOfLines = 1
            button.titleLabel!.adjustsFontSizeToFitWidth = true
            button.titleLabel!.lineBreakMode = NSLineBreakMode.byClipping
            button.titleLabel!.minimumScaleFactor = 0.08
        }

        // Start a game
        prepareNewGame()
    }

    func prepareNewGame() {
        
        // Get an array of shuffled Trivia questions
        shuffledTrivia = triviaProvider.shuffledTrivia()
        
        // Prepare game
        playGameSound(gameInitSound)
        
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
        
        // Hide the progress bar
        progressBar.isHidden = true

        // Try to get a new Trivia
        if let currentTrivia = triviaProvider.nextTrivia(from: &shuffledTrivia) {

            // We don't need this anymore
            playAgainButton.isHidden = true
            
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
            
            // Unlock the buttons
            lockAnswerButtons(false)
            
            // Random number determines if this question will
            // be in Lightning mode (timeout X seconds)
            //if (GKRandomSource.sharedRandom().nextInt(upperBound: 4) == 3) {
                // 1 on 4 chance to have a lightning question

                //UIView.animate(withDuration: 0.5) { () -> Void in
                //    self.view.backgroundColor = self.viewLightningColor
                //}
                loadNextQuestionWithTimeout()
            //}

        } else {
            // there are no more Trivia questions
            // Start a game with reloaded questions
            prepareNewGame()
        }
        
    }
    
    /// Updates the in-game score display
    func updateScore() {
        //if (scoreLabel.isHidden) { scoreLabel.isHidden = false }
        scoreLabel.text = "Score: \(correctQuestions) — High Score: \(highScore)"
    }
    
    /// Gets called when one of the answer buttons is tapped
    @IBAction func checkAnswer(_ sender: UIButton) {

        // Cancel any running timers
        timer.invalidate()
        progressBar.isHidden = true
        progressBar.setProgress(0.0, animated: false)
        UIView.animate(withDuration: 0.1) { () -> Void in
            self.view.backgroundColor = self.viewBackgroundColor
        }
        
        // Increment the questions asked counter
        questionsAsked += 1
        
        // the chosen answer is correct when its tag == 1
        let answer = sender.tag
        if (answer == 1) {
            correctQuestions += 1
            if (correctQuestions > highScore) { highScore = correctQuestions }
            questionField.text = "Correct!"
            playGameSound(triviaRightSound)
        } else {
            // In Lightning mode, we manually tapped playAgainButton 
            // because no answer-button was tapped
            questionField.text = (sender === playAgainButton) ? "Sorry, you're too late!" : "Sorry, wrong answer!"
            playGameSound(triviaWrongSound)
        }
        
        showCorrectAnswer(answer: sender, triviaAnswer: currentTrivia.answer)

        updateScore()
        
        loadNextRoundWithDelay(seconds: 2)
    }
    
    /// Shows color-coded buttons based on chosen and correct answers
    func showCorrectAnswer(answer: UIButton, triviaAnswer: Int) {

        // prevent additional clicks
        lockAnswerButtons(true)

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
        playGameSound(gameInitSound)
        nextRound()
    }
    
    /// Displays the score when game is finished
    func displayFinalScore() {
        // Hide the answer buttons
        hideAnswerButtons()
        
        // Play a tune
        playGameSound(gameOverSound)

        // Hide the small score label
        // Not necessary anymore because playAgainButton
        // will be displayed on top of it
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
            // should never be shown
            emojiLabel.text = "🦑"
        }
        emojiLabel.isHidden = false
        
        // Display play again button
        playAgainButton.isHidden = false
        
        questionField.text = "You got \(correctQuestions) out of \(questionsAsked) correct!"
    }
    

    // MARK: Helper Methods

    func loadNextQuestionWithTimeout() {
        var counter = 0
        let seconds = 15
        var progress : Float = 0.0
        progressBar.isHidden = false
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            // increase the number of seconds already passed
            counter += 1
            // update progress bar on the main thread
            progress = Float(counter) / Float(seconds)
            DispatchQueue.main.async { [unowned self] in
                self.progressBar.setProgress(progress, animated: true)
                self.view.backgroundColor = UIColor(red: 0xF5 / 255, green: 0x9F / 255, blue: 0x00 / 255, alpha: CGFloat(progress))


            }
            
            // check if timeout happened
            if (counter >= seconds) {
                // After x seconds, we force the game to continue by
                // faking a button tap on a non-answer button
                self.checkAnswer(self.playAgainButton)
            }
            // debug
            //print("Counter \(counter), seconds \(seconds)")
        }
    }
    

    func loadNextRoundWithDelay(seconds: Int) {
        // Reset background color
        view.backgroundColor = viewBackgroundColor

        // Converts a delay in seconds to nanoseconds as signed 64 bit integer
        let delay = Int64(NSEC_PER_SEC * UInt64(seconds))
        // Calculates a time value to execute the method given current time and delay
        let dispatchTime = DispatchTime.now() + Double(delay) / Double(NSEC_PER_SEC)
        
        // Executes the nextRound method at the dispatch time on the main queue
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            
            self.nextRound()

        }
    }
    
    func loadSoundFile(from fileName: String, fileExtension: String, gameSound: inout SystemSoundID) {
        let pathToSoundFile = Bundle.main.path(forResource: fileName, ofType: fileExtension)
        let soundURL = URL(fileURLWithPath: pathToSoundFile!)
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &gameSound)
    }
    
    func loadGameSounds() {
        loadSoundFile(from: "GameInit", fileExtension: "aiff", gameSound: &gameInitSound)
        loadSoundFile(from: "GameOver", fileExtension: "aiff", gameSound: &gameOverSound)
        loadSoundFile(from: "triviaRight", fileExtension: "aiff", gameSound: &triviaRightSound)
        loadSoundFile(from: "triviaWrong", fileExtension: "aiff", gameSound: &triviaWrongSound)
    }
    
    func playGameSound(_ gameSound: SystemSoundID) {
        AudioServicesPlaySystemSound(gameSound)
    }
}

