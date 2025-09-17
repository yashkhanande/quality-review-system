import 'package:flutter/material.dart';
import 'package:atlas_copco/models/project.dart'; // import the models
import 'self_review.dart'; // next screen

class Execution extends StatefulWidget {
  const Execution({super.key});

  @override
  State<Execution> createState() => _ExecutionState();
}

class _ExecutionState extends State<Execution> {
  final List<String> employees = [
    "Suraj Bansal",
    "Akash Kathe",
    "Suresh Pawar",
    "Sanjay Raut",
    "Archana Chauhan",
    "Jay Mathur",
    "Harish Borkar",
    "Add new",
  ];

  final List<String> roles = [
    "Team Leader",
    "Reviewer",
    "Team Member",
    "Service Delivery Head",
  ];

  final List<Employee> selectedEmployees = [];
  final TextEditingController _projectController = TextEditingController();

  void _showAddEmployeeDialog({String? preSelected}) {
    String? selectedEmployee = preSelected;
    String? selectedRole;
    final TextEditingController nameController = TextEditingController();

    if (preSelected == "Add new") {
      selectedEmployee = null;
    } else if (preSelected != null) {
      selectedEmployee = preSelected;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Assign Employee"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (preSelected == "Add new" || preSelected == null)
                  TextField(
                    controller: nameController,
                    decoration:
                    const InputDecoration(labelText: "Employee Name"),
                  ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  hint: const Text("Select Role"),
                  items: roles
                      .map((r) =>
                      DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (value) {
                    setStateDialog(() => selectedRole = value);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel")),
              ElevatedButton(
                  onPressed: () {
                    final name = preSelected == "Add new"
                        ? nameController.text
                        : selectedEmployee;
                    if (name != null &&
                        name.isNotEmpty &&
                        selectedRole != null) {
                      setState(() {
                        selectedEmployees
                            .add(Employee(name: name, role: selectedRole!));
                        if (preSelected == "Add new") {
                          employees.insert(employees.length - 1, name);
                        }
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Add"))
            ],
          );
        });
      },
    );
  }

  void _proceed() {
    if (_projectController.text.isEmpty || selectedEmployees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Please add Project title and Team members",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red.shade200,
        ),
      );
    } else {
      final project = Project(
        title: _projectController.text,
        teamMembers: selectedEmployees,
        checklist: [],
      );

      // Navigate to Self Review screen with project data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelfReviewScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Start Project",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _projectController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.task),
                  hintText: "Project Title",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  labelText: "Select Employee",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                hint: const Text("Choose Employee"),
                items: employees
                    .map((e) =>
                    DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    _showAddEmployeeDialog(preSelected: value);
                  }
                },
              ),
              const SizedBox(height: 20),
              Wrap(
                runSpacing: 8,
                spacing: 8,
                children: selectedEmployees
                    .map((e) => Chip(
                  label: Text("${e.name} - ${e.role}"),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () {
                    setState(() {
                      selectedEmployees.remove(e);
                    });
                  },
                ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _proceed,
                child: const Text("Proceed → Self Review"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
