import 'package:atlas_copco/screens/questions_sceen.dart';
import 'package:flutter/material.dart';
import 'dynamic_questions_assigning.dart';

class TeamRoleAssignmentApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Team Role Assignment',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Sample team members (without "Add new")
  final List<String> teamMembers = [
    "Suraj Bansal",
    "Akash Kathe",
    "Suresh Pawar",
    "Sanjay Raut",
    "Archana Chauhan",
    "Jay Mathur",
    "Harish Borkar",
  ];

  // Role assignments - multiple selections allowed
  List<String> selectedTeamLeaders = [];
  List<String> selectedReviewers = [];
  List<String> selectedExecutors = [];

  // Title controller
  final TextEditingController titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(

        title: Text(
          'Atlas Copco Quality Review',
          style: TextStyle(fontWeight: FontWeight.bold , color: Colors.white),
        ),
         backgroundColor: Color(0xff1994b7),

        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Project Title',
                      hintText: 'Enter the project or workflow title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.title),
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Assign Team Members',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Select multiple team members for each role to begin the workflow process',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Role Assignment Cards
            Row(
              children: [
                Expanded(
                  child: _buildMultiSelectRoleCard(
                    title: 'Team Leaders',
                    description:
                    'Oversees the entire process and coordinates team activities',
                    color: Colors.green,
                    selectedMembers: selectedTeamLeaders,
                    onChanged: (selectedList) {
                      setState(() {
                        selectedTeamLeaders = selectedList;
                      });
                    },
                    icon: Icons.supervisor_account,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: _buildMultiSelectRoleCard(
                    title: 'Reviewers',
                    description:
                    'Evaluates work and provides feedback for improvements',
                    color: Colors.blue,
                    selectedMembers: selectedReviewers,
                    onChanged: (selectedList) {
                      setState(() {
                        selectedReviewers = selectedList;
                      });
                    },
                    icon: Icons.rate_review,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: _buildMultiSelectRoleCard(
                    title: 'Executors',
                    description:
                    'Performs tasks and implements required changes',
                    color: Colors.orange,
                    selectedMembers: selectedExecutors,
                    onChanged: (selectedList) {
                      setState(() {
                        selectedExecutors = selectedList;
                      });
                    },
                    icon: Icons.engineering,
                  ),
                ),
              ],
            ),

            SizedBox(height: 40),

            // Assignment Summary
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assignment Summary',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildMultiSummaryRow(
                      'Team Leaders', selectedTeamLeaders, Colors.green),
                  SizedBox(height: 12),
                  _buildMultiSummaryRow(
                      'Reviewers', selectedReviewers, Colors.blue),
                  SizedBox(height: 12),
                  _buildMultiSummaryRow(
                      'Executors', selectedExecutors, Colors.orange),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _clearAssignments,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Clear All',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _canStartWorkflow() ? _startWorkflow : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    _canStartWorkflow() ? Colors.blue[700] : Colors.grey[400],
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Start Workflow',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiSelectRoleCard({
    required String title,
    required String description,
    required Color color,
    required List<String> selectedMembers,
    required ValueChanged<List<String>> onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          SizedBox(height: 16),

          // Multi-select interface
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Text(
                        'Selected: ${selectedMembers.length} members',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  constraints: BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: teamMembers.length + 1, // +1 for "Add new"
                    itemBuilder: (context, index) {
                      if (index == teamMembers.length) {
                        return ListTile(
                          leading: Icon(Icons.add, color: color),
                          title: Text(
                            "Add new member",
                            style: TextStyle(
                                color: color, fontWeight: FontWeight.w500),
                          ),
                          onTap: _showAddMemberDialog,
                        );
                      }

                      final member = teamMembers[index];
                      final isSelected = selectedMembers.contains(member);

                      return CheckboxListTile(
                        dense: true,
                        title: Text(
                          member,
                          style: TextStyle(fontSize: 14),
                        ),
                        value: isSelected,
                        activeColor: color,
                        onChanged: (bool? value) {
                          List<String> updatedList =
                          List.from(selectedMembers);
                          if (value == true) {
                            updatedList.add(member);
                          } else {
                            updatedList.remove(member);
                          }
                          onChanged(updatedList);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Display selected members as chips
          if (selectedMembers.isNotEmpty) ...[
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedMembers.map((member) {
                return Chip(
                  label: Text(
                    member,
                    style: TextStyle(fontSize: 12),
                  ),
                  backgroundColor: color.withOpacity(0.1),
                  labelStyle: TextStyle(color: color),
                  deleteIcon: Icon(Icons.close, size: 16, color: color),
                  onDeleted: () {
                    List<String> updatedList = List.from(selectedMembers);
                    updatedList.remove(member);
                    onChanged(updatedList);
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMultiSummaryRow(
      String role, List<String> assignedMembers, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12),
            Text(
              '$role (${assignedMembers.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Padding(
          padding: EdgeInsets.only(left: 24),
          child: Text(
            assignedMembers.isEmpty
                ? 'No members assigned'
                : assignedMembers.join(', '),
            style: TextStyle(
              fontSize: 14,
              color: assignedMembers.isNotEmpty
                  ? Colors.grey[600]
                  : Colors.grey[500],
            ),
          ),
        ),
      ],
    );
  }

  bool _canStartWorkflow() {
    return selectedTeamLeaders.isNotEmpty &&
        selectedReviewers.isNotEmpty &&
        selectedExecutors.isNotEmpty;
  }

  void _clearAssignments() {
    setState(() {
      selectedTeamLeaders.clear();
      selectedReviewers.clear();
      selectedExecutors.clear();
      titleController.clear();
    });
  }

  void _startWorkflow() {
    if (_canStartWorkflow()) {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => DynamicQuestionsAssigning(
      //       question: "Is imported geometry correct (units/required data)?",
      //       assignedMembers: {
      //         "leaders": selectedTeamLeaders,
      //         "reviewers": selectedReviewers,
      //         "executors": selectedExecutors,
      //         "title": titleController.text.isNotEmpty
      //             ? titleController.text
      //             : "Untitled Project",
      //       },
      //     ),
      //   ),
      // );
      Navigator.push(context, MaterialPageRoute(builder: (context)=>Questions()));
    }
  }


  void _showAddMemberDialog() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add New Member"),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: "Enter member name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty && !teamMembers.contains(newName)) {
                  setState(() {
                    teamMembers.add(newName);
                  });
                }
                Navigator.pop(context);
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }
}

