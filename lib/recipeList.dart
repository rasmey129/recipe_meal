import 'package:flutter/material.dart';
import 'recipeDetails.dart';
import 'services/recipe_services.dart';

class RecipeListScreen extends StatelessWidget {
  final RecipeService recipeService = RecipeService();

  @override
  Widget build(BuildContext context) {
    final recipes = recipeService.getAllRecipes();

    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe List'),
      ),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          final imageUrl = recipeService.getRecipeImageUrl(recipe);

          return Card(
            elevation: 4,
            margin: const EdgeInsets.all(10.0),
            child: ListTile(
              leading: imageUrl != null
                  ? Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover)
                  : Container(width: 100, height: 100, color: Colors.grey),
              title: Text(recipe),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailsScreen(recipe: recipe),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
