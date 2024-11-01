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
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          height: 65,
          padding: EdgeInsets.zero,
          notchMargin: 8,
          shape: AutomaticNotchedShape(
            RoundedRectangleBorder(),
            CircleBorder(),
          ),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavBarItem(Icons.home_rounded, 0),
                      SizedBox(width: 15),
                      _buildNavBarItem(Icons.settings_rounded, 1),
                    ],
                  ),
                ),
                SizedBox(width: 40), // Consistent space for FAB
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavBarItem(Icons.bar_chart_rounded, 3),
                      SizedBox(width: 15),
                      _buildNavBarItem(Icons.person_rounded, 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavBarItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: EdgeInsets.fromLTRB(4, 0, 4, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isSelected ? LinearGradient(
          colors: [
            Color(0xFF9C27B0).withOpacity(0.8),
            Color(0xFF7B1FA2).withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ) : null,
        boxShadow: isSelected ? [
          BoxShadow(
            color: Color(0xFF9C27B0).withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          )
        ] : null,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 26,
        ),
        color: isSelected 
          ? Colors.white
          : Colors.grey[400],
        onPressed: () => _onItemTapped(index),
        splashColor: Colors.purple.withOpacity(0.3),
        highlightColor: Colors.purple.withOpacity(0.2),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Stack(
      children: [
        // FAB Socket/Background
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.2),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 1,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        // FAB
        Positioned.fill(
          child: Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF9C27B0),
                    Color(0xFF7B1FA2),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF9C27B0).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: CircleBorder(),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AddHabitPage()));
                  },
                  child: Icon(
                    Icons.add,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Add navigation logic here
  }
}
