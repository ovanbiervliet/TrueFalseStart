//
//  TriviaProvider.swift
//  TrueFalseStarter
//
//  Created by oVan on 09/02/2017.
//  Copyright © 2017 Treehouse. All rights reserved.
//

import GameKit

class Trivia {
    let question: String
    let choices: [String]
    let answer: Int
    
    init(question: String, choices: [String], answer: Int) {
        self.question = question
        self.choices = choices
        self.answer = answer
    }
}

class TriviaProvider {
    let allTrivia: [Trivia] = [
        Trivia(question: "Only female koalas can whistle", choices: ["True", "False"], answer: 2),
        Trivia(question: "Blue whales are technically whales", choices: ["True", "False"], answer: 1),
        Trivia(question: "Camels are cannibalistic", choices: ["True", "False"], answer: 2),
        Trivia(question: "All ducks are birds", choices: ["True", "False"], answer: 1),
        Trivia(question: "This was the only US President to serve more than two consecutive terms.", choices: ["George Washington", "Franklin D. Roosevelt", "Woodrow Wilson",  "Andrew Jackson"], answer: 2),
        Trivia(question: "Which of the following countries has the most residents?", choices: ["Nigeria", "Russia", "Iran", "Vietnam"], answer: 1),
        Trivia(question: "In what year was the United Nations founded?", choices: ["1918", "1919", "1945", "1954"], answer: 3),
        Trivia(question: "The Titanic departed from the United Kingdom, where was it supposed to arrive?", choices: ["Paris", "Washington D.C.", "New York City", "Boston"], answer: 3),
        Trivia(question: "Which nation produces the most oil?", choices: ["Iran", "Iraq", "Brazil", "Canada"], answer: 4),
        Trivia(question: "Which country has most recently won consecutive World Cups in Soccer?", choices: ["Italy", "Brazil", "Argentina", "Spain"], answer: 2),
        Trivia(question: "Which of the following rivers is longest?", choices: ["Yangtze", "Mississippi", "Congo", "Mekong"], answer: 2),
        Trivia(question: "Which city is the oldest?", choices: ["Mexico City", "Cape Town", "San Juan", "Sydney"], answer: 1),
        Trivia(question: "Which country was the first to allow women to vote in national elections?", choices: ["Poland", "United States", "Sweden", "Senegal"], answer: 1),
        Trivia(question: "Which of these countries won the most medals in the 2012 Summer Games?", choices: ["France", "Germany", "Japan", "Great Britian"], answer: 4),
    ]
    
    /// Return a random trivia question
    func randomTrivia() -> Trivia {
        let randomNumber = GKRandomSource.sharedRandom().nextInt(upperBound: allTrivia.count)
        return allTrivia[randomNumber]
    }
}
