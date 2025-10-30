import 'package:flutter/material.dart';
import 'login.dart';

void main() {
  runApp(const TeamRoleAssignmentApp());
}

class TeamRoleAssignmentApp extends StatelessWidget {
  const TeamRoleAssignmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Atlas Copco Quality Review',
      home: login(),
      debugShowCheckedModeBanner: false,
    );
  }
}
