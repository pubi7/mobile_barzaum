import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'review_page.dart';

class ScoreHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final users = FirebaseAuth.instance.currentUser;

    if (users == null) {
      return Scaffold(body: Center(child: Text('User not logged in')));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Score History')),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance
                .collection('submissions')
                .where('userId', isEqualTo: users.uid)
                .orderBy('submittedAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No scores found'));
          }

          for (var doc in snapshot.data!.docs) {
            print(
              "submittedAt: ${doc['submittedAt']} (${doc['submittedAt'].runtimeType})",
            );
          }

          final scores = snapshot.data!.docs;

          return ListView.builder(
            itemCount: scores.length,
            itemBuilder: (context, index) {
              final doc = scores[index];
              final data = doc.data() as Map<String, dynamic>;

              final testId = data['testId'] ?? 'Unknown';
              final score = data['score'] ?? 0;
              final total = data['total'] ?? 0;
              final submittedAt = (data['submittedAt'] as Timestamp).toDate();

              return ListTile(
                title: Text('Test: $testId'),
                subtitle: Text('Score: $score / $total'),
                trailing: Text('${submittedAt.toLocal()}'.substring(0, 16)),
                onTap: () {
                  final scoreData = {
                    ...data,
                    'scoreId':
                        doc.id, // Add the document ID in case needed later
                  };
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewPage(scoreData: scoreData),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
