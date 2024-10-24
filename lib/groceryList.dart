import 'package:flutter/material.dart';
import 'services/recipe_services.dart';

class GroceryListScreen extends StatefulWidget {
  @override
  _GroceryListScreenState createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  final RecipeService _recipeService = RecipeService();
  Map<String, bool> _groceryItems = {};
  List<String> _selectedRecipes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grocery List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddRecipeDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Selected Recipes Section
          if (_selectedRecipes.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recipes Added:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
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
            Divider(height: 1),
          ],

          // Grocery List
          Expanded(
            child: _groceryItems.isEmpty
                ? Center(
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
              child: Icon(Icons.cleaning_services),
              tooltip: 'Clear checked items',
            )
          : null,
    );
  }

  List<Widget> _buildGroceryCategories() {
    Map<String, List<MapEntry<String, bool>>> categorizedItems = {};
    
    _groceryItems.entries.forEach((item) {
      String category = _categorizeIngredient(item.key);
      categorizedItems.putIfAbsent(category, () => []);
      categorizedItems[category]!.add(item);
    });

    List<Widget> categories = [];
    categorizedItems.forEach((category, items) {
      categories.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
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
        setState(() {
          _groceryItems[item] = value ?? false;
        });
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
          title: Text('Add Recipe Ingredients'),
          content: Container(
            width: double.maxFinite,
            child: availableRecipes.isEmpty
                ? Center(
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
                        onTap: () {
                          _addRecipeIngredients(recipe);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _addRecipeIngredients(String recipe) {
    final recipeDetails = _recipeService.getRecipeDetails(recipe);
    if (recipeDetails != null) {
      setState(() {
        _selectedRecipes.add(recipe);
        for (String ingredient in recipeDetails['ingredients']) {
          _groceryItems.putIfAbsent(ingredient, () => false);
        }
      });
    }
  }

  void _removeRecipe(String recipe) {
    final recipeDetails = _recipeService.getRecipeDetails(recipe);
    if (recipeDetails != null) {
      setState(() {
        _selectedRecipes.remove(recipe);
        for (String ingredient in recipeDetails['ingredients']) {
          _groceryItems.remove(ingredient);
        }
      });
    }
  }

  void _clearCheckedItems() {
    setState(() {
      _groceryItems.removeWhere((key, value) => value);
    });
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