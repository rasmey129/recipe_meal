
class RecipeService {
  final Map<String, Map<String, dynamic>> _recipeData = {
    'Classic Pancakes': {
      'tags': ['Breakfast', 'Quick Meals', 'Vegetarian'],
      'image': 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445',
      'description': 'Fluffy, golden pancakes perfect for breakfast',
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
      'image': 'https://images.unsplash.com/photo-1550304943-4f24f54ddde9',
      'description': 'Fresh and crispy Caesar salad with grilled chicken',
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
      'image': 'https://images.unsplash.com/photo-1473093295043-cdd812d0e601',
      'description': 'Delicious pasta with fresh vegetables',
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
      'image': 'https://images.unsplash.com/photo-1499636136210-6f4ee915583e',
      'description': 'Classic homemade chocolate chip cookies',
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
      'image': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd',
      'description': 'Nutritious and colorful vegan buddha bowl',
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

  String? getRecipeImageUrl(String recipe) {
    return _recipeData[recipe]?['image'] as String?;
  }

  List<String>? getRecipeTags(String recipe) {
    final tags = _recipeData[recipe]?['tags'];
    return tags != null ? List<String>.from(tags) : null;
  }

  Map<String, dynamic>? getRecipeDetails(String recipe) {
    return _recipeData[recipe];
  }

 
}