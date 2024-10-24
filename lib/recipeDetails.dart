// recipeDetails.dart
import 'package:flutter/material.dart';
import '/services/recipe_services.dart';  

class DetailsScreen extends StatelessWidget {
  final String recipe;

  DetailsScreen({required this.recipe});

  final RecipeService _recipeService = RecipeService();  // Create an instance of the service

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recipeInfo = _recipeService.getRecipeDetails(recipe);

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recipeInfo != null && recipeInfo["image"] != null)
                Image.network(
                  recipeInfo["image"]!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Text('Image failed to load.');
                  },
                ),
              SizedBox(height: 16.0),
              Text(
                recipeInfo != null ? recipeInfo["description"] ?? "No details available." : "Recipe not found.",
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20.0),
              if (recipeInfo != null && recipeInfo["ingredients"] != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ingredients:",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    for (var ingredient in recipeInfo["ingredients"] as List<String>)
                      Text("- $ingredient", style: TextStyle(fontSize: 16.0)),
                  ],
                ),
              SizedBox(height: 20.0),
              if (recipeInfo != null && recipeInfo["instructions"] != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Instructions:",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    for (var step in recipeInfo["instructions"] as List<String>)
                      Text("• $step", style: TextStyle(fontSize: 16.0)),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
