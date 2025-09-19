class Question {
  final String category;
  final String text;
  String? answer;
  List<Question> subQuestions; // Nested sub-questions

  Question({
    required this.category,
    required this.text,
    this.answer,
    this.subQuestions = const [],
  });

  Question copyWith({
    String? category,
    String? text,
    String? answer,
    List<Question>? subQuestions,
  }) {
    return Question(
      category: category ?? this.category,
      text: text ?? this.text,
      answer: answer ?? this.answer,
      subQuestions: subQuestions ?? this.subQuestions,
    );
  }
}
