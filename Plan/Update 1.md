# Update 1  
## General  
* Apply background colours to the tabs using `.recipeBackground`  
* Add dev tab after Recipes tab. It should:  
    * Container a picker for selecting any of the .json mock data object (hardcoded)  
    * Load the current selection from local storage via @AppStorage  
    * Upon changing the selection, save it to local storage via @AppStorage  
    * If the selection changes, show a banner at the bottom of the view stating that the app needs to be restarted for this to take effect.  
* Rename the `ContentView` view to something more descriptive of its usage and purpose.  
* Remove any comments in code that reference CLAUDE.md  
  
## ListView  
* Move recipe list card diet attributes above title for card and detail view.  
    * Also create a DietaryBadgesView that takes an array and sorts it in the initialiser.  
    * DietaryBadgesView should use `ViewThatFits` to switch from HStack to VStack when subviews don’t fit.  
  
## Detail  
* Title text wrapping  
    * Use Text title, that when scrolled out of view shows title in toolbar.  
* Card style. Where it’s title (not in card) followed by content (in a card). So it should be:  
    * Title above card  
    * Description+Servings+Dietary attributes in a card  
    * Ingredients title not in a card  
    * Ingredients in a card  
    * Instructions not in a card  
    * Each instruction step in a card  
        * Additionally, the first step is highlighted. Users can then tap any of the steps to change it to be highlighted (so they can quickly glance at the step they are up to)  
* Icon/image at the top, same as the card view in a list.  
  
Search  
* Inline navigation title  
* Add a new endpoint to return all the data necessary to power the filter feature.  
* Filters dropdown.   
    * Looks like this when collapsed:   
        * Filters             >  
    * Looks like this when expanded:  
        * Filters             V  
        * Dietary        (Select)  
        * Servings      (Select)  
        * Included ingredients:     (Select)  
        * Excluded ingredients:    (Select)  
    * Tapping the (Select) button opens a half detented sheet with filter options. After selecting an option and closing the sheet, the search reloads and the filters are updated. Here is an example with some filters selected.  
        * Filters (3)             V  
        * Dietary        (Vegan)  
        * Servings      (2 servings)  
        * Included ingredients:     (Select)  
        * Excluded ingredients:    (Tofu) (Lettuce)  
    * And if the filters are collapsed whilst some are selected, it would look like this:  
        * Filters (3)             >  
    * So note how the amount of filter options selected is shown in the title  
* For each filter sheet:  
    * Dietary should include label buttons to select one or more dietary attributes for the recipe  
    * Servings should include label buttons to select one serving size. The filter endpoint should read all the recipes and return a set of serving options based on what’s actually available.  
        * For example if there are 3 recipes in the json, and two are 2 servings and one is 6 servings, the options returned would be: 2 servings, 6 servings  
    * Included/excluded ingredients should show all available ingredients, based on the recipes JSON, similar to the servings filtering. All ingredients should be shown in a searchable list. When the sheet is opened the focus should be set to the search bad. Ideally, use List and .searchable APIs for this.  
* Search tab free text should search on submit only, not on change.  
