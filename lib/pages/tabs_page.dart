import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'myAI_page.dart';
import 'storage_page.dart';
import 'calendar_page.dart';
import 'scanner_barcode_page.dart';
import 'account_page.dart';

class TabsPage extends StatefulWidget {
  const TabsPage({super.key});

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {

  int _selectedIndex = 0;

  static const _widgets = [StoragePage(), MyAIPage(), CalendarPage(),
                            ScannerBarcodePage(), AccountPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgets.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(240, 255, 213, 63),
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_cart_outlined), label: 'Storage'.tr()),
          const BottomNavigationBarItem(
              icon: Icon(Icons.chat), label: 'MyAI'),
          BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_month_outlined), label: 'Calendar'.tr()),
          const BottomNavigationBarItem(
              icon: Icon(Icons.document_scanner_outlined), label: 'Scan'),
          BottomNavigationBarItem(
              icon: const Icon(Icons.account_circle_rounded), label: 'Profile'.tr()),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
