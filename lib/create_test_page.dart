import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_question_page.dart';

class CreateTestPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController languageController = TextEditingController();

  void createTest(BuildContext context) async {
    String title = nameController.text.trim();
    String language = languageController.text.trim();

    if (title.isEmpty) return;

    final doc = await FirebaseFirestore.instance.collection('tests').add({
      'title': title,
      'language': language.isNotEmpty ? language : 'Unknown',
      'created_at': Timestamp.now(),
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddQuestionPage(testId: doc.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create or Select Test')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Test Title'),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: languageController,
                  decoration: InputDecoration(labelText: 'Language'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => createTest(context),
                  child: Text('Create New Test'),
                ),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('tests')
                      .orderBy('created_at', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final tests = snapshot.data!.docs;

                if (tests.isEmpty) {
                  return Center(child: Text('No tests found.'));
                }

                return ListView.builder(
                  itemCount: tests.length,
                  itemBuilder: (context, index) {
                    final test = tests[index];
                    final title = test['title'] ?? 'Unnamed Test';
                    final language = test['language'] ?? 'Unknown';

                    return ListTile(
                      title: Text(title),
                      subtitle: Text('Language: $language'),
                      trailing: Icon(Icons.edit),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddQuestionPage(testId: test.id),
                          ),
                        );
                      },
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
