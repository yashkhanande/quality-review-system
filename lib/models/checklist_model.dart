import 'package:flutter/material.dart';

/// A single checklist item (can also contain nested sub-items).
class ChecklistItem {
  final String description;
  final String type; // "yesno", "text", "number", "group"
  String? answer;
  List<ChecklistItem> subItems;

  ChecklistItem({
    required this.description,
    required this.type,
    this.answer,
    this.subItems = const [],
  });
}
