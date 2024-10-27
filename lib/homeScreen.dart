import 'package:flutter/material.dart';
import 'groceryList.dart';
import 'profile.dart';
import 'recipeList.dart';
import 'mealPlanner.dart';
import 'database_helper.dart';
import 'login.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  String _username = 'User';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _db.database.then((db) => db.query('users', limit: 1));
      if (users.isNotEmpty) {
        setState(() {
          _username = users.first['name'] as String;
        });
      } else {
        _navigateToLogin();
      }
    } catch (e) {
      print('Error loading user data: $e');
      _navigateToLogin();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _logout() async {
    await _db.database.then((db) => db.close());
    _navigateToLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, $_username!',
                                style: const TextStyle(
                                  fontSize: 28.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'What would you like to plan today?',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.account_circle, size: 30),
                                color: Colors.blue,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfileScreen(),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.logout, size: 30),
                                color: Colors.blue,
                                onPressed: _logout,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildMenuCard(
                              icon: Icons.book,
                              title: 'Recipes',
                              subtitle: 'Browse and discover new recipes',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => RecipeListScreen()),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildMenuCard(
                              icon: Icons.calendar_today,
                              title: 'Meal Planner',
                              subtitle: 'Plan your weekly meals',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MealPlannerScreen()),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildMenuCard(
                              icon: Icons.shopping_cart,
                              title: 'Grocery List',
                              subtitle: 'Manage your shopping list',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => GroceryListScreen()),
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

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}