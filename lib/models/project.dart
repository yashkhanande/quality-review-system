class Employee {
  String name;
  String role;

  Employee({required this.name, required this.role});
}

class ChecklistItem {
  final String category;
  final String description;
  final String type; // "yesno", "text", "number", "file"
  String? answer;
  String? comment;
  List<String> attachments = []; // file paths or URLs

  ChecklistItem({
    required this.category,
    required this.description,
    required this.type,
    this.answer,
    this.comment,
  });
}
final checklistTemplate = [
  ChecklistItem(
    category: "Geometry preparation",
    description: "Is imported geometry correct (units/required data)",
    type: "yesno",
  ),
  ChecklistItem(
    category: "Geometry preparation",
    description: "Required splits for pre- and post-processing",
    type: "yesno",
  ),
  ChecklistItem(
    category: "FE mesh",
    description: "Element quality (As per standards) → Quality report",
    type: "file", // user uploads PDF/image
  ),
  ChecklistItem(
    category: "Material",
    description: "To be verified: E modulus, Poisson coefficient, Shear modulus, Density…",
    type: "text",
  ),
];


class Project {
  String title;
  List<Employee> teamMembers;
  List<ChecklistItem> checklist;

  Project({
    required this.title,
    required this.teamMembers,
    required this.checklist,
  });
}
