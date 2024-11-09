import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuizPage extends StatefulWidget {
  final String cursoId;
  const QuizPage({Key? key, required this.cursoId}) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  String? userRole;
  List<Map<String, dynamic>> quizzes = [];
  bool isCreatingQuiz = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quizTitleController = TextEditingController();
  List<QuestionForm> questionForms = [QuestionForm()];

  @override
  void initState() {
    super.initState();
    fetchUserRole();
    fetchQuizzes();
  }


  Future<void> editQuiz(Map<String, dynamic> quiz) async {
    setState(() {
      isCreatingQuiz = true;
      _quizTitleController.text = quiz['title'];
      questionForms = (quiz['questions'] as List).map((q) => QuestionForm.fromMap(q)).toList();
    });
  }

  Future<void> deleteQuiz(String quizId) async {
    await FirebaseFirestore.instance
        .collection('cursos')
        .doc(widget.cursoId)
        .collection('quizzes')
        .doc(quizId)
        .delete();
    fetchQuizzes();
  }

  
  Future<void> updateQuiz(String quizId) async {
    if (_formKey.currentState!.validate()) {
      final updatedQuiz = {
        'title': _quizTitleController.text,
        'questions': questionForms.map((qf) => qf.toMap()).toList(),
      };
      await FirebaseFirestore.instance
          .collection('cursos')
          .doc(widget.cursoId)
          .collection('quizzes')
          .doc(quizId)
          .update(updatedQuiz);
      fetchQuizzes();
      setState(() {
        isCreatingQuiz = false;
        questionForms = [QuestionForm()];
        _quizTitleController.clear();
      });
    }
  }

  Future<void> fetchUserRole() async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('usersperm')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();
      if (userDoc.docs.isNotEmpty) {
        setState(() {
          userRole = userDoc.docs.first['rol'];
        });
      }
    }
  }

  Future<void> fetchQuizzes() async {
    final quizzesSnapshot = await FirebaseFirestore.instance
        .collection('cursos')
        .doc(widget.cursoId)
        .collection('quizzes')
        .get();
    setState(() {
      quizzes = quizzesSnapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    });
  }

  Future<void> createQuiz() async {
    if (_formKey.currentState!.validate()) {
      final newQuiz = {
        'title': _quizTitleController.text,
        'questions': questionForms.map((qf) => qf.toMap()).toList(),
      };
      await FirebaseFirestore.instance
          .collection('cursos')
          .doc(widget.cursoId)
          .collection('quizzes')
          .add(newQuiz);
      fetchQuizzes();
      setState(() {
        isCreatingQuiz = false;
        questionForms = [QuestionForm()];
        _quizTitleController.clear();
      });
    }
  }

  Widget buildQuizCreationForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextFormField(
            style: const TextStyle(color: Colors.white),
            controller: _quizTitleController,
            decoration: InputDecoration(
              labelText: 'Título del Quiz', 
              labelStyle: const TextStyle(color: Colors.white),
              enabledBorder: eneableBordT(),
              focusedBorder: focusBordT(Colors.white),
            ),
            validator: (value) => value!.isEmpty ? 'Por favor ingrese un título' : null,
          ),
          const SizedBox(height: 16),
          ...questionForms.asMap().entries.map((entry) {
            int idx = entry.key;
            QuestionForm qf = entry.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pregunta ${idx + 1}', style: TextStyle(color: const Color.fromARGB(255, 153, 118, 2), fontSize: 40.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 25.h),
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  controller: qf.questionController,
                  decoration: InputDecoration(
                    labelText: 'Pregunta',
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: eneableBordT(),
                    focusedBorder: focusBordT(Colors.white),
                  ),
                  validator: (value) => value!.isEmpty ? 'Por favor ingrese una pregunta' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  controller: qf.correctAnswerController,
                  decoration: InputDecoration(
                    labelText: 'Respuesta correcta',
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: eneableBordT(),
                    focusedBorder: focusBordT(Colors.green),
                  ),
                  validator: (value) => value!.isEmpty ? 'Por favor ingrese la respuesta correcta' : null,
                ),
                SizedBox(height: 40.h),
                ...List.generate(3, (index) => Column(
                  children: [
                    TextFormField(
                  style: const TextStyle(color: Colors.white),
                      controller: qf.wrongAnswersControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Respuesta incorrecta ${index + 1}',
                        labelStyle: const TextStyle(color: Colors.white),
                        enabledBorder: eneableBordT(),
                        focusedBorder: focusBordT(Colors.red),
                      ),
                      validator: (value) => value!.isEmpty ? 'Por favor ingrese una respuesta incorrecta' : null,
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),),
                const SizedBox(height: 16),
                if (idx == questionForms.length - 1)
                  ElevatedButton.icon(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(const Color.fromARGB(255, 0, 150, 136)),
                    ),
                    onPressed: () {
                      setState(() {
                        questionForms.add(QuestionForm());
                      });
                    },
                    label: const Text('Añadir otra pregunta', style: TextStyle(color: Colors.white),),
                    icon: const Icon(Icons.add, color: Colors.white,),
                  ),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
          ElevatedButton.icon(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(const Color.fromARGB(255, 153, 118, 2)),
            ),
            onPressed: () {
              if (_quizTitleController.text.isNotEmpty) {
                final quizToUpdate = quizzes.firstWhere(
                  (quiz) => quiz['title'] == _quizTitleController.text,
                  orElse: () => <String, dynamic>{},
                );
                if (quizToUpdate.isNotEmpty) {
                  updateQuiz(quizToUpdate['id']);
                } else {
                  createQuiz();
                }
              } else {
                createQuiz();
              }
            },
            label: Text(_quizTitleController.text.isNotEmpty ? 'Actualizar Quiz' : 'Crear Quiz', style: const TextStyle(color: Colors.white),),
            icon: Icon(_quizTitleController.text.isNotEmpty ? Icons.update : Icons.check, color: Colors.white,),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder focusBordT(Color colorBorder) {
    return OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: colorBorder),
            );
  }

  OutlineInputBorder eneableBordT() {
    return const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.white),
            );
  }

  Widget buildQuizList() {
    return ListView.builder(
      itemCount: quizzes.length,
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        return Card(
          child: ListTile(
            title: Text(quiz['title']),
            subtitle: Text('${(quiz['questions'] as List).length} preguntas'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => QuizTakingPage(quiz: quiz),
              ),
            ),
            trailing: userRole == 'Profesor'
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => editQuiz(quiz),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Eliminar Quiz'),
                            content: const Text('¿Estás seguro de que quieres eliminar este quiz?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  deleteQuiz(quiz['id']);
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : null,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF425C5A),
      appBar: AppBar(
        title: const Text('Quiz', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF425C5A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          if (userRole == 'Profesor' || userRole == 'Administrador' && !isCreatingQuiz)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(const Color.fromARGB(255, 153, 118, 2)),
                ),
                onPressed: () => setState(() {
                  isCreatingQuiz = true;
                  _quizTitleController.clear();
                  questionForms = [QuestionForm()];
                }),
                label: const Text('Crear Nuevo Quiz', style: TextStyle(color: Colors.white),),
                icon: const Icon(Icons.add, color: Colors.white,),
              ),
            ),
          Expanded(
            child: isCreatingQuiz ? buildQuizCreationForm() : buildQuizList(),
          ),
        ],
      ),
    );
  }
}

class QuestionForm {
  final TextEditingController questionController = TextEditingController();
  final TextEditingController correctAnswerController = TextEditingController();
  final List<TextEditingController> wrongAnswersControllers = 
    List.generate(3, (index) => TextEditingController());

  QuestionForm();

  QuestionForm.fromMap(Map<String, dynamic> map) {
    questionController.text = map['question'];
    correctAnswerController.text = map['correctAnswer'];
    for (int i = 0; i < 3; i++) {
      wrongAnswersControllers[i].text = map['wrongAnswers'][i];
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'question': questionController.text,
      'correctAnswer': correctAnswerController.text,
      'wrongAnswers': wrongAnswersControllers.map((controller) => controller.text).toList(),
    };
  }
}

class QuizTakingPage extends StatefulWidget {
  final Map<String, dynamic> quiz;

  const QuizTakingPage({super.key, required this.quiz});

  @override
  _QuizTakingPageState createState() => _QuizTakingPageState();
}

class _QuizTakingPageState extends State<QuizTakingPage> {
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  late List<String> shuffledAnswers;
  Map<String, Color> buttonColors = {};

  @override
  void initState() {
    super.initState();
    shuffleAnswers();
  }

  void shuffleAnswers() {
    final currentQuestion = (widget.quiz['questions'] as List)[currentQuestionIndex] as Map<String, dynamic>;
    shuffledAnswers = [currentQuestion['correctAnswer'], ...currentQuestion['wrongAnswers']]..shuffle();
  }

  void answerQuestion(String selectedAnswer) {
    final currentQuestion = (widget.quiz['questions'] as List)[currentQuestionIndex] as Map<String, dynamic>;
    final correctAnswer = currentQuestion['correctAnswer'];
    final isCorrect = selectedAnswer == correctAnswer;

    setState(() {
      buttonColors[selectedAnswer] = isCorrect ? Colors.green : Colors.red;
      buttonColors[correctAnswer] = Colors.green;
    });

    if (isCorrect) {
      correctAnswers++;
    }

    Timer(const Duration(milliseconds: 1000), () {
      if (currentQuestionIndex < (widget.quiz['questions'] as List).length - 1) {
        setState(() {
          currentQuestionIndex++;
          buttonColors.clear();
          shuffleAnswers();
        });
      } else {
        showResults();
      }
    });
  }

  void showResults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resultados del Quiz'),
        content: Text(
          'Has respondido correctamente $correctAnswers de ${(widget.quiz['questions'] as List).length} preguntas.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.quiz['questions'] as List;
    final currentQuestion = questions[currentQuestionIndex] as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: const Color(0xFF425C5A),
      appBar: AppBar(
        title: Text(widget.quiz['title'], style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF425C5A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pregunta ${currentQuestionIndex + 1} de ${questions.length}',
              style: const TextStyle(color: Color.fromARGB(255, 153, 118, 2), fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              currentQuestion['question'],
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ...shuffledAnswers.map((answer) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(buttonColors[answer] ?? Colors.white),
                ),
                onPressed: buttonColors.isEmpty ? () => answerQuestion(answer) : null,
                child: Text(answer, style: const TextStyle(color: Colors.black)),
              ),
            )),
          ],
        ),
      ),
    );
  }
}