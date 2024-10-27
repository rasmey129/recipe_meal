import 'package:flutter/material.dart';
import 'services/recipe_services.dart';
import 'database_helper.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  _GroceryListScreenState createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  final RecipeService _recipeService = RecipeService();
  final DatabaseHelper _db = DatabaseHelper();
  final Map<String, bool> _groceryItems = {};
  final List<String> _selectedRecipes = [];
  int? _userId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _db.database.then((db) => db.query('users', limit: 1));
      if (users.isNotEmpty) {
        _userId = users.first['id'] as int;
        await _loadGroceryList();
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadGroceryList() async {
    if (_userId == null) return;

    final groceryList = await _db.getGroceryList(_userId!);
    
    setState(() {
      _groceryItems.clear();
      for (var item in groceryList) {
        _groceryItems[item['ingredient'] as String] = item['is_checked'] == 1;
      }
    });
  }

  Future<void> _addRecipeIngredients(String recipe) async {
    if (_userId == null) return;

    final recipeDetails = _recipeService.getRecipeDetails(recipe);
    if (recipeDetails != null) {
      setState(() {
        _selectedRecipes.add(recipe);
      });

      // First, add all ingredients to the database
      for (String ingredient in recipeDetails['ingredients']) {
        if (!_groceryItems.containsKey(ingredient)) {
          await _db.addToGroceryList(_userId!, ingredient);
        }
      }

      // Then reload the grocery list to ensure consistency
      await _loadGroceryList();
    }
  }

  Future<void> _removeRecipe(String recipe) async {
    if (_userId == null) return;

    final recipeDetails = _recipeService.getRecipeDetails(recipe);
    if (recipeDetails != null) {
      setState(() {
        _selectedRecipes.remove(recipe);
      });

      // Remove ingredients that aren't used in other selected recipes
      for (String ingredient in recipeDetails['ingredients']) {
        bool usedInOtherRecipes = false;
        for (String otherRecipe in _selectedRecipes) {
          final otherRecipeDetails = _recipeService.getRecipeDetails(otherRecipe);
          if (otherRecipeDetails != null && 
              otherRecipeDetails['ingredients'].contains(ingredient)) {
            usedInOtherRecipes = true;
            break;
          }
        }

        if (!usedInOtherRecipes) {
          await _db.removeFromGroceryList(_userId!, ingredient);
        }
      }

      // Reload the grocery list to ensure consistency
      await _loadGroceryList();
    }
  }

  Future<void> _toggleGroceryItem(String ingredient) async {
    if (_userId == null) return;

    await _db.toggleGroceryItem(_userId!, ingredient);
    await _loadGroceryList();
  }

  Future<void> _clearCheckedItems() async {
    if (_userId == null) return;

    // Get all checked items
    final checkedItems = _groceryItems.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    // Remove checked items from selected recipes if necessary
    for (String recipe in List.from(_selectedRecipes)) {
      final recipeDetails = _recipeService.getRecipeDetails(recipe);
      if (recipeDetails != null) {
        bool allIngredientsChecked = recipeDetails['ingredients']
            .every((ingredient) => checkedItems.contains(ingredient));
        
        if (allIngredientsChecked) {
          _selectedRecipes.remove(recipe);
        }
      }
    }

    await _db.clearCheckedGroceryItems(_userId!);
    await _loadGroceryList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddRecipeDialog,
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_selectedRecipes.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.blue.shade50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recipes Added:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _selectedRecipes.map((recipe) {
                            return Chip(
                              label: Text(recipe),
                              onDeleted: () {
                                _removeRecipe(recipe);
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                ],

                Expanded(
                  child: _groceryItems.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Your grocery list is empty\nTap + to add recipes',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          children: [
                            ..._buildGroceryCategories(),
                          ],
                        ),
                ),
              ],
            ),
      floatingActionButton: _groceryItems.isNotEmpty
          ? FloatingActionButton(
              onPressed: _clearCheckedItems,
              tooltip: 'Clear checked items',
              child: const Icon(Icons.cleaning_services),
            )
          : null,
    );
  }

  List<Widget> _buildGroceryCategories() {
    Map<String, List<MapEntry<String, bool>>> categorizedItems = {};
    
    for (var item in _groceryItems.entries) {
      String category = _categorizeIngredient(item.key);
      categorizedItems.putIfAbsent(category, () => []);
      categorizedItems[category]!.add(item);
    }

    List<Widget> categories = [];
    categorizedItems.forEach((category, items) {
      if (items.isNotEmpty) {
        categories.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
              ...items.map((item) => _buildGroceryItem(item.key, item.value)),
            ],
          ),
        );
      }
    });
    return categories;
  }

  Widget _buildGroceryItem(String item, bool isChecked) {
    return CheckboxListTile(
      title: Text(
        item,
        style: TextStyle(
          decoration: isChecked ? TextDecoration.lineThrough : null,
          color: isChecked ? Colors.grey : null,
        ),
      ),
      value: isChecked,
      onChanged: (bool? value) {
        _toggleGroceryItem(item);
      },
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  void _showAddRecipeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        List<String> availableRecipes = _recipeService.getAllRecipes()
            .where((recipe) => !_selectedRecipes.contains(recipe))
            .toList();

        return AlertDialog(
          title: const Text('Add Recipe Ingredients'),
          content: SizedBox(
            width: double.maxFinite,
            child: availableRecipes.isEmpty
                ? const Center(
                    child: Text('All recipes have been added'),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = availableRecipes[index];
                      final recipeDetails = _recipeService.getRecipeDetails(recipe);
                      
                      return ListTile(
                        title: Text(recipe),
                        subtitle: Text('${recipeDetails?["ingredients"].length ?? 0} ingredients'),
                        onTap: () async {
                          await _addRecipeIngredients(recipe);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  String _categorizeIngredient(String ingredient) {
    ingredient = ingredient.toLowerCase();
    
    if (ingredient.contains('flour') || 
        ingredient.contains('sugar') || 
        ingredient.contains('baking') ||
        ingredient.contains('vanilla')) {
      return 'Baking & Spices';
    } else if (ingredient.contains('milk') || 
               ingredient.contains('cheese') || 
               ingredient.contains('butter') ||
               ingredient.contains('egg')) {
      return 'Dairy & Eggs';
    } else if (ingredient.contains('bread') || 
               ingredient.contains('bun') || 
               ingredient.contains('roll')) {
      return 'Bread & Bakery';
    }
    
    return 'Other Ingredients';
  }
}