import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(const TeamRoleAssignmentApp());
}

class TeamRoleAssignmentApp extends StatelessWidget {
  const TeamRoleAssignmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atlas Copco Quality Review',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// git status
// git add .
// git commit -m "updated"
// git push origin main
