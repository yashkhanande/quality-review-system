import 'package:flutter/material.dart';
import '../data/services/upload_service.dart';
import '../data/services/checklist_service.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../utils/paste_helper.dart';
import 'package:dio/dio.dart';

// Upload state types for per-image progress tracking
enum UploadStatus { pending, uploading, success, failed }

class ImageUploadState {
  UploadStatus status;
  double progress; // 0.0..1.0
  CancelToken? cancelToken;

  ImageUploadState({
    this.status = UploadStatus.pending,
    this.progress = 0.0,
    this.cancelToken,
  });
}

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
  // track per-subquestion upload states
  final Map<String, List<ImageUploadState>> uploadStates = {};

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
    _uploadAndSubmit();
  }

  Future<void> _uploadAndSubmit() async {
    final uploadService = UploadService();
    final checklistService = ChecklistService();

    // Copy answers and replace image bytes with uploaded URLs
    final Map<String, dynamic> payload = {
      "projectTitle": widget.projectTitle,
      "leaders": widget.leaders,
      "reviewers": widget.reviewers,
      "executors": widget.executors,
      "answers": {},
    };

    for (final entry in answers.entries) {
      final key = entry.key;
      final map = Map<String, dynamic>.from(entry.value);
      if (map.containsKey('images') && map['images'] is List) {
        final List<dynamic> images = map['images'];
        final List<String> urls = [];
        uploadStates[key] = List.generate(
          images.length,
          (i) => ImageUploadState(),
        );
        int idx = 0;
        for (final imgEntry in images) {
          if (imgEntry is Map && imgEntry['bytes'] is Uint8List) {
            final bytes = imgEntry['bytes'] as Uint8List;
            final srcName = imgEntry['name'] as String?;
            final filename =
                srcName ??
                'upload_${DateTime.now().millisecondsSinceEpoch}_$idx.png';

            final cancelToken = CancelToken();
            try {
              final url = await uploadService.uploadBytesWithProgress(
                bytes,
                filename,
                (sent, total) {
                  setState(() {
                    uploadStates[key]![idx].progress = total > 0
                        ? sent / total
                        : 0.0;
                  });
                },
                cancelToken: cancelToken,
              );
              urls.add(url);
              setState(() {
                uploadStates[key]![idx].status = UploadStatus.success;
              });
            } catch (e) {
              debugPrint('upload failed: $e');
              setState(() {
                uploadStates[key]![idx].status = UploadStatus.failed;
              });
            }
          }
          idx++;
        }
        map['images'] = urls;
      }
      payload['answers'][key] = map;
    }

    try {
      final resp = await checklistService.submitChecklist(payload);
      debugPrint('Checklist submit response: ${resp.statusCode} ${resp.data}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Checklist submitted successfully!",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Checklist submission failed: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Submit failed: $e')));
    }
  }

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
      appBar: AppBar(
        title: Text(
          "Checklist - ${widget.projectTitle}",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: checklist.length,
          itemBuilder: (context, index) {
            final question = checklist[index];
            return Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.blue),
                borderRadius: BorderRadiusGeometry.circular(10),
              ),
              margin: const EdgeInsets.symmetric(vertical: 10),
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
            backgroundColor: Colors.blue,
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
        child: const Icon(Icons.add, color: Colors.white),
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
  final TextEditingController remarkController = TextEditingController();
  // Each image is stored as a map: { 'bytes': Uint8List, 'name': String? }
  List<Map<String, dynamic>> _images = [];
  void _updateAnswer() {
    widget.onAnswer({
      "answer": selectedOption,
      "remark": remarkController.text,
      "images": _images,
    });
  }

  Future<void> _pickImages() async {
    try {
      // Use FilePicker to allow multi-selection on desktop/mobile
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _images = result.files
              .where((f) => f.bytes != null)
              .map((f) => {'bytes': f.bytes!, 'name': f.name})
              .toList();
        });
        _updateAnswer();
      }
    } catch (e) {
      debugPrint('pick images error: $e');
    }
  }

  late DropzoneViewController _dropCtrl;

  // For web/desktop: paste handler could be added later using RawKeyboard/Clipboard APIs

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
        SizedBox(
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
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  _pickImages();
                },
                icon: const Icon(
                  Icons.add_a_photo_outlined,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              // Dropzone area small button to toggle drop support preview
              ElevatedButton(
                onPressed: () async {
                  // open a dialog with a larger drop area on web
                  if (Theme.of(context).platform == TargetPlatform.android ||
                      Theme.of(context).platform == TargetPlatform.iOS) {
                    _pickImages();
                    return;
                  }
                  await showDialog(
                    context: context,
                    builder: (ctx) {
                      PasteSubscription? pasteSub;
                      if (kIsWeb) {
                        pasteSub = addPasteListener((bytes) {
                          setState(
                            () => _images.add({'bytes': bytes, 'name': null}),
                          );
                          _updateAnswer();
                        });
                      }

                      return AlertDialog(
                        title: const Text(
                          'Drop images here or click to pick (paste with Ctrl/Cmd+V)',
                        ),
                        content: SizedBox(
                          width: 600,
                          height: 300,
                          child: DropzoneView(
                            onCreated: (c) => _dropCtrl = c,
                            onLoaded: () => debugPrint('dropzone loaded'),
                            onError: (e) => debugPrint('dropzone error: $e'),
                            onDrop: (ev) async {
                              try {
                                final bytes = await _dropCtrl.getFileData(ev);
                                String? name;
                                try {
                                  name = await _dropCtrl.getFilename(ev);
                                } catch (_) {
                                  name = null;
                                }
                                setState(
                                  () => _images.add({
                                    'bytes': Uint8List.fromList(bytes),
                                    'name': name,
                                  }),
                                );
                                _updateAnswer();
                              } catch (e) {
                                debugPrint('drop processing error: $e');
                              }
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              pasteSub?.cancel();
                              Navigator.pop(ctx);
                            },
                            child: const Text('Close'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              pasteSub?.cancel();
                              await _pickImages();
                              Navigator.pop(ctx);
                            },
                            child: const Text('Pick files'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Drop/Paste'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_images.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              itemBuilder: (context, i) {
                final img = _images[i];
                final bytes = img['bytes'] as Uint8List;
                final name = img['name'] as String?;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.memory(
                          bytes,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _images.removeAt(i);
                            });
                            _updateAnswer();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (name != null)
                        Positioned(
                          left: 4,
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            color: Colors.black45,
                            child: Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
