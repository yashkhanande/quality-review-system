import 'package:flutter/material.dart';
import 'screens/dynamic_questions_assigning.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // initial team members
  final List<String> teamMembers = [
    "Suraj Bansal",
    "Akash Kathe",
    "Suresh Pawar",
    "Sanjay Raut",
    "Archana Chauhan",
    "Jay Mathur",
    "Harish Borkar",
  ];

  // multiple selections
  List<String> selectedTeamLeaders = [];
  List<String> selectedReviewers = [];
  List<String> selectedExecutors = [];

  final TextEditingController titleController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  bool _canStartWorkflow() =>
      selectedTeamLeaders.isNotEmpty &&
          selectedReviewers.isNotEmpty &&
          selectedExecutors.isNotEmpty;

  void _clearAssignments() {
    setState(() {
      selectedTeamLeaders.clear();
      selectedReviewers.clear();
      selectedExecutors.clear();
      titleController.clear();
    });
  }

  void _startWorkflow() {
    if (!_canStartWorkflow()) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DynamicQuestionsAssigning(
          assignedMembers: {
            "leaders": selectedTeamLeaders,
            "reviewers": selectedReviewers,
            "executors": selectedExecutors,
            "title": titleController.text.isNotEmpty
                ? titleController.text
                : "Untitled Project",
          },
        ),
      ),
    );

  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 6,
          offset: const Offset(0, 2)),
    ],
  );

  Widget _buildRoleCard({
    required String title,
    required Color color,
    required List<String> selectedMembers,
    required ValueChanged<List<String>> onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(title,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ]),
          const SizedBox(height: 12),
          ...teamMembers.map((m) {
            final isSelected = selectedMembers.contains(m);
            return CheckboxListTile(
              value: isSelected,
              title: Text(m),
              activeColor: color,
              onChanged: (v) {
                final list = List<String>.from(selectedMembers);
                if (v == true) {
                  if (!list.contains(m)) list.add(m);
                } else {
                  list.remove(m);
                }
                onChanged(list);
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String role, List<String> members, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        CircleAvatar(radius: 6, backgroundColor: color),
        const SizedBox(width: 8),
        Expanded(
            child: Text("$role: ${members.isEmpty ? 'None' : members.join(', ')}")),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Atlas Copco Quality Review',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xff1994b7),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: _cardDecoration(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Project Title',
                  hintText: 'Enter the project or workflow title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Assign Team Members',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Select multiple team members for each role to begin the workflow process',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ]),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: _buildRoleCard(
                  title: 'Team Leaders',
                  color: Colors.green,
                  selectedMembers: selectedTeamLeaders,
                  onChanged: (list) => setState(() => selectedTeamLeaders = list),
                  icon: Icons.supervisor_account,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildRoleCard(
                  title: 'Reviewers',
                  color: Colors.blue,
                  selectedMembers: selectedReviewers,
                  onChanged: (list) => setState(() => selectedReviewers = list),
                  icon: Icons.rate_review,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildRoleCard(
                  title: 'Executors',
                  color: Colors.orange,
                  selectedMembers: selectedExecutors,
                  onChanged: (list) => setState(() => selectedExecutors = list),
                  icon: Icons.engineering,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: _cardDecoration(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Assignment Summary',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildSummaryRow('Team Leaders', selectedTeamLeaders, Colors.green),
              _buildSummaryRow('Reviewers', selectedReviewers, Colors.blue),
              _buildSummaryRow('Executors', selectedExecutors, Colors.orange),
            ]),
          ),
          const SizedBox(height: 30),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            ElevatedButton(
              onPressed: _clearAssignments,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[600]),
              child: const Text('Clear All',style: TextStyle(
                color: Colors.white
              ),),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _canStartWorkflow() ? _startWorkflow : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canStartWorkflow() ? Colors.white : Colors.black,
              ),
              child: const Text('Start Workflow',style: TextStyle(color :Colors.black),),
            ),
          ]),
        ]),
      ),
    );
  }
}
