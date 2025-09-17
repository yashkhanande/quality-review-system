import 'package:flutter/material.dart';

class ChecklistItem {
  final String category;
  final String description;
  final String type; // "yesno", "text", "number", "file"
  String? answer;
  String? comment;
  List<String> attachments = [];

  ChecklistItem({
    required this.category,
    required this.description,
    required this.type,
    this.answer,
    this.comment,
  });
}

class SelfReviewScreen extends StatefulWidget {
  const SelfReviewScreen({super.key});

  @override
  State<SelfReviewScreen> createState() => _SelfReviewScreenState();
}

class _SelfReviewScreenState extends State<SelfReviewScreen> {
  final List<ChecklistItem> checklist = [
    ChecklistItem(
      category: "Geometry preparation",
      description: "Is imported geometry correct (units/required data)?",
      type: "yesno",
    ),
    ChecklistItem(
      category: "Geometry preparation",
      description: "Required splits for pre- and post-processing",
      type: "yesno",
    ),
    ChecklistItem(
      category: "FE mesh",
      description: "Element quality (As per standards) → Upload report",
      type: "file",
    ),
    ChecklistItem(
      category: "Material",
      description:
      "To be verified: E modulus, Poisson coefficient, Shear modulus, Density…",
      type: "text",
    ),
  ];

  // Future<void> _pickFile(ChecklistItem item) async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles();
  //   if (result != null) {
  //     setState(() {
  //       item.attachments.add(result.files.single.name); // store filename
  //     });
  //   }
  // }

  void _submit() {
    for (var item in checklist) {
      debugPrint(
          "${item.category} - ${item.description} => ${item.answer ?? 'No Answer'} | Attachments: ${item.attachments.join(", ")}");
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Self-review submitted!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Self Review Checklist")),
      body: ListView.builder(
        itemCount: checklist.length,
        itemBuilder: (context, index) {
          final item = checklist[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.category,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(item.description),
                  const SizedBox(height: 10),

                  // Dynamic input type
                  if (item.type == "yesno")
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text("Yes"),
                            value: "Yes",
                            groupValue: item.answer,
                            onChanged: (val) {
                              setState(() => item.answer = val);
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text("No"),
                            value: "No",
                            groupValue: item.answer,
                            onChanged: (val) {
                              setState(() => item.answer = val);
                            },
                          ),
                        ),
                      ],
                    ),
                  if (item.type == "text")
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Enter comments",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => item.answer = val,
                    ),
                  if (item.type == "number")
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Enter number",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => item.answer = val,
                    ),
                  // if (item.type == "file")
                  //   Column(
                  //     children: [
                  //       ElevatedButton.icon(
                  //         icon: const Icon(Icons.attach_file),
                  //         label: const Text("Upload File"),
                  //          onPressed: () => _pickFile(item),
                  //       ),
                  //       if (item.attachments.isNotEmpty)
                  //         Text("Uploaded: ${item.attachments.join(", ")}"),
                  //     ],
                  //   ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton(
          onPressed: _submit,
          child: const Text("Submit Self Review"),
        ),
      ),
    );
  }
}
