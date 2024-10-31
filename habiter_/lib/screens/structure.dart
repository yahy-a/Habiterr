import 'package:flutter_svg/svg.dart';
import 'package:habiter_/screens/analytics.dart';
import 'package:habiter_/screens/home/add.dart';
import 'package:habiter_/screens/home/home.dart';
import 'package:habiter_/screens/settingsRel/settings.dart';
import 'package:habiter_/screens/streak.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habiter_/providers/habit_provider.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
    final List<Widget> _pages = [
    const HomeCont(),        // Your current home page content
    const SettingsScreen(),       // Settings page        // Empty container for FAB
    const AnalyticsScreen(),     // Statistics page
    const StreakScreen(),        // Profile page
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) => Scaffold(
        backgroundColor: Color(0xFF1E1E1E),
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: _buildBottomNavBar(),
        floatingActionButton: _selectedIndex == 0 ? _buildFloatingActionButton() : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomAppBar(
      color: Color(0xFF2A2A2A),
      height: 60, // Explicitly set a reduced height for the BottomAppBar
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavBarItem(Icons.home, 0),
          _buildNavBarItem(Icons.settings, 1),
          if (_selectedIndex == 0) SizedBox(width: 25),
          _buildNavBarItem(Icons.bar_chart, 3),
          _buildNavBarItem(Icons.person, 4),
        ],
      ),
    );
  }
  //   Widget _buildBottomNavBar() {
  //   return BottomAppBar(
  //     color: Color(0xFF2A2A2A),
  //     child: Container(
  //       height: 50,
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           _buildNavBarItem('assets/icons/home.svg', 0),
  //           _buildNavBarItem('assets/icons/settings.svg', 1),
  //           if (_selectedIndex == 0) SizedBox(width: 28),
  //           _buildNavBarItem('assets/icons/analytics.svg', 2),
  //           _buildNavBarItem('assets/icons/streak.svg', 3),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildNavBarItem(IconData icon, int index) {
    return IconButton(
      icon: Icon(icon, size: 30),
      color: _selectedIndex == index ? Colors.purple : Colors.grey[400],
      onPressed: () => _onItemTapped(index),
    );
  }

  //   Widget _buildNavBarItem(String assetName, int index) {
  //   final isSelected = _selectedIndex == index;
  //   return IconButton(
  //     icon: SvgPicture.asset(
  //       assetName,
  //       width: 23,
  //       height: 23,
  //       colorFilter: ColorFilter.mode(
  //         _selectedIndex == 0 
  //             ? Colors.grey[400]!
  //             : (isSelected ? Colors.purple : Colors.grey[100]!),
  //         BlendMode.srcIn,
  //       ),
  //     ),
  //     onPressed: () => _onItemTapped(index),
  //   );
  // }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: Colors.purple,
      elevation: 4,
      shape: CircleBorder(),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => AddHabitPage()));
      },
      child: Icon(Icons.add, size: 32,color: Colors.white,),
    );
  }



  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Add navigation logic here
  }
}
