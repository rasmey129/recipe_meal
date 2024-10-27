import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'recipe_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Enable foreign key support
        await db.execute('PRAGMA foreign_keys = ON');

        // Create users table
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            age INTEGER,
            email TEXT UNIQUE,
            password TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE meal_plans(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            date TEXT NOT NULL,
            meal_type TEXT NOT NULL,
            recipe_name TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
            UNIQUE(user_id, date, meal_type)
          )
        ''');
        await db.execute('CREATE INDEX idx_meal_plans_user_date ON meal_plans(user_id, date)');

        await db.execute('''
          CREATE TABLE favorites(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            recipe_name TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
            UNIQUE(user_id, recipe_name)
          )
        ''');
        await db.execute('CREATE INDEX idx_favorites_user ON favorites(user_id)');

        await db.execute('''
          CREATE TABLE grocery_lists(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            ingredient TEXT NOT NULL,
            is_checked INTEGER DEFAULT 0,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('CREATE INDEX idx_grocery_user ON grocery_lists(user_id)');
      },
    );
  }

  Future<void> insertUser(String name, int age, String email, String password) async {
    final db = await database;
    await db.insert(
      'users',
      {'name': name, 'age': age, 'email': email, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> authenticateUser(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return maps.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<void> saveMealPlan(int userId, String date, String mealType, String recipeName) async {
    final db = await database;
    await db.insert(
      'meal_plans',
      {
        'user_id': userId,
        'date': date,
        'meal_type': mealType,
        'recipe_name': recipeName,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeMealPlan(int userId, String date, String mealType) async {
    final db = await database;
    await db.delete(
      'meal_plans',
      where: 'user_id = ? AND date = ? AND meal_type = ?',
      whereArgs: [userId, date, mealType],
    );
  }

  Future<Map<String, Map<String, String>>> getMealPlans(
    int userId,
    String startDate,
    String endDate,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'meal_plans',
      where: 'user_id = ? AND date BETWEEN ? AND ?',
      whereArgs: [userId, startDate, endDate],
    );

    Map<String, Map<String, String>> mealPlans = {};
    for (var map in maps) {
      final date = map['date'] as String;
      final mealType = map['meal_type'] as String;
      final recipeName = map['recipe_name'] as String;

      mealPlans.putIfAbsent(date, () => {});
      mealPlans[date]![mealType] = recipeName;
    }
    return mealPlans;
  }

  Future<void> addToGroceryList(int userId, String ingredient) async {
    final db = await database;
    await db.insert(
      'grocery_lists',
      {
        'user_id': userId,
        'ingredient': ingredient,
        'is_checked': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFromGroceryList(int userId, String ingredient) async {
    final db = await database;
    await db.delete(
      'grocery_lists',
      where: 'user_id = ? AND ingredient = ?',
      whereArgs: [userId, ingredient],
    );
  }

  Future<void> toggleGroceryItem(int userId, String ingredient) async {
    final db = await database;
    await db.rawUpdate('''
      UPDATE grocery_lists 
      SET is_checked = CASE WHEN is_checked = 1 THEN 0 ELSE 1 END
      WHERE user_id = ? AND ingredient = ?
    ''', [userId, ingredient]);
  }

  Future<void> clearCheckedGroceryItems(int userId) async {
    final db = await database;
    await db.delete(
      'grocery_lists',
      where: 'user_id = ? AND is_checked = 1',
      whereArgs: [userId],
    );
  }

  Future<List<Map<String, dynamic>>> getGroceryList(int userId) async {
    final db = await database;
    return await db.query(
      'grocery_lists',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'is_checked, ingredient',
    );
  }

  Future<void> toggleFavoriteRecipe(int userId, String recipeName) async {
    final db = await database;
    final List<Map<String, dynamic>> existing = await db.query(
      'favorites',
      where: 'user_id = ? AND recipe_name = ?',
      whereArgs: [userId, recipeName],
    );

    if (existing.isEmpty) {
      await db.insert('favorites', {
        'user_id': userId,
        'recipe_name': recipeName,
      });
    } else {
      await db.delete(
        'favorites',
        where: 'user_id = ? AND recipe_name = ?',
        whereArgs: [userId, recipeName],
      );
    }
  }

  Future<List<String>> getFavoriteRecipes(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => maps[i]['recipe_name'] as String);
  }

  Future<bool> isFavoriteRecipe(int userId, String recipeName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'user_id = ? AND recipe_name = ?',
      whereArgs: [userId, recipeName],
    );
    return maps.isNotEmpty;
  }

  Future<void> clearUserData(int userId) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('meal_plans', where: 'user_id = ?', whereArgs: [userId]);
      await txn.delete('favorites', where: 'user_id = ?', whereArgs: [userId]);
      await txn.delete('grocery_lists', where: 'user_id = ?', whereArgs: [userId]);
    });
  }

  Future<Map<String, dynamic>> getAllUserData(int userId) async {
    final db = await database;
    
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1).toIso8601String().split('T').first;
    final endDate = DateTime(now.year, now.month + 1, 0).toIso8601String().split('T').first;
    
    final mealPlansData = await db.query(
      'meal_plans',
      where: 'user_id = ? AND date BETWEEN ? AND ?',
      whereArgs: [userId, startDate, endDate],
    );

    final favoritesData = await db.query(
      'favorites',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    final groceryListData = await db.query(
      'grocery_lists',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return {
      'meal_plans': mealPlansData,
      'favorites': favoritesData,
      'grocery_list': groceryListData,
    };
  }
}