import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';


// --- Data Model ---
class Question {
  final String mainQuestion;
  final List<String> subQuestions;

  Question({required this.mainQuestion, required this.subQuestions});
}

// --- Screen ---
class QuestionsScreen extends StatefulWidget {
  final String projectTitle;
  final List<String> leaders;
  final List<String> reviewers;
  final List<String> executors;

  const QuestionsScreen({
    super.key,
    required this.projectTitle,
    required this.leaders,
    required this.reviewers,
    required this.executors,
  });

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  final Map<String, Map<String, dynamic>> answers = {};

  // 🔥 make checklist mutable
  final List<Question> checklist = [
    Question(
      mainQuestion: "Verification",
      subQuestions: [
        "Original BDF available?",
        "Revised input file checked?",
        "Description correct?",
      ],
    ),
    Question(
      mainQuestion: "Geometry Preparation",
      subQuestions: [
        "Is imported geometry correct (units/required data)?",
        "Required splits for pre- and post-processing?",
        "Required splits for bolted joint procedure?",
        "Geometry correctly defeatured?",
      ],
    ),
    Question(
      mainQuestion: "Coordinate Systems",
      subQuestions: ["Is correct coordinate system created and assigned?"],
    ),
    Question(
      mainQuestion: "FE Mesh",
      subQuestions: [
        "Is BDF exported with comments?",
        "Are Components, Properties, LBC, Materials renamed appropriately?",
        "Visual check of FE model (critical locations, transitions)?",
        "Nastran Model Checker run?",
        "Element quality report available?",
      ],
    ),
    Question(
      mainQuestion: "Solid Mesh",
      subQuestions: [
        "Correct element type and properties?",
        "Face of solid elements checked (for internal crack)?",
      ],
    ),
    Question(
      mainQuestion: "Shell Mesh",
      subQuestions: [
        "Free edges handled?",
        "Correct element type and properties?",
        "Shell normals correct?",
        "Shell thickness defined?",
        "Weld thickness/material correctly assigned?",
      ],
    ),
    Question(
      mainQuestion: "Beam Elements",
      subQuestions: [
        "Is the orientation and cross-section correct?",
        "Are correct nodes used to create beam elements?",
        "Number of beam elements appropriate?",
      ],
    ),
    Question(
      mainQuestion: "Rigids (RBE2/RBE3)",
      subQuestions: ["Rigid elements defined correctly?"],
    ),
    Question(
      mainQuestion: "Joints",
      subQuestions: [
        "Bolted joints defined?",
        "Welds defined?",
        "Shrink fit applied?",
        "Merged regions correct?",
      ],
    ),
    Question(
      mainQuestion: "Mass & Weight",
      subQuestions: [
        "Total weight cross-checked with model units?",
        "Point masses defined?",
        "COG location correct?",
        "Connection to model verified?",
      ],
    ),
    Question(
      mainQuestion: "Material Properties",
      subQuestions: [
        "E modulus verified?",
        "Poisson coefficient verified?",
        "Shear modulus verified?",
        "Density verified?",
      ],
    ),
    Question(
      mainQuestion: "Boundary Conditions",
      subQuestions: [
        "Correct DOFs assigned?",
        "Correct coordinate system assigned?",
      ],
    ),
    Question(
      mainQuestion: "Loading",
      subQuestions: [
        "Pressure load applied correctly?",
        "End loads/Total load defined?",
        "Gravity load applied?",
        "Force (point load) applied?",
        "Temperature load applied?",
        "Subcases defined (operating, lifting, wind, seismic, etc.)?",
      ],
    ),
    Question(
      mainQuestion: "Subcases",
      subQuestions: [
        "Subcase I: Definition, load, SPC ID, output request?",
        "Subcase II: Definition, load, SPC ID, output request?",
        "Subcase III: Definition, load, SPC ID, output request?",
        "Subcase IV: Definition, load, SPC ID, output request?",
      ],
    ),
    Question(
      mainQuestion: "Parameters",
      subQuestions: [
        "Param,post,-1 (op2 output)?",
        "Param,prgpst,no?",
        "Param,Ogeom,no?",
        "NASTRAN BUFFSIZE set for large models?",
        "Nastran system(151)=1 for large models?",
      ],
    ),
    Question(
      mainQuestion: "Oloads",
      subQuestions: [
        "Oload verification for Subcase I?",
        "Oload verification for Subcase II?",
        "Oload verification for Subcase III?",
        "Oload verification for Subcase IV?",
      ],
    ),
    Question(
      mainQuestion: "SPC",
      subQuestions: [
        "SPC resultant verified for Subcase I?",
        "SPC resultant verified for Subcase II?",
        "SPC resultant verified for Subcase III?",
      ],
    ),
  ];

  void _submitChecklist() {
    final result = {
      "projectTitle": widget.projectTitle,
      "leaders": widget.leaders,
      "reviewers": widget.reviewers,
      "executors": widget.executors,
      "answers": answers,
    };

    debugPrint("Checklist Submitted: $result");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Checklist submitted successfully!",style: TextStyle(
        fontWeight: FontWeight.bold
      ),)),
    );
  }

  // 🔥 Function to add custom question
  void _addQuestionDialog() {
    final TextEditingController mainQController = TextEditingController();
    final TextEditingController subQController = TextEditingController();
    List<String> subQs = [];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Add New Question"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: mainQController,
                      decoration: const InputDecoration(
                        labelText: "Main Question",
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: subQController,
                      decoration: const InputDecoration(
                        labelText: "Sub Question",
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (subQController.text.trim().isNotEmpty) {
                          setStateDialog(() {
                            subQs.add(subQController.text.trim());
                            subQController.clear();
                          });
                        }
                      },
                      child: const Text("Add Sub Question"),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      children: subQs
                          .map(
                            (q) => Chip(
                              label: Text(q),
                              onDeleted: () {
                                setStateDialog(() => subQs.remove(q));
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (mainQController.text.trim().isNotEmpty) {
                      setState(() {
                        checklist.add(
                          Question(
                            mainQuestion: mainQController.text.trim(),
                            subQuestions: subQs,
                          ),
                        );
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Checklist - ${widget.projectTitle}")),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: checklist.length,
          itemBuilder: (context, index) {
            final question = checklist[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.mainQuestion,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...question.subQuestions.map((subQ) {
                      return SubQuestionCard(
                        subQuestion: subQ,
                        onAnswer: (ans) {
                          setState(() {
                            answers[subQ] = ans;
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: _submitChecklist,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.all(16),
          ),

          child: const Text(
            "Submit Checklist",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addQuestionDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- Sub Question Card ---
class SubQuestionCard extends StatefulWidget {
  final String subQuestion;
  final Function(Map<String, dynamic>) onAnswer;

  const SubQuestionCard({
    super.key,
    required this.subQuestion,
    required this.onAnswer,
  });

  @override
  State<SubQuestionCard> createState() => _SubQuestionCardState();
}

class _SubQuestionCardState extends State<SubQuestionCard> {
  String? selectedOption;
  File? selectedImage;
  final TextEditingController remarkController = TextEditingController();
  Uint8List? _imageBytes;

  void _updateAnswer() {
    widget.onAnswer({
      "answer": selectedOption,
      "remark": remarkController.text,
      "image": _imageBytes,
    });
  }
  Future<void> _pickImage() async {
    final XFile? returnedImage =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (returnedImage != null) {
      final bytes = await returnedImage.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
      _updateAnswer();

    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.subQuestion, style: const TextStyle(fontSize: 14)),
        RadioListTile<String>(
          title: const Text("Yes"),
          value: "Yes",
          groupValue: selectedOption,
          onChanged: (val) {
            setState(() => selectedOption = val);
            _updateAnswer();
          },
        ),
        RadioListTile<String>(
          title: const Text("No"),
          value: "No",
          groupValue: selectedOption,
          onChanged: (val) {
            setState(() => selectedOption = val);
            _updateAnswer();
          },
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: remarkController,
                  onChanged: (val) {
                    _updateAnswer();
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    hintText: "Remark",
                    border: const OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
              ),
              IconButton(onPressed: (
                  ){
                _pickImage();
              }, icon: Icon(Icons.add_a_photo_outlined))
            ],
          ),
        ),
        const SizedBox(height: 12),
        _imageBytes != null ? Image.memory(_imageBytes! ,width: 400,) : Text('Select Image')
      ],
    );
  }
}
