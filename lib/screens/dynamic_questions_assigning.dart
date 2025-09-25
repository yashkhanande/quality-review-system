// import 'package:flutter/material.dart';
// import '../models/question.dart';
// import 'review_question_screen.dart';
//
// class DynamicQuestionsAssigning extends StatefulWidget {
//   final Map<String, dynamic> assignedMembers;
//
//   const DynamicQuestionsAssigning({
//     super.key,
//     required this.assignedMembers,
//   });
//
//   @override
//   State<DynamicQuestionsAssigning> createState() =>
//       _DynamicQuestionsAssigningState();
// }
//
// class _DynamicQuestionsAssigningState
//     extends State<DynamicQuestionsAssigning> {
//   final List<Question> _questions = [];
//   final TextEditingController _mainQuestionController = TextEditingController();
//
//   @override
//   void dispose() {
//     _mainQuestionController.dispose();
//     super.dispose();
//   }
//
//   void _addMainQuestion() {
//     final text = _mainQuestionController.text.trim();
//     if (text.isEmpty) return;
//
//     setState(() {
//       _questions.add(Question(category: 'Custom', text: text));
//       _mainQuestionController.clear();
//     });
//   }
//
//   void _addSubQuestion(Question parent, String text) {
//     if (text.trim().isEmpty) return;
//
//     setState(() {
//       parent.subQuestions.add(
//         Question(category: parent.category, text: text.trim()),
//       );
//     });
//   }
//
//   void _removeQuestion(Question question, {Question? parent}) {
//     setState(() {
//       if (parent == null) {
//         _questions.remove(question);
//       } else {
//         parent.subQuestions.remove(question);
//       }
//     });
//   }
//
//   void _goToReview() {
//     if (_questions.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('No questions to review')),
//       );
//       return;
//     }
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ReviewQuestionScreen(
//           questions: List<Question>.from(_questions),
//           assignedMembers: widget.assignedMembers,
//         ),
//       ),
//     );
//   }
//
//
//   Widget _buildQuestionTile(Question q, {Question? parent}) {
//     return ExpansionTile(
//       title: Text(
//         q.text,
//         style: const TextStyle(fontWeight: FontWeight.bold),
//       ),
//       subtitle: Text(q.category),
//       children: [
//         ...q.subQuestions.map(
//               (sub) => Padding(
//             padding: const EdgeInsets.only(left: 24.0),
//             child: _buildQuestionTile(sub, parent: q),
//           ),
//         ),
//         Row(
//           children: [
//             IconButton(
//               icon: const Icon(Icons.add_circle, color: Colors.green),
//               onPressed: () {
//                 final TextEditingController subController = TextEditingController();
//
//                 showDialog(
//                   context: context,
//                   builder: (_) {
//                     return AlertDialog(
//                       title: const Text("Add Sub-Question"),
//                       content: TextField(
//                         controller: subController,
//                         decoration: const InputDecoration(
//                           labelText: "Sub-question",
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       actions: [
//                         TextButton(
//                           child: const Text("Cancel"),
//                           onPressed: () => Navigator.pop(context),
//                         ),
//                         ElevatedButton(
//                           child: const Text("Add question"),
//                           onPressed: () {
//                             final text = subController.text.trim();
//                             if (text.isNotEmpty) {
//                               setState(() {
//                                 _addSubQuestion(q, text);
//                               });
//                             }
//                             Navigator.pop(context);
//                           },
//                         ),
//                       ],
//                     );
//                   },
//                 );
//               },
//             ),
//
//             IconButton(
//               icon: const Icon(Icons.delete, color: Colors.red),
//               onPressed: () => _removeQuestion(q, parent: parent),
//             ),
//           ],
//         )
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final title = widget.assignedMembers['title'] ?? 'Untitled Project';
//
//     return Scaffold(
//       appBar: AppBar(title: Text('Create Checklist - $title')),
//       body: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           children: [
//             // Add main question
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _mainQuestionController,
//                     decoration: const InputDecoration(
//                       labelText: 'Add new Checklist',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: _addMainQuestion,
//                   child: const Text('Add'),
//                 )
//               ],
//             ),
//             const SizedBox(height: 12),
//
//
//             // List of questions
//             Expanded(
//               child: ListView(
//                 children:
//                 _questions.map((q) => _buildQuestionTile(q)).toList(),
//               ),
//             ),
//
//             // Go to review
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 ElevatedButton(
//                   onPressed: _goToReview,
//                   child: const Text("Go to Review"),
//                 )
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
