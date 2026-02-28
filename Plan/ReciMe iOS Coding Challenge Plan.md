# ReciMe iOS Coding Challenge Plan  
Read the ReciMe iOS Coding Challenge.pdf file to understand the requirements.  
  
From the requirements, we will generate a plan for implementation together.   
  
However the following are some additional guidelines of my own:  
  
**Model**  
* The “Dietary attributes” of the model should be computed from the ingredients. That is, each ingredient should contain a Set of type DietaryAttributes.   
    * The DietaryAttributes enum should have the following cases:  
        * Vegetarian  
        * Vegan  
    * The the recipe should should then have its own computed Set of DietaryAttributes, where:  
        * If ALL ingredients have the Vegetarian attribute, then the recipes has the Vegetarian attribute. Similar for Vegan.  
* The Number of servings will be static.  
* The Cooking Instructions will be an array of AttributedString. Ordered by cooking steps. The JSON will contain markdown so that the steps can have formatting such as bold and italics. When the Recipe model is loaded from the API JSON response, it will load the markdown using `try AttributedString(markdown:)`.  
* Create multiple different mock local JSON files to test with. Have at least:  
    * An empty result  
    * A result with 5 recipes  
    * A result with 50 recipes  
    * A result with a corrupted recipe that causes a decoding error.  
* Add a random delay of 0.5s to 1.5s to the API client to provide a realistic mock experience.  
  
**Views**  
* Each view should have a working preview.  
* Use native iOS/SwiftUI components as much as possible.  
* Each recipe in the adaptive grid should have a card style and look. When opening to the detail view, use a navigationTransition. See how to do so here: [https://peterfriese.dev/blog/2024/hero-animation/](https://peterfriese.dev/blog/2024/hero-animation/)  
* Use a tab view with a search tab. The search tab should contain the necessary filter options as listed in the PDF.  
* Remember to consider iPad screen sizes, and changing from compact to regular size classes.  
* Ensure there is an appropriate empty state and error state for the recipe list/grid.  
  
**Architecture**  
* Use MVVM, reference the mvvm.md for guidelines.  
* Use local packages, including but not limited to:  
    * A design system package, which should include:  
        * A reusable color palette  
        * A base 4 spacing system that is an extension of CGFloat, with values:  
            * .space50 = 2pt  
            * .space100 = 4pt  
            * .space150 = 6pt  
            * .space200 = 8pt  
            * .space300 = 12pt  
            * .space400 = 16pt  
            * And so on until space1000  
        * Include predefined corner radii to use.  
    * A networking package  
    * A package for the search feature  
    * A package for the grid/list  
    * A package with core models (Recipes)  
