//
//  ContentView.swift
//  WordScramble
//
//  Created by Baymurat Abdumuratov on 10/02/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var userWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    
    
    var body: some View {
        NavigationStack{
            List{
                Section{
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section("Per word you can earn 4 points"){
                    Text("8 * \(userWords.count) = \(8 * userWords.count)")
                }
                
                Section{
                    ForEach(userWords, id: \.self){
                        word in
                        
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                            
                        }
                    }
                }
            }
            .onAppear(perform: startGame)
            .navigationTitle(rootWord)
            .onSubmit {
                addNewWord()
            }
            .toolbar {
                Button {
                    startGame()
                    userWords.removeAll()
                } label: {
                    Text("Restart")
                }

            }
        }
        .alert(errorTitle, isPresented: $showingError) {
            Button("OK"){
                
            }
        }message: {
            Text(errorMessage)
        }
    }
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'! Make sure that your word is more than three letters and not equal to original word")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        withAnimation {
            userWords.insert(answer, at: 0)
        }
        
        newWord = ""
    }
    func startGame(){
        // 1. Find the URL for start.txt in our app bundle
        if let startWordURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            // 2. Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordURL){
                
                // 3. Split the string up into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")
                
                
                // 4. Pick one random word, or use "silkworm" as a sensible default
                
                rootWord = allWords.randomElement() ?? "silkworm"
                
                // If we are here everything has worked, so we can exit
                            return
            }
        }
        
        // If were are *here* then there was a problem – trigger a crash and report the error
            fatalError("Could not load start.txt from bundle.")
    }
    
    
    func isOriginal(word: String) -> Bool{
        !userWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool{
        var tempWord = rootWord
        for letter in word{
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            }else {
                return false
            }
        }
        
        if word == rootWord || word.count < 3{
            return false
        }
        
        
        return true
    }
    
    func isReal(word: String) -> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        
        return misspelledRange.location == NSNotFound
    }

    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    
    
}

#Preview {
    ContentView()
}
