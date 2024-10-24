import 'package:flutter/material.dart';
import 'services/recipe_services.dart';
import 'recipeDetails.dart';

class MealPlannerScreen extends StatefulWidget {
  @override
  _MealPlannerScreenState createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  final RecipeService _recipeService = RecipeService();
  DateTime _selectedDate = DateTime.now();
  
  // Structure: {'2024-3-24': {'breakfast': 'Pancakes', 'lunch': 'Ham Sandwich', 'dinner': 'Pasta'}}
  Map<String, Map<String, String>> _mealPlan = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Planner'),
      ),
      body: Column(
        children: [
          // Calendar Section
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.blue.shade200),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
                        });
                      },
                    ),
                    Text(
                      '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() {
                          _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                _buildCalendarGrid(),
              ],
            ),
          ),
          
          // Meals for Selected Day
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  _buildMealTimeSection('Breakfast'),
                  SizedBox(height: 16),
                  _buildMealTimeSection('Lunch'),
                  SizedBox(height: 16),
                  _buildMealTimeSection('Dinner'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTimeSection(String mealTime) {
    final dateKey = '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}';
    final meal = _mealPlan[dateKey]?[mealTime.toLowerCase()];

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  mealTime,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _showRecipeSelectionDialog(mealTime.toLowerCase()),
                  tooltip: 'Add $mealTime',
                ),
              ],
            ),
            SizedBox(height: 8),
            if (meal != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeDetailsScreen(recipe: meal),
                          ),
                        );
                      },
                      child: Text(
                        meal,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() {
                        _mealPlan[dateKey]?.remove(mealTime.toLowerCase());
                        if (_mealPlan[dateKey]?.isEmpty ?? false) {
                          _mealPlan.remove(dateKey);
                        }
                      });
                    },
                    tooltip: 'Remove $mealTime',
                  ),
                ],
              ),
            ] else
              Text(
                'No meal planned',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final startingWeekday = firstDayOfMonth.weekday;

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 7 + daysInMonth + (startingWeekday - 1),
      itemBuilder: (context, index) {
        if (index < 7) {
          return Center(
            child: Text(
              ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        }

        final dayNumber = index - 7 - (startingWeekday - 2);
        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return Container();
        }

        final dateKey = '${_selectedDate.year}-${_selectedDate.month}-$dayNumber';
        final isSelected = dayNumber == _selectedDate.day;
        final hasMeal = _mealPlan.containsKey(dateKey);

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, dayNumber);
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : (hasMeal ? Colors.blue.shade100 : null),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.transparent,
              ),
            ),
            child: Center(
              child: Text(
                dayNumber.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: hasMeal ? FontWeight.bold : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRecipeSelectionDialog(String mealTime) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select a Recipe'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _recipeService.getAllRecipes().length,
              itemBuilder: (context, index) {
                final recipe = _recipeService.getAllRecipes()[index];
                return ListTile(
                  title: Text(recipe),
                  onTap: () {
                    setState(() {
                      final dateKey = '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}';
                      _mealPlan.putIfAbsent(dateKey, () => {});
                      _mealPlan[dateKey]![mealTime] = recipe;
                    });
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

  String _getMonthName(int month) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month - 1];
  }
}