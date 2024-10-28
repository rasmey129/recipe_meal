import 'package:flutter/material.dart';
import 'recipeDetails.dart';
import 'services/recipe_services.dart';
import 'database_helper.dart';

class RecipeListScreen extends StatefulWidget {
  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final RecipeService recipeService = RecipeService();
  final DatabaseHelper _db = DatabaseHelper();
  String searchQuery = '';
  Set<String> selectedTags = {};
  List<String> allRecipes = [];
  Map<String, bool> favorites = {};
  int? userId;
  bool _isLoading = true;
  
  final List<String> availableTags = [
    'Favorites',  
    'Breakfast',
    'Lunch',
    'Dinner',
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Quick Meals',
    'Dessert'
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    allRecipes = recipeService.getAllRecipes();
    await _loadUserAndFavorites();
    setState(() => _isLoading = false);
  }

  Future<void> _loadUserAndFavorites() async {
    final users = await _db.database.then((db) => db.query('users', limit: 1));
    if (users.isNotEmpty) {
      userId = users.first['id'] as int;
      await _loadFavorites();
    }
  }

  Future<void> _loadFavorites() async {
    if (userId != null) {
      final favoriteRecipes = await _db.getFavoriteRecipes(userId!);
      setState(() {
        favorites = Map.fromIterable(
          allRecipes,
          key: (item) => item as String,
          value: (item) => favoriteRecipes.contains(item),
        );
      });
    }
  }

  Future<void> _toggleFavorite(String recipe) async {
    if (userId != null) {
      await _db.toggleFavoriteRecipe(userId!, recipe);
      await _loadFavorites();
    }
  }

  List<String> getFilteredRecipes() {
    return allRecipes.where((recipe) {
      bool matchesSearch = searchQuery.isEmpty ||
          recipe.toLowerCase().contains(searchQuery.toLowerCase());
      
      if (selectedTags.isEmpty) {
        return matchesSearch;
      }

      bool isFavorite = favorites[recipe] ?? false;
      bool needsFavorite = selectedTags.contains('Favorites');
      
      Set<String> otherTags = selectedTags.where((tag) => tag != 'Favorites').toSet();
      
      bool matchesOtherTags = otherTags.isEmpty || 
          otherTags.every((tag) => recipeService.getRecipeTags(recipe)?.contains(tag) ?? false);
      
      return matchesSearch && 
             (!needsFavorite || isFavorite) && 
             matchesOtherTags;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecipes = getFilteredRecipes();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade200,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.blue),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Recipes',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search recipes...',
                              prefixIcon: const Icon(Icons.search, color: Colors.blue),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                              });
                            },
                          ),
                        ),
                      ),
                      
                      Container(
                        height: 50,
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: availableTags.length,
                          itemBuilder: (context, index) {
                            final tag = availableTags[index];
                            final isSelected = selectedTags.contains(tag);
                            final bool isFavoritesTag = tag == 'Favorites';
                            
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isFavoritesTag) 
                                      Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: Icon(
                                          Icons.favorite,
                                          size: 16,
                                          color: isSelected ? Colors.white : Colors.red,
                                        ),
                                      ),
                                    Text(tag),
                                  ],
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      selectedTags.add(tag);
                                    } else {
                                      selectedTags.remove(tag);
                                    }
                                  });
                                },
                                selectedColor: isFavoritesTag ? Colors.red.shade100 : Colors.blue.shade100,
                                checkmarkColor: isFavoritesTag ? Colors.red : Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const Divider(height: 1),

                      // Recipe List
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : filteredRecipes.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.no_meals,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No recipes found',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: filteredRecipes.length,
                                    itemBuilder: (context, index) {
                                      final recipe = filteredRecipes[index];
                                      final imagePath = recipeService.getRecipeImagePath(recipe);
                                      final tags = recipeService.getRecipeTags(recipe) ?? [];
                                      final isFavorite = favorites[recipe] ?? false;

                                      return Card(
                                        elevation: 4,
                                        margin: const EdgeInsets.only(bottom: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => RecipeDetailsScreen(recipe: recipe),
                                              ),
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(20),
                                          child: Column(
                                            children: [
                                              ClipRRect(
                                                borderRadius: const BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  topRight: Radius.circular(20),
                                                ),
                                                child: imagePath != null
                                                    ? Image.asset(
                                                        imagePath,
                                                        height: 200,
                                                        width: double.infinity,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Container(
                                                        height: 200,
                                                        color: Colors.grey[300],
                                                        child: Icon(
                                                          Icons.restaurant,
                                                          size: 50,
                                                          color: Colors.grey[600],
                                                        ),
                                                      ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(16),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            recipe,
                                                            style: const TextStyle(
                                                              fontSize: 20,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                        IconButton(
                                                          icon: Icon(
                                                            isFavorite ? Icons.favorite : Icons.favorite_border,
                                                            color: isFavorite ? Colors.red : Colors.grey,
                                                          ),
                                                          onPressed: () => _toggleFavorite(recipe),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Wrap(
                                                      spacing: 8,
                                                      runSpacing: 8,
                                                      children: tags.map((tag) => Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 6,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.blue.shade50,
                                                          borderRadius: BorderRadius.circular(20),
                                                        ),
                                                        child: Text(
                                                          tag,
                                                          style: TextStyle(
                                                            color: Colors.blue.shade700,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      )).toList(),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}