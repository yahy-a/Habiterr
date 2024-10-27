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
  late final HabitProvider _habitProvider;
  List<Habit> _habits = [];

  @override
  void initState() {
    super.initState();
    _habitProvider = Provider.of<HabitProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) => Scaffold(
        backgroundColor: Color(0xFF1E1E1E),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildDatePicker()),
              SliverToBoxAdapter(child: _buildStreakInfo()),
              SliverToBoxAdapter(child: _buildProgressCircle()),
              SliverToBoxAdapter(child: _buildHabitList()),
              SliverToBoxAdapter(child: _buildHabitItem()),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavBar(),
        floatingActionButton: _buildFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello, Sampad',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              Text('Good Evening',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          Icon(Icons.notifications, color: Colors.purple, size: 30),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return SizedBox(
      // margin: EdgeInsets.symmetric(horizontal: 10),

      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          DateTime date = DateTime.now().add(Duration(days: index));
          bool isSelected = date.day == _habitProvider.selectedDate.day;
          bool isCurrentDay = date.day == DateTime.now().day;
          return GestureDetector(
            onTap: () {
              _habitProvider.setSelectedDate(date);
            },
            child: Container(
              width: 60,
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: isSelected
                    ? BorderRadius.vertical(
                        top: Radius.circular(20), bottom: Radius.circular(20))
                    : BorderRadius.circular(10),
                color: isSelected ? Colors.purple : Colors.grey[800],
                border: Border(
                    bottom: BorderSide(
                        color:
                            isCurrentDay ? Colors.purple : Colors.transparent,
                        width: 3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(date.day.toString(),
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(DateFormat('MMMM').format(date).substring(0, 3),
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStreakInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF343A40),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall streak: 121 days',
              style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            Container(
              width: 220,
              height: 2.5,
              margin: EdgeInsets.fromLTRB(6, 2, 0, 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: Colors.white,
              ),
            ),
            Text(
              'Overall best streak: 121 days',
              style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCircle() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: CircularProgressIndicator(
                    value: 0.33,
                    strokeWidth: 10,
                    backgroundColor: Color.fromARGB(220, 231, 216, 255),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                    
                  ),
                ),
                Positioned(
                  top: 42,
                  left: 38,
                  child: Text('33%',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(
                '1 of 3 habits',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
                Text(
                  'completed today!',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 25 ),
        Text(
          "Today's Habits",
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHabitList() {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        return StreamBuilder<List<Habit>>(
          stream: habitProvider.habitsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: SizedBox(),
              );
            } else {
              List<Habit> habits = snapshot.data!;
              return ListView.builder(
                itemCount: habits.length,
                itemBuilder: (context, index) {},
              );
            }
          },
        );
      },
    );
  }

  Widget _buildHabitItem() {
    return Material(
      elevation: 6,
      color: Color.fromARGB(0, 42, 42, 42),
      child: Container(
        margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18.0, 22.0, 0, 12),
                  child: Text(
                    'habit.name',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // habitProvider.updateHabitCompletion(habit.id, !habit.isCompleted);
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 2),
                          color: false ? Colors.purple : Colors.transparent,
                        ),
                        child: false
                            ? Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () {
                        // Add menu functionality here
                      },
                    ),
                  ],
                ),
              ],
            ),
            Container(
              width: 300,
              height: 2,
              color: Colors.white,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Current ',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Icon(
                        Icons.local_fire_department_outlined,
                        color: Colors.white,
                        size: 23,
                      ),
                      Text(
                        ': 0',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Best ',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Icon(
                        Icons.local_fire_department_outlined,
                        color: Colors.white,
                        size: 23,
                      ),
                      Text(
                        ': 0',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
          SizedBox(width: 25),
          _buildNavBarItem(Icons.bar_chart, 3),
          _buildNavBarItem(Icons.person, 4),
        ],
      ),
    );
  }

  Widget _buildNavBarItem(IconData icon, int index) {
    return IconButton(
      icon: Icon(icon, size: 30),
      color: _selectedIndex == index ? Colors.purple : Colors.grey[400],
      onPressed: () => _onItemTapped(index),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: Colors.purple,
      elevation: 4,
      shape: CircleBorder(),
      onPressed: () {

        // Handle FAB tap
      },
      child: Icon(Icons.add, size: 32,color: Colors.white,),
    );
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Add navigation logic here
  }
}
