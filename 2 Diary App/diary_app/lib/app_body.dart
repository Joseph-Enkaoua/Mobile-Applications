import 'dart:async';
import 'package:diary_app/calendar_page.dart';
import 'package:diary_app/main.dart';
import 'package:diary_app/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BodyPage extends StatefulWidget {
  const BodyPage({super.key});

  @override
  State<BodyPage> createState() => _BodyPageState();
}

class _BodyPageState extends State<BodyPage> {
  late FirebaseDatabase database;
  late DatabaseReference ref;
  Map<String, double> feelingPercentages = {};
  List<Map<String, dynamic>> notes = [];
  late StreamSubscription<DatabaseEvent> _notesSubscription;

  final Map<String, String> feelings = {
    'happy': '😊',
    'sad': '😢',
    'angry': '😡',
    'excited': '🤩',
    'neutral': '😐',
  };

  @override
  void initState() {
    super.initState();

    database = FirebaseDatabase.instance;

    if (SIM) {
      database.useDatabaseEmulator('localhost', 9000);
    }

    ref = database.ref();

    _getUserNotes();
  }

  @override
  void dispose() {
    _notesSubscription.cancel();
    super.dispose();
  }

  void _calculateFeelingPercentages() {
    if (notes.isEmpty) return;

    Map<String, int> feelingCounts = {
      'happy': 0,
      'sad': 0,
      'angry': 0,
      'excited': 0,
      'neutral': 0,
    };

    for (var note in notes) {
      String feeling = note['feeling'];
      feelingCounts[feeling] = feelingCounts[feeling]! + 1;
    }

    feelingPercentages = feelingCounts
        .map((key, value) => MapEntry(key, (value / notes.length) * 100));

    setState(() {});
  }

  void _getUserNotes() {
    if (FirebaseAuth.instance.currentUser == null) {
      notes = [];
      return;
    }

    try {
      List<Map<String, dynamic>> loadedNotes = [];
      _notesSubscription = ref
          .child('notes')
          .orderByChild('email')
          .equalTo(FirebaseAuth.instance.currentUser?.email)
          .onValue
          .listen((event) {
        if (event.snapshot.value != null) {
          Map<String, dynamic> rawData =
              Map<String, dynamic>.from(event.snapshot.value as Map);

          loadedNotes = rawData.entries.map((entry) {
            Map<String, dynamic> note = Map<String, dynamic>.from(entry.value);
            note['id'] = entry.key;

            if (note['date'] is int) {
              note['date'] = DateTime.fromMillisecondsSinceEpoch(note['date']);
            } else if (note['date'] is String) {
              note['date'] = DateTime.parse(note['date']);
            }

            return note;
          }).toList();

          loadedNotes.sort((a, b) => b['date'].compareTo(a['date']));
        }
        if (mounted) {
          setState(() {
            notes = loadedNotes;
            _calculateFeelingPercentages();
          });
        }
      });
    } catch (e) {
      debugPrint("Error fetching notes: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Failed to load notes",
                style: TextStyle(color: Colors.red))),
      );
    }
  }

  Future<void> _deleteNote(Map<String, dynamic> note) async {
    try {
      await ref.child('notes').child(note['id']).remove();

      _getUserNotes();

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error deleting note: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Failed to delete note",
                  style: TextStyle(color: Colors.red))),
        );
      }
    }
  }

  void _showNoteDetails(Map<String, dynamic> note) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  DateFormat('EEEE, MMMM d, y').format(note['date']),
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(note['title']),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Feeling: ${feelings[note['feeling']] ?? note['feeling']}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 15),
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 0,
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  child: Text(
                    note['content'],
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => _deleteNote(note),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('DELETE'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CLOSE'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: TabBarView(
          children: [
            ProfilePage(
              ref: ref,
              notes: notes,
              feelings: feelings,
              feelingPercentages: feelingPercentages,
              showNoteDetails: _showNoteDetails,
            ),
            CalendarPage(
              notes: notes,
              feelings: feelings,
              showNoteDetails: _showNoteDetails,
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: TabBar(
            dividerColor: Colors.transparent,
            tabs: [
              Tab(icon: Icon(Icons.person)),
              Tab(icon: Icon(Icons.calendar_today)),
            ],
          ),
        ),
      ),
    );
  }
}
