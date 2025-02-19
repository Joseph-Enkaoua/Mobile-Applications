import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NoteForm extends StatelessWidget {
  const NoteForm({super.key, required this.database});

  final DatabaseReference database;

  Future<bool> checkUserAndConnection() async {
    try {
      List<ConnectivityResult> connectivityResults =
          await Connectivity().checkConnectivity();

      return FirebaseAuth.instance.currentUser != null &&
          connectivityResults
              .any((result) => result != ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  void _showForm(BuildContext context) {
    String title = '';
    String content = '';
    String feeling = 'happy';

    final Map<String, String> feelings = {
      'happy': '😊',
      'sad': '😢',
      'angry': '😡',
      'excited': '🤩',
      'neutral': '😐',
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(25),
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(35),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(bottom: 25),
                            child: Text(
                              "Add a new note",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          TextField(
                            maxLength: 28,
                            decoration: InputDecoration(
                              labelText: "Title",
                              labelStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                            ),
                            onChanged: (value) => title = value,
                          ),
                          SizedBox(height: 20),
                          Text("How do you feel?",
                              style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: feelings.entries.map((entry) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    feeling = entry.key;
                                  });
                                },
                                child: CircleAvatar(
                                  backgroundColor: feeling == entry.key
                                      ? Colors.green.shade200
                                      : Colors.transparent,
                                  radius: 22,
                                  child: Text(entry.value,
                                      style: TextStyle(fontSize: 26)),
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 20),
                          TextField(
                            minLines: 6,
                            maxLines: 6,
                            maxLength: 1500,
                            decoration: InputDecoration(
                              labelText: "Text",
                              labelStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                            ),
                            onChanged: (value) => content = value,
                          ),
                          SizedBox(height: 40),
                          ElevatedButton(
                            onPressed: () async {
                              if (title.isNotEmpty &&
                                  content.isNotEmpty &&
                                  await checkUserAndConnection()) {
                                await database.child('notes').push().set({
                                  'title': title,
                                  'email':
                                      FirebaseAuth.instance.currentUser!.email,
                                  'content': content,
                                  'feeling': feeling,
                                  'date':
                                      DateTime.now().toUtc().toIso8601String(),
                                });

                                if (!context.mounted) return;
                                Navigator.pop(context);
                              } else if (!await checkUserAndConnection()) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("No internet connection",
                                          style: TextStyle(color: Colors.red))),
                                );
                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: Text("Save"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: ElevatedButton(
          onPressed: () => _showForm(context),
          style: ElevatedButton.styleFrom(
              foregroundColor: Color(0xFF00796B),
              backgroundColor: Colors.white),
          child: Text("Create a Note"),
        ),
      ),
    );
  }
}
