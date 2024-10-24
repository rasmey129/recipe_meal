import 'package:flutter/material.dart';
import 'services/recipe_services.dart';

class RecipeDetailsScreen extends StatelessWidget {
  final String recipe;
  final RecipeService recipeService = RecipeService();

  RecipeDetailsScreen({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final recipeDetails = recipeService.getRecipeDetails(recipe);

    if (recipeDetails == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(recipe),
        ),
        body: Center(
          child: Text("No details found for this recipe."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Image.network(recipeDetails["image"] ?? '', height: 200, fit: BoxFit.cover),
            SizedBox(height: 16),
            Text(
              recipeDetails["description"] ?? "No description available.",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text("Ingredients", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ...recipeDetails["ingredients"].map<Widget>((ingredient) => Text("• $ingredient")),
            SizedBox(height: 16),
            Text("Instructions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ...recipeDetails["instructions"].map<Widget>((instruction) => Text("• $instruction")),
          ],
        ),
      ),
    );
  }
}
