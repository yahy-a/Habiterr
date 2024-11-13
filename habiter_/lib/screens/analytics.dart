import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habiter_/models/habit.dart';
import 'package:habiter_/providers/preferences_service.dart';
import 'package:habiter_/providers/habit_provider.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String selectedTimeframe = 'Week';
  int selectedChartIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        return SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildTimeframeSelector()),
              SliverToBoxAdapter(child: _buildCompletionChart()),
              SliverToBoxAdapter(child: _buildHabitStats()),
              SliverToBoxAdapter(child: _buildTopHabits()),
              SliverToBoxAdapter(child: _buildMonthlyProgress()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final isDarkMode = Provider.of<PreferencesProvider>(context).isDarkMode;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode ? [
                Color(0xFF2A2A2A),
                Color(0xFF1F1F1F),
              ] : [
                Colors.white,
                Colors.grey[100]!,
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
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Analytics',
                style: GoogleFonts.poppins(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDarkMode ? Color.fromARGB(255, 187, 134, 252) : Colors.blue).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: isDarkMode ? Color.fromARGB(255, 187, 134, 252) : Colors.blue,
                  size: 28,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeframeSelector() {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final isDarkMode = Provider.of<PreferencesProvider>(context).isDarkMode;
        return Container(
          height: 60,
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: ['Week', 'Month', '3 Months', 'Year'].map((timeframe) {
              bool isSelected = selectedTimeframe == timeframe;
              return GestureDetector(
                onTap: () => setState(() => selectedTimeframe = timeframe),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isSelected
                          ? isDarkMode
                              ? [Color(0xFF9C27B0), Color(0xFF7B1FA2)]
                              : [Colors.blue, Colors.blue[700]!]
                          : isDarkMode
                              ? [Color(0xFF2A2A2A), Color(0xFF1F1F1F)]
                              : [const Color.fromARGB(255, 239, 237, 237), Colors.grey[100]!,Colors.grey[300]!],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode? Colors.black26: Colors.white,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      timeframe,
                      style: GoogleFonts.poppins(
                        color: isSelected
                            ? Colors.white
                            : isDarkMode
                                ? Colors.white70
                                : Colors.black87,
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildCompletionChart() {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final isDarkMode = Provider.of<PreferencesProvider>(context).isDarkMode;
        return Container(
          height: 300,
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode ? [
                Color(0xFF2A2A2A),
                Color(0xFF1F1F1F),
              ] : [
                Colors.white,
                Colors.grey[100]!,
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
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Completion Rate',
                style: GoogleFonts.poppins(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}%',
                              style: GoogleFonts.poppins(
                                color: isDarkMode ? Colors.white70 : Colors.black54,
                                fontSize: 12,
                              ),
                            );
                          },
                          reservedSize: 40,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][value.toInt()],
                              style: GoogleFonts.poppins(
                                color: isDarkMode ? Colors.white70 : Colors.black54,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          FlSpot(0, 65),
                          FlSpot(1, 70),
                          FlSpot(2, 85),
                          FlSpot(3, 75),
                          FlSpot(4, 80),
                          FlSpot(5, 90),
                          FlSpot(6, 85),
                        ],
                        isCurved: true,
                        color: isDarkMode ? Color.fromARGB(255, 187, 134, 252) : Colors.blue,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: (isDarkMode ? Color.fromARGB(255, 187, 134, 252) : Colors.blue).withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHabitStats() {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final isDarkMode = Provider.of<PreferencesProvider>(context).isDarkMode;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildStatCard(
                'Total Habits',
                '12',
                Icons.list_alt_rounded,
                isDarkMode,
              ),
              SizedBox(width: 12),
              _buildStatCard(
                'Completion Rate',
                '78%',
                Icons.show_chart_rounded,
                isDarkMode,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, bool isDarkMode) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode ? [
              Color(0xFF2A2A2A),
              Color(0xFF1F1F1F),
            ] : [
              Colors.white,
              Colors.grey[100]!,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isDarkMode ? Color.fromARGB(255, 187, 134, 252) : Colors.blue,
              size: 24,
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHabits() {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final isDarkMode = Provider.of<PreferencesProvider>(context).isDarkMode;
        return Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode ? [
                Color(0xFF2A2A2A),
                Color(0xFF1F1F1F),
              ] : [
                Colors.white,
                Colors.grey[100]!,
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
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top Performing Habits',
                style: GoogleFonts.poppins(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),
              _buildTopHabitItem('Morning Meditation', '95%', isDarkMode),
              _buildTopHabitItem('Daily Exercise', '85%', isDarkMode),
              _buildTopHabitItem('Reading', '80%', isDarkMode),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopHabitItem(String name, String completion, bool isDarkMode) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: GoogleFonts.poppins(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: (isDarkMode ? Color.fromARGB(255, 187, 134, 252) : Colors.blue).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              completion,
              style: GoogleFonts.poppins(
                color: isDarkMode ? Color.fromARGB(255, 187, 134, 252) : Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyProgress() {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final isDarkMode = Provider.of<PreferencesProvider>(context).isDarkMode;
        return Container(
          height: 300,
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode ? [
                Color(0xFF2A2A2A),
                Color(0xFF1F1F1F),
              ] : [
                Colors.white,
                Colors.grey[100]!,
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
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly Progress',
                style: GoogleFonts.poppins(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: BarChart(
                  BarChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}%',
                              style: GoogleFonts.poppins(
                                color: isDarkMode ? Colors.white70 : Colors.black54,
                                fontSize: 12,
                              ),
                            );
                          },
                          reservedSize: 40,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                            if (value.toInt() < months.length) {
                              return Text(
                                months[value.toInt()],
                                style: GoogleFonts.poppins(
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                  fontSize: 12,
                                ),
                              );
                            }
                            return Text('');
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      _buildBarGroup(0, 65, isDarkMode),
                      _buildBarGroup(1, 75, isDarkMode),
                      _buildBarGroup(2, 85, isDarkMode),
                      _buildBarGroup(3, 80, isDarkMode),
                      _buildBarGroup(4, 90, isDarkMode),
                      _buildBarGroup(5, 85, isDarkMode),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, bool isDarkMode) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: isDarkMode ? Color.fromARGB(255, 187, 134, 252) : Colors.blue,
          width: 16,
          borderRadius: BorderRadius.circular(4),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 100,
            color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.05),
          ),
        ),
      ],
    );
  }
}