import 'package:flutter/material.dart';
import 'package:recipe_meal/login.dart';
import 'login.dart';
import 'homeScreen.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(), 
    );
  }
}
