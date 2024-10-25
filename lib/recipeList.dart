import 'package:flutter/material.dart';
import 'recipeDetails.dart';
import 'services/recipe_services.dart';

class RecipeListScreen extends StatefulWidget {
  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final RecipeService recipeService = RecipeService();
  String searchQuery = '';
  Set<String> selectedTags = {};
  List<String> allRecipes = [];
  
  final List<String> availableTags = [//for tags/filters
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
    allRecipes = recipeService.getAllRecipes();
  }

  List<String> getFilteredRecipes() {
    return allRecipes.where((recipe) {
     bool matchesSearch = searchQuery.isEmpty ||
          recipe.toLowerCase().contains(searchQuery.toLowerCase());
      
      if (selectedTags.isEmpty) {
        return matchesSearch;
      }

      bool matchesTags = selectedTags.every((tag) =>
          recipeService.getRecipeTags(recipe)?.contains(tag) ?? false);

      return matchesSearch && matchesTags;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecipes = getFilteredRecipes();

    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe List'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          
          //fiilters
          Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: availableTags.length,
              itemBuilder: (context, index) {
                final tag = availableTags[index];
                final isSelected = selectedTags.contains(tag);
                
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(tag),
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
                    selectedColor: Colors.blue[100],
                    checkmarkColor: Colors.blue,
                  ),
                );
              },
            ),
          ),

          Divider(height: 1),

          // Recipe List
          Expanded(
            child: filteredRecipes.isEmpty
                ? Center(
                    child: Text(
                      'No recipes found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = filteredRecipes[index];
                      final imageUrl = recipeService.getRecipeImageUrl(recipe);
                      final tags = recipeService.getRecipeTags(recipe) ?? [];

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: imageUrl != null
                                    ? Image.network(
                                        imageUrl,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.grey[300],
                                        child: Icon(
                                          Icons.restaurant,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                              ),
                              title: Text(
                                recipe,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Wrap(
                                spacing: 4,
                                children: tags.map((tag) => Chip(
                                  label: Text(
                                    tag,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: Colors.grey[200],
                                )).toList(),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.arrow_forward),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RecipeDetailsScreen(
                                        recipe: recipe,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}