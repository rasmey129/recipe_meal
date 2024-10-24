class RecipeService {
  final Map<String, Map<String, dynamic>> recipeDetails = {
    "Pancakes": {
      "description": "Fluffy pancakes with syrup and butter.",
      "image": "https://cdn.apartmenttherapy.info/image/upload/f_auto,q_auto:eco,c_fill,g_auto,w_1500,ar_3:2/k%2FPhoto%2FRecipes%2F2024-06-seo-pancakes%2Fseo-pancakes-232",
      "ingredients": [
        "1 1/2 cups of all-purpose Flour",
        "2 tablespoons Sugar",
        "1 tablespoon Baking powder",
        "1 1/4 cups of Milk",
        "5 tablespoon Unsalted Butter",
        "1 large egg",
        "1/2 teaspoon of fine salt",
        "2 teaspoon vanilla extract"
      ],
      "instructions": [
        "1. Melt the butter and set it aside. In a medium bowl, whisk together the flour, sugar, baking powder and salt",
        "2. In a separate bowl, whisk together milk, egg, melted butter, and vanilla extract",
        "3. Create a well in the center of your dry ingredients. Pour in the milk mixture and stir gently until incorporated. As the batter sits it should start to bubble",
        "4. Place a griddle over medium heat.",
        "5. Brush the griddle with melted butter.",
        "6. Scoop the batter onto the griddle and spread each pancake into a 4-inch circle.",
        "7. Serve with syrup, butter, and berries."
      ]
    },
    //More recipes...
  };

  Map<String, dynamic>? getRecipeDetails(String recipeName) {
    return recipeDetails[recipeName];
  }
}
