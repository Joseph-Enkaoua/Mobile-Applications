import 'package:diary_app/note_form.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage(
      {super.key,
      required this.ref,
      required this.notes,
      required this.feelings,
      required this.feelingPercentages,
      required this.showNoteDetails});

  final DatabaseReference ref;
  final Map<String, String> feelings;
  final List<Map<String, dynamic>> notes;
  final Map<String, double> feelingPercentages;
  final Function(Map<String, dynamic> note) showNoteDetails;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _formatNoteDate(dynamic dateValue) {
    DateTime noteDate;

    if (dateValue is String) {
      noteDate = DateTime.parse(dateValue);
    } else if (dateValue is DateTime) {
      noteDate = dateValue;
    } else {
      return "Invalid date";
    }

    DateTime now = DateTime.now();

    bool isToday = noteDate.year == now.year &&
        noteDate.month == now.month &&
        noteDate.day == now.day;

    return isToday
        ? DateFormat('HH:mm').format(noteDate)
        : DateFormat('dd-MM-yyyy').format(noteDate);
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: Column(
        children: [
          // Upper section with pic name & logout btn
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : const AssetImage("assets/images/default-avatar.png")
                            as ImageProvider,
                    backgroundColor: Colors.grey[300],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? "Anonymous User",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E)),
                      ),
                      Text(
                        user?.email ?? "No email found",
                        style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                ),
              ],
            ),
          ),

          // The page body containing notes data
          Expanded(
            child: Column(
              children: [
                if (widget.notes.isNotEmpty)
                  Column(
                    children: [
                      Card.filled(
                        color: Colors.white.withAlpha(160),
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text("Recent notes",
                                  style: TextStyle(
                                      fontSize: 18, color: Color(0xFF222222))),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: widget.notes.length > 2
                                  ? 2
                                  : widget.notes.length,
                              itemBuilder: (context, index) {
                                Map<String, dynamic> note = widget.notes[index];
                                return Card.filled(
                                  color: Colors.white.withAlpha(200),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 22),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          note['title'],
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Color(0xFF222222)),
                                        ),
                                        Text(
                                          "${widget.feelings[note['feeling']] ?? note['feeling']}",
                                          style: TextStyle(fontSize: 22),
                                        ),
                                      ],
                                    ),
                                    subtitle: Text(
                                      _formatNoteDate(note['date']),
                                      style: TextStyle(color: Colors.blueGrey),
                                    ),
                                    onTap: () => widget.showNoteDetails(note),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Card.filled(
                        color: Color(0xFFE0F7FA),
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                "You have ${widget.notes.length} notes",
                                style: TextStyle(
                                    color: Color(0xFF222222), fontSize: 18),
                              ),
                            ),
                            Card.filled(
                                color: Colors.white.withAlpha(140),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: widget.feelingPercentages.entries
                                        .map((entry) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 4),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              widget.feelings[entry.key] ??
                                                  entry.key,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              "${entry.value.toStringAsFixed(0)}%",
                                              style: TextStyle(
                                                fontSize: 17,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ))
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 230),
                    child: Center(
                      child: Text(
                        "You don't have notes yet.\nCreate a note with the button below",
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 20, color: Color(0xFF222222)),
                      ),
                    ),
                  ),
                NoteForm(database: widget.ref),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
