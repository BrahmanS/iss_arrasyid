import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:iss/Services/jadwal_service.dart';
import 'package:iss/Layout/appbar.dart';
import 'package:iss/Layout/drawer.dart';
import 'package:provider/provider.dart';
import 'package:iss/Provider/user_data_provider.dart';
import 'package:iss/Layout/bottombar.dart';
import 'package:iss/Services/shared_prefs.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> sessions = [];
  bool isLoading = true;

  late final JadwalService _sessionService;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _sessionService = JadwalService();
    _fetchSessions();  // Initial fetch for the current month
  }

  Future<void> _fetchSessions() async {
    try {
      // final userData = Provider.of<UserDataProvider>(context, listen: false).userData;
      // if (userData != null) {
      //   final sessionIdCookie = userData['session_id'];
      //   final sessionId = _extractSessionId(sessionIdCookie);
        final sessionId2 = await SharedPrefs().getSessionIdFromPrefs();
        if (sessionId2 != null) {
          final int month = _focusedDay.month; // Get the current month
          final int year = _focusedDay.year;   // Get the current year

          final response = await _sessionService.getUserSessions(sessionId2, month: month, year: year);

          if (response['status'] == 'success') {
            setState(() {
              sessions = List<Map<String, dynamic>>.from(response['data']);
              isLoading = false;
            });
          }
        } else {
          throw Exception('Session ID is null');
        }
      // } else {
      //   throw Exception('User data is null');
      // }
    } catch (error) {
      print('Error fetching sessions: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  // String? _extractSessionId(String? sessionIdCookie) {
  //   if (sessionIdCookie == null) return null;

  //   try {
  //     final parts = sessionIdCookie.split(';');
  //     for (final part in parts) {
  //       final trimmedPart = part.trim();
  //       if (trimmedPart.startsWith('session_id=')) {
  //         return trimmedPart.split('=')[1];
  //       }
  //     }
  //     return null;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _showScheduleDialog(selectedDay);
  }

  void _onMonthChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
    _fetchSessions();  // Fetch sessions for the new month
  }

  void _showScheduleDialog(DateTime selectedDate) {
    List<Map<String, dynamic>> dailySessions = sessions.where((session) {
      DateTime sessionDate = DateTime.parse(session['start_datetime']);
      return isSameDay(sessionDate, selectedDate);
    }).toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Jadwal untuk ${DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(selectedDate)}'),
          content: dailySessions.isEmpty
              ? Text('Tidak ada jadwal untuk hari ini.')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: dailySessions.map((session) {
                    return ListTile(
                      title: Text(session['subject']),
                      subtitle: Text('${_formatTime(session['start_datetime'])} - ${_formatTime(session['end_datetime'])}'),
                      trailing: Text(session['faculty']),
                    );
                  }).toList(),
                ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: _onDaySelected,
                  onPageChanged: _onMonthChanged,  // Handle month change
                  calendarFormat: CalendarFormat.month,
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month',
                  },
                ),
              ],
            ),
      bottomNavigationBar: CustomBottomBar(),
    );
  }

  String _formatTime(String datetime) {
    final date = DateTime.parse(datetime);
    return DateFormat.Hm().format(date);
  }
}
