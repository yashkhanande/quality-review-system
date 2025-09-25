import 'package:flutter/material.dart';
import 'screens/questions_sceen.dart'; // make sure this exists in lib/screens/

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // mutable so we can add new members
  List<String> teamMembers = [
    "Suraj Bansal",
    "Akash Kathe",
    "Suresh Pawar",
    "Sanjay Raut",
    "Archana Chauhan",
    "Jay Mathur",
    "Harish Borkar",
  ];

  List<String> selectedTeamLeaders = [];
  List<String> selectedReviewers = [];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool _canStartWorkflow() =>
      selectedTeamLeaders.isNotEmpty && selectedReviewers.isNotEmpty;

  void _clearAssignments() {
    setState(() {
      selectedTeamLeaders.clear();
      selectedReviewers.clear();
      titleController.clear();
    });
  }

  void _startWorkflow() {
    if (!_canStartWorkflow()) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionsScreen(
          projectTitle: titleController.text.isNotEmpty
              ? titleController.text
              : "Untitled Project",
          leaders: selectedTeamLeaders,
          reviewers: selectedReviewers,
          executors: [], // not needed, but kept for compatibility
        ),
      ),
    );
  }

  void _showAddMemberDialog() {

    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Add New Member"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "Enter member name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty && !teamMembers.contains(newName)) {
                  setState(() => teamMembers.add(newName));
                }
                Navigator.pop(ctx);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRoleSection(
      String title,
      Color color,
      List<String> selectedMembers,
      ValueChanged<List<String>> onChanged,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 10),

          // member checkboxes
          ...teamMembers.map((member) {
            final isSelected = selectedMembers.contains(member);
            return CheckboxListTile(
              value: isSelected,
              title: Text(member),
              activeColor: color,
              onChanged: (v) {
                final updated = List<String>.from(selectedMembers);
                if (v == true) {
                  updated.add(member);
                } else {
                  updated.remove(member);
                }
                onChanged(updated);
              },
            );
          }),

          // add new member row
          ListTile(
            leading: Icon(Icons.add, color: color),
            title: Text("Add new member",
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w600)),
            onTap: _showAddMemberDialog,
          ),

          // chips for selected members
          if (selectedMembers.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedMembers.map((member) {
                return Chip(
                  label: Text(member, style: const TextStyle(fontSize: 12)),
                  backgroundColor: color.withOpacity(0.15),
                  labelStyle: TextStyle(color: color),
                  deleteIcon: Icon(Icons.close, size: 16, color: color),
                  onDeleted: () {
                    final updated = List<String>.from(selectedMembers);
                    updated.remove(member);
                    onChanged(updated);
                  },
                );
              }).toList(),
            ),
          ]
        ],
      ),
    );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Atlas Copco Quality Review",style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white
        ),),
        backgroundColor: const Color(0xff1994b7),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Project title
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Project Title",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller:  descriptionController,
              decoration: InputDecoration(
                labelText: "Descriptions",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Row with 2 role cards
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildRoleSection(
                    "Team Leaders",
                    Colors.green,
                    selectedTeamLeaders,
                        (list) => setState(() => selectedTeamLeaders = list),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildRoleSection(
                    "Reviewers",
                    Colors.blue,
                    selectedReviewers,
                        (list) => setState(() => selectedReviewers = list),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: _clearAssignments,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: const Text("Clear All"),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _canStartWorkflow() ? _startWorkflow : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                _canStartWorkflow() ? Colors.blue : Colors.grey,
              ),
              child: const Text("Start Workflow"),
            ),
          ],
        ),
      ),
    );
  }
}
