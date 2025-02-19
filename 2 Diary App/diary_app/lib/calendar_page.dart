import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage(
      {super.key,
      required this.notes,
      required this.feelings,
      required this.showNoteDetails});

  final List<Map<String, dynamic>> notes;
  final Map<String, String> feelings;
  final Function(Map<String, dynamic> note) showNoteDetails;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  List<Map<String, dynamic>> get _filteredNotes {
    return widget.notes.where((note) {
      DateTime noteDate;
      if (note['date'] is String) {
        noteDate = DateTime.parse(note['date']);
      } else if (note['date'] is DateTime) {
        noteDate = note['date'];
      } else {
        return false;
      }

      return isSameDay(noteDate, _selectedDay);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Card.filled(
              color: Colors.white,
              child: TableCalendar(
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Card.filled(
                color: Colors.white,
                child: _filteredNotes.isNotEmpty
                    ? ListView.builder(
                        itemCount: _filteredNotes.length,
                        itemBuilder: (context, index) {
                          final note = _filteredNotes[index];
                          return ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 22),
                            title: Text(
                              note['title'],
                              style:
                                  TextStyle(fontSize: 20, color: Colors.black),
                            ),
                            trailing: Text(
                              widget.feelings[note['feeling']] ??
                                  note['feeling'],
                              style: TextStyle(fontSize: 22),
                            ),
                            onTap: () => widget.showNoteDetails(note),
                          );
                        },
                      )
                    : const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            "No notes for this day",
                            style: TextStyle(
                                fontSize: 16, color: Color(0xFF222222)),
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
