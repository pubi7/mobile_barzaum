import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReviewPage extends StatelessWidget {
  final Map<String, dynamic> scoreData;

  const ReviewPage({Key? key, required this.scoreData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String testId = scoreData['testId'];
    final Map<String, dynamic> answers = Map<String, dynamic>.from(
      scoreData['answers'] ?? {},
    );

    final int score = scoreData['score'] ?? 0;
    final int total = scoreData['total'] ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text('Review: $testId')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Score: $score / $total',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('tests')
                      .doc(testId)
                      .collection('questions')
                      .orderBy('timestamp')
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No questions found for this test.'),
                  );
                }

                final questions = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final q = questions[index];
                    final qData = q.data() as Map<String, dynamic>;
                    final qId = q.id;

                    final userAnswer = answers[qId] ?? 'No answer';
                    final correctAnswer = qData['correctAnswer'];
                    final isCorrect = userAnswer == correctAnswer;

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Q${index + 1}: ${qData['text']}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your Answer: $userAnswer',
                              style: TextStyle(
                                color: isCorrect ? Colors.green : Colors.red,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              'Correct Answer: $correctAnswer',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
