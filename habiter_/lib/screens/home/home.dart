import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habiter_/models/habit.dart';
import 'package:intl/intl.dart';
import 'package:habiter_/providers/habit_provider.dart';
import 'package:provider/provider.dart';

class HomeCont extends StatefulWidget {
  const HomeCont({super.key});

  @override
  State<HomeCont> createState() => _HomeContState();
}

class _HomeContState extends State<HomeCont> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        // bool isToday = habitProvider.selectedDate.day == DateTime.now().day &&
        //     habitProvider.selectedDate.month == DateTime.now().month &&
        //     habitProvider.selectedDate.year == DateTime.now().year;
        return SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildDatePicker()),
              // isToday? SliverToBoxAdapter(child: _buildStreakInfo()): SliverToBoxAdapter(),
              // isToday
              //     ? SliverToBoxAdapter(child: _buildProgressCircle())
              //     : SliverToBoxAdapter(),
              SliverToBoxAdapter(child: _buildStreakInfo()),
              SliverToBoxAdapter(child: _buildProgressCircle()),
              SliverToBoxAdapter(child: _buildHabitList()),
            ],
          ),
        );
      },
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
    return Container(
      height: 80,
      child: Consumer<HabitProvider>(
        builder: (context, habitProvider, child) => ListView.builder(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            DateTime firstDate = DateTime.now().subtract(Duration(days: 4));
            DateTime date = firstDate.add(Duration(days: index));
            bool isSelected = date.day == habitProvider.selectedDate.day &&
                date.month == habitProvider.selectedDate.month &&
                date.year == habitProvider.selectedDate.year;
            bool isCurrentDay = date.day == DateTime.now().day &&
                date.month == DateTime.now().month &&
                date.year == DateTime.now().year;
            return GestureDetector(
              onTap: () {
                habitProvider.setSelectedDate(date);
              },
              child: Container(
                width: 65,
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isSelected
                        ? [
                            Color.fromARGB(255, 187, 134, 252).withOpacity(0.3),
                            Color.fromARGB(255, 187, 134, 252).withOpacity(0.1),
                          ]
                        : [
                            Color(0xFF2A2A2A),
                            Color(0xFF1F1F1F),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                  border: isCurrentDay
                      ? Border.all(
                          color: Color.fromARGB(255, 187, 134, 252)
                              .withOpacity(0.5),
                          width: 1.5,
                        )
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      date.day.toString(),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      DateFormat('MMM').format(date),
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStreakInfo() {
    return Container(
      margin: EdgeInsets.all(12),
      child: Consumer<HabitProvider>(
        builder: (context, habitProvider, child) =>
            FutureBuilder<Map<String, int>>(
          future: Future.wait([
            habitProvider.getOverallStreak(),
            habitProvider.getOverallBestStreak()
          ]).then((values) => {'streak': values[0], 'bestStreak': values[1]}),
          builder: (context, snapshot) {
            final streakData = snapshot.data ?? {'streak': 0, 'bestStreak': 0};

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2A2A2A),
                    Color(0xFF1F1F1F),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Color.fromARGB(255, 187, 134, 252).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: Color.fromARGB(255, 187, 134, 252),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Streak',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${streakData['streak']} days',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    height: 30,
                    width: 1,
                    color: Color.fromARGB(255, 187, 134, 252).withOpacity(0.2),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        color: Colors.amber,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Best Streak',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${streakData['bestStreak']} days',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressCircle() {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 140,
                      width: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF2A2D3E),
                            Color(0xFF1F1F1F),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 130,
                      width: 130,
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeInOutCubic,
                        tween: Tween<double>(
                          begin: 0,
                          end: habitProvider.progressValue,
                        ),
                        builder: (context, value, _) =>
                            CircularProgressIndicator(
                          value: value,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey[800],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color.fromARGB(255, 187, 134, 252),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 1500),
                          curve: Curves.easeInOutCubic,
                          tween: Tween<double>(
                            begin: 0,
                            end: habitProvider.progressValue,
                          ),
                          builder: (context, value, _) => Text(
                            '${(value * 100).toInt()}%',
                            style: GoogleFonts.rajdhani(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        Text(
                          'PROGRESS',
                          style: GoogleFonts.rajdhani(
                            color: Colors.grey[400],
                            fontSize: 12,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2A2D3E),
                      Color(0xFF1F1F1F),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${habitProvider.progress}/${habitProvider.total}',
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'COMPLETED',
                      style: GoogleFonts.rajdhani(
                        color: Colors.grey[400],
                        fontSize: 14,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHabitList() {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        bool isToday = habitProvider.selectedDate.day == DateTime.now().day &&
            habitProvider.selectedDate.month == DateTime.now().month &&
            habitProvider.selectedDate.year == DateTime.now().year;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title Section
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color.fromARGB(255, 187, 134, 252).withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "${isToday ? "Today's" : "Scheduled"} Habits",
                style: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            SizedBox(height: 16), // Add spacing between title and list
            // Habits List
            StreamBuilder<List<Habit>>(
              stream: habitProvider.habitsStream,
              builder: (context, snapshot) {
                print('StreamBuilder state: ${snapshot.connectionState}');
                print('StreamBuilder data length: ${snapshot.data?.length}');
                if (snapshot.hasError) {
                  print('StreamBuilder error: ${snapshot.error}');
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    margin: EdgeInsets.all(20),
                    padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF2A2A2A),
                          Color(0xFF1F1F1F),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Color.fromARGB(255, 187, 134, 252).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.add_task_rounded,
                          color: Color.fromARGB(255, 187, 134, 252),
                          size: 48,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No Habits Yet',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start building better habits by adding your first habit',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                List<Habit> habits = snapshot.data!;

                // Move progress calculation to post frame callback
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  int progress = habits
                      .where((habit) =>
                          habit.isCompletedForDate(habitProvider.selectedDate))
                      .length;
                  int total = habits.length;
                  habitProvider.setProgress(progress, total);
                });
                // Disable scrolling in ListView.builder by using NeverScrollableScrollPhysics
                return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    return _buildHabitItem(habits[index]);
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildHabitItem(Habit habit) {
    return Consumer<HabitProvider>(builder: (context, habitProvider, child) {
      bool isToday = habitProvider.selectedDate.day == DateTime.now().day &&
          habitProvider.selectedDate.month == DateTime.now().month &&
          habitProvider.selectedDate.year == DateTime.now().year;
      bool isCompleted = habit.isCompletedForDate(habitProvider.selectedDate);
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isCompleted
                ? [
                    Color(0xFF2E7D32),
                    Color(0xFF1B5E20),
                  ]
                : [
                    Color(0xFF2A2A2A),
                    Color(0xFF1F1F1F),
                  ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      habit.name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Row(
                      children: [
                        if (isToday)
                          GestureDetector(
                            onTap: () async {
                              setState(() {
                                isCompleted = true;
                              });
                              try {
                                final isCurrentlyCompleted =
                                    habit.isCompletedForDate(
                                        habitProvider.selectedDate);
                                final newCompletionStatus =
                                    !isCurrentlyCompleted;
                                await habitProvider.updateHabitCompletion(
                                    habit.id!, newCompletionStatus);
                              } catch (e) {
                                print('Error updating habit completion: $e');
                              }
                            },
                            child: AnimatedContainer(
                              duration: Duration(
                                  milliseconds:
                                      100), // Reduced from 200ms to 100ms
                              curve: Curves.easeInOut,
                              width: 28,
                              height: 28,
                              margin: EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isCompleted
                                      ? Colors.green[300]!.withOpacity(0.6)
                                      : Colors.white30,
                                  width: 1.5,
                                ),
                                color: isCompleted
                                    ? Colors.green[400]
                                    : Colors.transparent,
                                boxShadow: [
                                  if (isCompleted)
                                    BoxShadow(
                                      color:
                                          Colors.green[400]!.withOpacity(0.3),
                                      spreadRadius: 1,
                                    )
                                ],
                              ),
                              child: Center(
                                child: AnimatedSwitcher(
                                  duration: Duration(
                                      milliseconds:
                                          100), // Reduced from 200ms to 100ms
                                  child: isCompleted
                                      ? Icon(Icons.check,
                                          key: ValueKey(true),
                                          size: 16,
                                          color: Colors.white)
                                      : SizedBox(key: ValueKey(false)),
                                ),
                              ),
                            ),
                          ),
                        IconButton(
                          icon: Icon(
                            Icons.more_horiz,
                            color: Colors.white60,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                height: 1,
                margin: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white24,
                      Colors.transparent
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        habit.detail,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.orange.shade400,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${habit.currentStreak}',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
