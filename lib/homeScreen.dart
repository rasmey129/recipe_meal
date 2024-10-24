import 'package:flutter/material.dart';
import 'recipeList.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Planner'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
             
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            Text(
              'Welcome back, username!',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'What would you like to plan today?',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeListScreen(),
                        ),
                      );
                    },
                    icon: Icon(Icons.book),
                    label: Text('Recipes'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                      backgroundColor: Colors.blue,
                      textStyle: TextStyle(fontSize: 20, color: Colors.white), 
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () { },
                    icon: Icon(Icons.calendar_today),
                    label: Text('Meal Planner'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                      backgroundColor: Colors.blue,
                      textStyle: TextStyle(fontSize: 20, color: Colors.white), // Set text color to white
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.shopping_cart),
                    label: Text('Grocery List'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                      backgroundColor: Colors.blue,
                      textStyle: TextStyle(fontSize: 20, color: Colors.white), // Set text color to white
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
