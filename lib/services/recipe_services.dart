
class RecipeService {
  final Map<String, Map<String, dynamic>> _recipeData = {
    'Classic Pancakes': {
      'tags': ['Breakfast', 'Quick Meals', 'Vegetarian'],
      'image': 'assets/classic_pancakes.jpg',
      'description': 'Fluffy, golden pancakes perfect for breakfast',
      'cookTime': '20 mins',
      'difficulty': 'Easy',
      'ingredients': [
        '1 1/2 cups all-purpose flour',
        '3 1/2 teaspoons baking powder',
        '1/4 teaspoon salt',
        '1 tablespoon sugar',
        '1 1/4 cups milk',
        '1 egg',
        '3 tablespoons melted butter'
      ],
      'instructions': [
        'Mix dry ingredients in a bowl',
        'Combine wet ingredients in another bowl',
        'Mix wet and dry ingredients until just combined',
        'Cook on a hot griddle until bubbles form',
        'Flip and cook other side until golden'
      ]
    },
    'Chicken Caesar Salad': {
      'tags': ['Lunch', 'Quick Meals'],
      'image': 'assets/chicken_caesar_salad.jpg',
      'description': 'Fresh and crispy Caesar salad with grilled chicken',
      'cookTime': '15 mins',
      'difficulty': 'Easy',
      'ingredients': [
        'Romaine lettuce',
        'Grilled chicken breast',
        'Parmesan cheese',
        'Caesar dressing',
        'Croutons',
        'Black pepper'
      ],
      'instructions': [
        'Chop lettuce and place in bowl',
        'Slice grilled chicken',
        'Add cheese and croutons',
        'Toss with dressing',
        'Top with fresh black pepper'
      ]
    },
    'Vegetarian Pasta': {
      'tags': ['Dinner', 'Vegetarian'],
      'image': 'assets/vegetarian_pasta.jpg',
      'description': 'Delicious pasta with fresh vegetables',
      'cookTime': '25 mins',
      'difficulty': 'Medium',
      'ingredients': [
        'Spaghetti',
        'Mixed vegetables',
        'Olive oil',
        'Garlic',
        'Italian herbs',
        'Parmesan cheese'
      ],
      'instructions': [
        'Cook pasta according to package',
        'Sauté vegetables in olive oil',
        'Add garlic and herbs',
        'Combine pasta and vegetables',
        'Top with cheese'
      ]
    },
    'Chocolate Chip Cookies': {
      'tags': ['Dessert', 'Vegetarian'],
      'image': 'assets/chocolate_chip_cookies.jpg',
      'description': 'Classic homemade chocolate chip cookies',
      'cookTime': '30 mins',
      'difficulty': 'Medium',
      'ingredients': [
        'Flour',
        'Butter',
        'Brown sugar',
        'White sugar',
        'Eggs',
        'Vanilla extract',
        'Chocolate chips'
      ],
      'instructions': [
        'Cream butter and sugars',
        'Add eggs and vanilla',
        'Mix in dry ingredients',
        'Fold in chocolate chips',
        'Bake at 350°F for 10-12 minutes'
      ]
    },
    'Vegan Buddha Bowl': {
      'tags': ['Lunch', 'Dinner', 'Vegan', 'Gluten-Free'],
      'image': 'assets/vegan_buddha_bowl.jpg',
      'description': 'Nutritious and colorful vegan buddha bowl',
      'cookTime': '35 mins',
      'difficulty': 'Medium',
      'ingredients': [
        'Quinoa',
        'Roasted chickpeas',
        'Sweet potato',
        'Kale',
        'Avocado',
        'Tahini dressing'
      ],
    'instructions': [
        'Cook quinoa',
        'Roast chickpeas and sweet potato',
        'Massage kale with olive oil',
        'Assemble bowl with all ingredients',
        'Top with tahini dressing'
      ]
    }
  };

  List<String> getAllRecipes() {
    return _recipeData.keys.toList();
  }

  String? getRecipeImagePath(String recipe) {
    return _recipeData[recipe]?['image'] as String?;
  }

  List<String>? getRecipeTags(String recipe) {
    final tags = _recipeData[recipe]?['tags'];
    return tags != null ? List<String>.from(tags) : null;
  }

  Map<String, dynamic>? getRecipeDetails(String recipe) {
    return _recipeData[recipe];
  }

  String? getRecipeCookTime(String recipe) {
    return _recipeData[recipe]?['cookTime'] as String?;
  }

  String? getRecipeDifficulty(String recipe) {
    return _recipeData[recipe]?['difficulty'] as String?;
  }
}