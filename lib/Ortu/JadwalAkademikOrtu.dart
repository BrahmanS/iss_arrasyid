import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:iss/Layout/appbarOrtu.dart'; // import custom app bar
import 'package:iss/Layout/bottombarOrtu.dart'; // import custom bottom bar
import 'package:iss/Layout/drawerOrtu.dart';
import 'package:iss/Services/jadwal_service.dart'; // import jadwal service
import 'package:provider/provider.dart';
import 'package:iss/Provider/user_data_provider.dart';
import 'package:iss/Services/shared_prefs.dart';
class CalendarOrtuScreen extends StatefulWidget {
  @override
  _CalendarOrtuScreenState createState() => _CalendarOrtuScreenState();
}

class _CalendarOrtuScreenState extends State<CalendarOrtuScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;

  late final JadwalService _jadwalService;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _jadwalService = JadwalService();
    _loadCalendarEvents();
  }

  void _loadCalendarEvents() async {
    try {
      // final userData = Provider.of<UserDataProvider>(context, listen: false).userData;
      // if (userData != null) {
      //   final sessionIdCookie = userData['session_id'];
      //   final sessionId = _extractSessionId(sessionIdCookie);
      final sessionId2 = await SharedPrefs().getSessionIdFromPrefs();
      if (sessionId2 != null) {
        final events = await _jadwalService.getCalendarEvents(sessionId2);
        setState(() {
          _events = events;
          _isLoading = false;
        });
        print('Loaded events: $_events'); // Log to check loaded events
      } else {
        throw Exception('Session ID is null');
      }
      // } else {
      //   throw Exception('User data is null');
      // }
    } catch (error) {
      print('Failed to load events: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _extractSessionId(String? sessionIdCookie) {
    if (sessionIdCookie == null) return null;

    try {
      final parts = sessionIdCookie.split(';');
      for (final part in parts) {
        final trimmedPart = part.trim();
        if (trimmedPart.startsWith('session_id=')) {
          return trimmedPart.split('=')[1];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    _showEventsDialog(selectedDay);
  }

  void _showEventsDialog(DateTime selectedDay) {
    List<Map<String, dynamic>> dailyEvents = _events.where((event) {
      DateTime eventDate = DateTime.parse(event['start']);
      return isSameDay(eventDate, selectedDay);
    }).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Jadwal untuk ${DateFormat.yMMMd().format(selectedDay)}'),
          content: dailyEvents.isEmpty
              ? Text('Tidak ada jadwal untuk hari ini.')
              : SingleChildScrollView(
                  child: Column(
                    children: dailyEvents.map((event) {
                      return ListTile(
                        title: Text(event['name']),
                        subtitle: Text(event['allday']
                            ? 'Seharian'
                            : '${event['start']} - ${event['stop']}'),
                      );
                    }).toList(),
                  ),
                ),
          actions: [
            TextButton(
              child: Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarortu(),
      drawer: CustomDrawerortu(),
      bottomNavigationBar: CustomBottomBarortu(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  TableCalendar(
                    firstDay: DateTime.utc(2010, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: _onDaySelected,
                    calendarFormat: CalendarFormat.month,
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Month',
                    },
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        for (var event in _events) {
                          if (isSameDay(DateTime.parse(event['start']), day)) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.blue, // Color for days with events
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${day.day}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
