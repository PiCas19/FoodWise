import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../controllers/storage_controller.dart';
import '../models/food.dart';
import '../models/preferences/user_preferences.dart';
import '../models/storage.dart';
import '../services/appwrite/auth_api.dart';
import '../services/notification_manager.dart';
import '../models/point.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late String? userId;
  final StorageController _storageController = StorageController();
  late Map<DateTime, List<Food>> _events;
  late List<Food> _selectedProducts;
  late DateTime _selectedDay;
  late final ValueNotifier<List<Food>> _selectedEvents;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late int numberOfExpiredProducts = 0;
  late Timer _timer;
  final NotificationManager _notificationManager = NotificationManager();
  late Point points = Point();

  @override
  void initState() {
    super.initState();
    AuthAPI appwrite = context.read<AuthAPI>();
    _selectedProducts = [];
    _events = {};
    _selectedDay = DateTime.now();
    userId = appwrite.currentUser.$id.toString();
    _loadStorages();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
    _notificationManager.initialize();
    _timer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _checkExpiredProducts();
    });
    appwrite.getUserPreferences().then((value) {
      setState(() {
        points = value!.points;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AuthAPI appwrite = context.read<AuthAPI>();
    _selectedProducts = [];
    _events = {};
    _selectedDay = DateTime.now();
    userId = appwrite.currentUser.$id.toString();
    _loadStorages();
    appwrite.getUserPreferences().then((value) {
      setState(() {
        points = value!.points;
      });
    });
  }


  @override
  void dispose() {
    _selectedEvents.dispose();
    _timer.cancel();
    super.dispose();
  }




  Future<void> _loadStorages() async {
    await _storageController.fetchStorages();
    _events = _getEventsFromProducts(_storageController.listStorages ?? []);
    setState(() {});
  }

  Map<DateTime, List<Food>> _getEventsFromProducts(List<Storage> storages) {
    Map<DateTime, List<Food>> events = {};
    for (var storage in storages) {
      if (storage.userId == userId.toString()) {
        for (var product in storage.products) {
          DateTime date = product.expiryDate;
          if (events[date] == null) {
            events[date] = [];
          }
          events[date]!.add(product);
        }
      }
    }

    DateTime today = DateTime.now();
    if (events[today] == null) {
      events[today] = _getEventsForDay(today);
    } else {
      events[today]!.addAll(_getEventsForDay(today));
    }

    return events;
  }




  void _onDaySelected(BuildContext context, DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedProducts = _getEventsForDay(selectedDay);
      _selectedDay = selectedDay;
      _selectedEvents.value = _selectedProducts;
    });
  }

  List<Food> _getEventsForDay(DateTime day) {
    return _events.containsKey(day) ? _events[day]! : [];
  }


  void _checkExpiredProducts() {
    List<Food> expiredProducts = _getExpiredProducts();
    _updateBadge(expiredProducts.length);
    _sendNotifications(expiredProducts);
  }

  List<Food> _getExpiredProducts() {
    DateTime today = DateTime.now();
    return _events.entries
        .where((entry) => entry.key.isBefore(today) || entry.key.isAtSameMomentAs(today))
        .expand((entry) => entry.value)
        .toList();
  }


  void _updateBadge(int count) {
    _notificationManager.updateBadge(count);
  }

  void _sendNotifications(List<Food> expiredProducts) {
    for (var product in expiredProducts) {
      _notificationManager.showNotification('Expired product'.tr(), '${product.name.tr()} ${'has expired'.tr()}');
    }
  }



  Widget _buildDrawer() {
    List<Food> expiredEvents = [];
    _events.forEach((date, events) {
      if (date.isBefore(DateTime.now())) {
        expiredEvents.addAll(events);
      }
    });

    Set<String> uniqueProductNames = {};
    List<Food> uniqueExpiredEvents = [];
    for (var event in expiredEvents) {
      if (!uniqueProductNames.contains(event.name)) {
        uniqueProductNames.add(event.name);
        uniqueExpiredEvents.add(event);
      }
    }

    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(240, 255, 213, 63),
            ),
            child: Text('Notifications'),
          ),
          for (var event in uniqueExpiredEvents)
            ListTile(
              title: Text('${event.name.tr()} x${event.availableQuantity}'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    numberOfExpiredProducts = _events.entries
        .where((entry) => entry.key.isBefore(DateTime.now()))
        .fold<int>(0, (previousValue, entry) => previousValue + entry.value.length,
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Calendar".tr()),
        backgroundColor: const Color.fromARGB(240, 255, 213, 63),
        actions: [
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(points.value.toString(), style: const TextStyle(fontSize: 20)),
                Image.asset('assets/images/icons8-smallcoin.png'),
              ],
            ),
          ),
        ],
        leading: Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            if (numberOfExpiredProducts > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    numberOfExpiredProducts.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
      drawer: _buildDrawer(),
      body: Center(
        child: ColoredBox(
          color: const Color.fromARGB(255, 255, 240, 170),
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _selectedDay,
                selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                onDaySelected: (day, focusedDay) => _onDaySelected(context, day, focusedDay),
                eventLoader: (day) {
                  return _getEventsForDay(day);
                },
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(
                    color: Color.fromARGB(250, 151, 157, 250),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Color.fromARGB(250, 151, 207, 202),
                    shape: BoxShape.rectangle,
                  ),
                  markersMaxCount: 1,
                  markersAlignment: Alignment.bottomCenter,
                  markerMargin: EdgeInsets.symmetric(horizontal: 1),
                  markerDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                  markerSize: 12,
                ),
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: ValueListenableBuilder<List<Food>>(
                  valueListenable: _selectedEvents,
                  builder: (context, value, _) {
                    return ListView.builder(
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ListTile(
                            title: Text('${value[index].name} x${value[index].availableQuantity}'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

