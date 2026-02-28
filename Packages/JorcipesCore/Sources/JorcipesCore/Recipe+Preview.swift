public extension Recipe {
    static let preview = Recipe(
        title: "Classic Margherita Pizza",
        description: "A traditional Italian pizza with fresh mozzarella, basil, and tomato sauce.",
        servings: 4,
        ingredients: [
            Ingredient(id: "pizza-dough", name: "Pizza Dough", quantity: "1 ball", dietaryAttributes: [.vegetarian, .vegan]),
            Ingredient(id: "mozzarella", name: "Fresh Mozzarella", quantity: "200g", dietaryAttributes: [.vegetarian]),
            Ingredient(id: "san-marzano-tomatoes", name: "San Marzano Tomatoes", quantity: "1 can", dietaryAttributes: [.vegetarian, .vegan]),
            Ingredient(id: "fresh-basil", name: "Fresh Basil", quantity: "1 bunch", dietaryAttributes: [.vegetarian, .vegan]),
            Ingredient(id: "olive-oil", name: "Extra Virgin Olive Oil", quantity: "2 tbsp", dietaryAttributes: [.vegetarian, .vegan])
        ],
        instructions: [
            "**Preheat** the oven to 250°C (480°F) with a pizza stone or inverted baking sheet inside.",
            "Stretch the dough into a 12-inch round on a floured surface. Transfer to a piece of parchment paper.",
            "Crush the San Marzano tomatoes by hand and spread evenly over the dough, leaving a 1-inch border.",
            "Tear the mozzarella into pieces and distribute across the pizza. Drizzle with olive oil.",
            "Slide the pizza (on parchment) onto the hot stone. Bake for **8–10 minutes** until the crust is golden and cheese is bubbly.",
            "Top with *fresh basil leaves* and serve immediately."
        ]
    )

    static let previewList: [Recipe] = [
        .preview,
        Recipe(
            title: "Grilled Chicken Caesar Salad",
            description: "Crispy romaine lettuce topped with grilled chicken, parmesan, and creamy caesar dressing.",
            servings: 2,
            ingredients: [
                Ingredient(id: "chicken-breast", name: "Chicken Breast", quantity: "2 pieces", dietaryAttributes: []),
                Ingredient(id: "romaine-lettuce", name: "Romaine Lettuce", quantity: "1 head", dietaryAttributes: [.vegetarian, .vegan]),
                Ingredient(id: "parmesan", name: "Parmesan Cheese", quantity: "50g", dietaryAttributes: [.vegetarian]),
                Ingredient(id: "croutons", name: "Croutons", quantity: "1 cup", dietaryAttributes: [.vegetarian]),
                Ingredient(id: "caesar-dressing", name: "Caesar Dressing", quantity: "4 tbsp", dietaryAttributes: [.vegetarian])
            ],
            instructions: [
                "Season chicken breasts with salt, pepper, and a drizzle of olive oil.",
                "Grill over **medium-high heat** for 6–7 minutes per side until internal temperature reaches 74°C (165°F).",
                "Wash and chop the romaine lettuce into bite-sized pieces. Place in a large bowl.",
                "Slice the grilled chicken. Toss lettuce with caesar dressing, top with chicken, croutons, and *shaved parmesan*."
            ]
        ),
        Recipe(
            title: "Vegan Thai Green Curry",
            description: "A fragrant and creamy Thai curry made with tofu, coconut milk, and fresh vegetables.",
            servings: 4,
            ingredients: [
                Ingredient(id: "firm-tofu", name: "Firm Tofu", quantity: "400g", dietaryAttributes: [.vegetarian, .vegan]),
                Ingredient(id: "coconut-milk", name: "Coconut Milk", quantity: "1 can (400ml)", dietaryAttributes: [.vegetarian, .vegan]),
                Ingredient(id: "green-curry-paste", name: "Green Curry Paste", quantity: "3 tbsp", dietaryAttributes: [.vegetarian, .vegan]),
                Ingredient(id: "bell-peppers", name: "Bell Peppers", quantity: "2 mixed colors", dietaryAttributes: [.vegetarian, .vegan]),
                Ingredient(id: "jasmine-rice", name: "Jasmine Rice", quantity: "2 cups", dietaryAttributes: [.vegetarian, .vegan]),
                Ingredient(id: "thai-basil", name: "Thai Basil", quantity: "1 handful", dietaryAttributes: [.vegetarian, .vegan])
            ],
            instructions: [
                "Press tofu for 15 minutes, then cut into 1-inch cubes.",
                "Heat a tablespoon of oil in a wok over **high heat**. Fry tofu until golden on all sides, about 5 minutes. Set aside.",
                "In the same wok, cook the curry paste for 1 minute until fragrant. Pour in coconut milk and stir to combine.",
                "Add sliced bell peppers and simmer for **5–7 minutes** until tender.",
                "Return tofu to the wok. Stir gently and cook for 2 more minutes.",
                "Serve over steamed jasmine rice, garnished with *fresh Thai basil*."
            ]
        ),
        Recipe(
            title: "Classic Beef Tacos",
            description: "Seasoned ground beef in crispy taco shells with fresh toppings and melted cheese.",
            servings: 6,
            ingredients: [
                Ingredient(id: "ground-beef", name: "Ground Beef", quantity: "500g", dietaryAttributes: []),
                Ingredient(id: "taco-shells", name: "Taco Shells", quantity: "12 shells", dietaryAttributes: [.vegetarian, .vegan]),
                Ingredient(id: "iceberg-lettuce", name: "Iceberg Lettuce", quantity: "1/2 head", dietaryAttributes: [.vegetarian, .vegan]),
                Ingredient(id: "tomato", name: "Tomato", quantity: "2 large", dietaryAttributes: [.vegetarian, .vegan]),
                Ingredient(id: "cheddar-cheese", name: "Cheddar Cheese", quantity: "1 cup shredded", dietaryAttributes: [.vegetarian]),
                Ingredient(id: "sour-cream", name: "Sour Cream", quantity: "1/2 cup", dietaryAttributes: [.vegetarian])
            ],
            instructions: [
                "Brown the ground beef in a skillet over **medium-high heat**, breaking it apart as it cooks.",
                "Drain excess fat. Add taco seasoning and 1/4 cup of water. Simmer for **3–4 minutes** until thickened.",
                "Warm taco shells according to package directions.",
                "Shred lettuce and dice tomatoes. Set up a taco bar with all toppings.",
                "Fill each shell with seasoned beef, then top with lettuce, tomato, *shredded cheddar*, and a dollop of sour cream."
            ]
        ),
        Recipe(
            title: "Wild Mushroom Risotto",
            description: "Creamy Italian risotto made with a medley of wild mushrooms, butter, and parmesan.",
            servings: 3,
            ingredients: [
                Ingredient(id: "arborio-rice", name: "Arborio Rice", quantity: "1.5 cups", dietaryAttributes: [.vegetarian, .vegan]),
                Ingredient(id: "mixed-mushrooms", name: "Mixed Wild Mushrooms", quantity: "300g", dietaryAttributes: [.vegetarian, .vegan]),
                Ingredient(id: "vegetable-broth", name: "Vegetable Broth", quantity: "4 cups", dietaryAttributes: [.vegetarian, .vegan]),
                Ingredient(id: "butter", name: "Butter", quantity: "3 tbsp", dietaryAttributes: [.vegetarian]),
                Ingredient(id: "parmesan-risotto", name: "Parmesan Cheese", quantity: "3/4 cup grated", dietaryAttributes: [.vegetarian]),
                Ingredient(id: "yellow-onion", name: "Yellow Onion", quantity: "1 medium", dietaryAttributes: [.vegetarian, .vegan]),
                Ingredient(id: "garlic", name: "Garlic", quantity: "3 cloves", dietaryAttributes: [.vegetarian, .vegan])
            ],
            instructions: [
                "Heat vegetable broth in a saucepan and keep at a gentle simmer.",
                "In a large pan, melt 1 tbsp butter over **medium heat**. Sauté mushrooms until golden, about 5 minutes. Set aside.",
                "In the same pan, sauté diced onion and minced garlic in 1 tbsp butter until softened, about 3 minutes.",
                "Add arborio rice and stir for **1–2 minutes** until the grains are lightly toasted and translucent at the edges.",
                "Add broth one ladle at a time, stirring frequently. Wait until each addition is mostly absorbed before adding the next. This takes about **18–20 minutes**.",
                "When rice is *al dente* and creamy, remove from heat. Stir in remaining butter, parmesan, and the sautéed mushrooms. Season to taste."
            ]
        )
    ]
}
