import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projekakhirpam_124220134/JSON/users.dart';
import 'package:projekakhirpam_124220134/componen/color.dart';
import 'package:projekakhirpam_124220134/views/Profile.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CalendarScreen extends StatefulWidget {
  final Users? profile;
  const CalendarScreen({super.key, this.profile});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<String>> _events = {};
  Set<DateTime> _holidayDates = {}; // Hari libur
  Map<DateTime, String> _holidayDetails = {}; // Detail liburan

  late Timer _timer;
  String _currentTime = '';
  String _selectedTimeZone = 'WIB'; // Default ke WIB

  late DateTime _firstDay;
  late DateTime _lastDay;
  late CalendarFormat _calendarFormat;

  @override
  void initState() {
    _firstDay = DateTime.now().subtract(const Duration(days: 1000));
    _lastDay = DateTime.now().add(const Duration(days: 1000));
    _calendarFormat = CalendarFormat.month;
    super.initState();
    _fetchHolidays();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _updateTime());
  }

  /// Perbarui waktu secara independen dari status kalender
  void _updateTime() {
    final now = DateTime.now().toUtc();
    int offset = 0;

    if (_selectedTimeZone == 'WIB') {
      offset = 7; // UTC+7
    } else if (_selectedTimeZone == 'WITA') {
      offset = 8; // UTC+8
    } else if (_selectedTimeZone == 'WIT') {
      offset = 9; // UTC+9
    } else if (_selectedTimeZone == 'LDN') {
      offset = 0; // UTC+0
    }

    final adjustedTime = now.add(Duration(hours: offset));
    setState(() {
      _currentTime = DateFormat('HH:mm:ss').format(adjustedTime);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// Mengambil data hari libur dari API
  Future<void> _fetchHolidays() async {
    const url =
        'https://raw.githubusercontent.com/guangrei/APIHariLibur_V2/main/holidays.json';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _holidayDates.clear();
          _holidayDetails.clear();

          data.forEach((key, value) {
            if (key != 'info') {
              final date = DateTime.parse(key);
              _holidayDates.add(DateTime(date.year, date.month, date.day));
              _holidayDetails[DateTime(date.year, date.month, date.day)] =
                  value['summary'] ?? '';
            }
          });
        });
      } else {
        print('Failed to fetch holidays: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching holidays: $e');
    }
  }

  /// Menambahkan catatan ke tanggal tertentu
  void _addEvent(String event) {
    setState(() {
      if (_events[_selectedDay] != null) {
        _events[_selectedDay]!.add(event);
      } else {
        _events[_selectedDay] = [event];
      }
    });
  }

  /// Menghapus catatan dari tanggal tertentu
  void _removeEvent(String event) {
    setState(() {
      _events[_selectedDay]?.remove(event);
      if (_events[_selectedDay]?.isEmpty ?? true) {
        _events.remove(_selectedDay);  // Remove the day if no events left
      }
    });
  }

  /// Menampilkan catatan atau hari libur untuk tanggal tertentu
  List<String> _getEventsForDay(DateTime day) {
    final events = _events[day] ?? [];
    if (_holidayDates.contains(DateTime(day.year, day.month, day.day))) {
      final holidayDetail =
          _holidayDetails[DateTime(day.year, day.month, day.day)];
      if (holidayDetail != null) {
        return [holidayDetail, ...events];
      }
    }
    return events;
  }

  /// Menampilkan dialog untuk menambah event
  void _showAddEventDialog() {
    TextEditingController eventController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Tambah Event"),
          content: TextField(
            controller: eventController,
            decoration: const InputDecoration(hintText: "Masukkan event"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Tambah"),
              onPressed: () {
                if (eventController.text.isNotEmpty) {
                  _addEvent(eventController.text);
                  Navigator.of(context).pop();
                }
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
      appBar: AppBar(
        title: const Text(
          'Kalendar Kegiatan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
      ),
       bottomNavigationBar: SizedBox(
        height: 80,
        child: Container(
          color: primaryColor,
          child: Row(
            children: [
              Expanded(
                  child: InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CalendarScreen()));
                },
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //icon home
                    Icon(
                      Icons.home,
                      color: Colors.white,
                    ),
                    Text(
                      'Homepage',
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              )),
              Expanded(
                  child: InkWell(
                onTap: () {
                  showDialog(
                    context: context, 
                    builder: (context) => AlertDialog(
                      actions: [
                        TextButton(
                          onPressed: (){
                            Navigator.of(context).pop();
                          },
                          child: const Text('Close'),
                          )
                      ],
                      title: const Text('Kesan pesan & saran',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold),),
                      contentPadding: const EdgeInsets.all(20),
                      content: const Text('Menurut saya PAM ini memberikan kesan serba otodidak, dan hal itu membuat banyak mahasiswa yang tertantang untuk mengulik dan mencari informasi, termasuk saya. saya jadi lumayan menyukai ngoding walaupun dahulu saya ga suka ngoding. Saran saya mungkin bisa di buka kelas tambahan di luar jam kuliah pak, hehe',
                      textAlign: TextAlign.justify,),
                    ),
                    );
                },
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.help_outline,
                      color: Colors.white,
                    ),
                    Text('Kesan Pesan', style: TextStyle(color: Colors.white))
                  ],
                ),
              )),
              Expanded(
                  child: InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile(profile: widget.profile,)));
                },
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                    Text('Profil', style: TextStyle(color: Colors.white))
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Tampilkan dropdown untuk memilih zona waktu
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Time ($_selectedTimeZone): $_currentTime',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: _selectedTimeZone,
                  items: const [
                    DropdownMenuItem(value: 'WIB', child: Text('WIB')),
                    DropdownMenuItem(value: 'WITA', child: Text('WITA')),
                    DropdownMenuItem(value: 'WIT', child: Text('WIT')),
                    DropdownMenuItem(value: 'LDN', child: Text('LDN')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedTimeZone = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: _firstDay,
            lastDay: _lastDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay; // Hanya perbarui jika hari dipilih
              });
            },
            onPageChanged: (newFocusedDay) {
              setState(() {
                _focusedDay = newFocusedDay;
              });
            },
            eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              weekendTextStyle: TextStyle(color: Colors.red), // Set color for weekends (Sundays)
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: _getEventsForDay(_selectedDay)
                  .map((event) => ListTile(
                        title: Text(event),
                        leading: Icon(
                          _holidayDates.contains(_selectedDay)
                              ? Icons.flag
                              : Icons.event,
                          color: _holidayDates.contains(_selectedDay)
                              ? Colors.red
                              : Colors.blue,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _removeEvent(event);
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        child: const Icon(Icons.add),  // Icon + untuk menambah event
        backgroundColor: primaryColor,
      ),
    );
  }
}
