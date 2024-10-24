class RecipeService {
  final Map<String, Map<String, dynamic>> _recipeDetails = {
    "Pancakes": {
      "description": "Fluffy pancakes with syrup and butter.",
      "image": "https://cdn.apartmenttherapy.info/image/upload/f_auto,q_auto:eco,c_fill,g_auto,w_1500,ar_3:2/k%2FPhoto%2FRecipes%2F2024-06-seo-pancakes%2Fseo-pancakes-232",
      "ingredients": [
        "1 1/2 cups all-purpose flour",
        "2 tablespoons sugar",
        "1 tablespoon baking powder",
        "1 1/4 cups milk",
        "5 tablespoons unsalted butter",
        "1 large egg",
        "1/2 teaspoon salt",
        "2 teaspoons vanilla extract"
      ],
      "instructions": [
        "1. Mix dry ingredients in a bowl.",
        "2. Mix wet ingredients in another bowl.",
        "3. Combine both mixtures and stir.",
        "4. Cook on a greased griddle until golden."
      ]
    },
    "Omelette": {
      "description": "A classic omelette.",
      "image": "https://i2.wp.com/www.downshiftology.com/wp-content/uploads/2021/12/How-to-Make-an-Omelette-17.jpg",
      "ingredients": [
        "2 large eggs",
        "Kosher salt",
        "Ground black pepper",
        "Olive oil or butter"
      ],
      "instructions": [
        "1. Whisk eggs, salt, and pepper.",
        "2. Heat oil in a pan and pour in eggs.",
        "3. Cook until set and fold."
      ]
    },
    "Ham Sandwich": {
      "description": "Delicious ham sandwich.",
      "image": "https://www.seriouseats.com/thmb/j4q7hzhs2rgUFbMIJ6TyOIkWWdY=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/20240305-SEA-HamandCheese-Amanda-Suarez-herojpg-5f7304ba4a7e43018052d2056495c266.jpg",
      "ingredients": [
        "4 slices bread",
        "2 tablespoons mayonnaise",
        "2 teaspoons mustard",
        "8 slices ham",
        "4 slices cheese",
        "Pickles (optional)"
      ],
      "instructions": [
        "1. Spread mayonnaise on each slice of bread.",
        "2. Top with ham, cheese, and mustard.",
        "3. Grill the sandwich until golden."
      ]
    }
  };

  List<String> getAllRecipes() {
    return _recipeDetails.keys.toList();
  }

  Map<String, dynamic>? getRecipeDetails(String recipeName) {
    return _recipeDetails[recipeName];
  }

  String? getRecipeImageUrl(String recipeName) {
    return _recipeDetails[recipeName]?["image"];
  }
}
