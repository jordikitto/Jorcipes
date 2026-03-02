# Update 2  
## General  
* variables that are 3 characters or less are NOT preferred. Acronyms are NOT preferred. Prefer spelling things out for clarity. For example, not `vm`, but instead `viewModel`.  
* Add documentation comments to public functions  
* Rename MockAPIClient to LocalAPIClient  
  
## Tests  
* Combine tests into one flow test where possible  
* Write test names using new syntax, @Test func `onAppear triggers loading state`()  
* Add GIVEN:, WHEN:, THEN: comments. For example  
    * GIVEN: View model initialised  
    * WHEN: View appears  
    * THEN: State is loading  
* Only one @Suite per file  
* Ensure tests are testing something that wouldn’t already be tested by the frameworks provided.  
    * For example, testing a model encoded and decodes with the same values is an unnecessary test, since this would already be tested by Apple when they implemented Codable.  
