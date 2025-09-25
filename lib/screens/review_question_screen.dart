// import 'package:flutter/material.dart';
// import '../models/question.dart';
//
// class ReviewQuestionScreen extends StatefulWidget {
//   final List<Question> questions;
//   final Map<String, dynamic> assignedMembers;
//
//   const ReviewQuestionScreen({
//     super.key,
//     required this.questions,
//     required this.assignedMembers,
//   });
//
//   @override
//   State<ReviewQuestionScreen> createState() => _ReviewQuestionScreenState();
// }
//
// class _ReviewQuestionScreenState extends State<ReviewQuestionScreen> {
//   final Map<Question, String?> _answers = {};
//   final Map<Question, String?> _otherText = {};
//
//   void _submit() {
//     for (var q in widget.questions) {
//       _saveAnswersRecursively(q);
//     }
//
//     debugPrint("===== Submitted Answers =====");
//     for (var q in widget.questions) {
//       _printAnswers(q);
//     }
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Answers submitted successfully")),
//     );
//   }
//
//   void _saveAnswersRecursively(Question q) {
//     final ans = _answers[q];
//     q.answer = ans == "Other" ? _otherText[q] ?? "No input" : ans;
//     for (var sub in q.subQuestions) {
//       _saveAnswersRecursively(sub);
//     }
//   }
//
//   void _printAnswers(Question q, [String indent = ""]) {
//     debugPrint("$indent${q.text} → ${q.answer}");
//     for (var sub in q.subQuestions) {
//       _printAnswers(sub, "$indent   ");
//     }
//   }
//
//   Widget _buildQuestionCard(Question q, {double indent = 0}) {
//     return Padding(
//       padding: EdgeInsets.only(left: indent, bottom: 8),
//       child: Card(
//         margin: const EdgeInsets.all(4),
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(q.text,
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold, fontSize: 16)),
//                 const SizedBox(height: 8),
//                 RadioListTile<String>(
//                   title: const Text("Yes"),
//                   value: "Yes",
//                   groupValue: _answers[q],
//                   onChanged: (v) => setState(() => _answers[q] = v),
//                 ),
//                 RadioListTile<String>(
//                   title: const Text("No"),
//                   value: "No",
//                   groupValue: _answers[q],
//                   onChanged: (v) => setState(() => _answers[q] = v),
//                 ),
//                 RadioListTile<String>(
//                   title: const Text("Other"),
//                   value: "Other",
//                   groupValue: _answers[q],
//                   onChanged: (v) => setState(() => _answers[q] = v),
//                 ),
//                 if (_answers[q] == "Other")
//                   TextField(
//                     decoration: const InputDecoration(
//                       labelText: "Please specify",
//                       border: OutlineInputBorder(),
//                     ),
//                     onChanged: (v) => _otherText[q] = v,
//                   ),
//                 const SizedBox(height: 8),
//                 // Render sub-questions indented
//                 ...q.subQuestions
//                     .map((sub) => _buildQuestionCard(sub, indent: indent + 20))
//                     .toList(),
//               ]),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final title = widget.assignedMembers['title'] ?? "Untitled Project";
//
//     return Scaffold(
//       appBar: AppBar(title: Text("Review - $title")),
//       body: ListView(
//         padding: const EdgeInsets.all(8),
//         children: widget.questions
//             .map((q) => _buildQuestionCard(q))
//             .toList(),
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(12),
//         child: ElevatedButton(
//           onPressed: _submit,
//           style: ElevatedButton.styleFrom(
//
//             backgroundColor: const Color(0xff1994b7),
//             padding: const EdgeInsets.symmetric(vertical: 16),
//           ),
//           child: const Text("Done",
//               style: TextStyle(color: Colors.white, fontSize: 16)),
//         ),
//       ),
//     );
//   }
// }
