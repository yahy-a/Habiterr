class Habit {
  final String id;
  final String name;
  final String detail;
  bool isCompleted;

  Habit({required this.id, required this.name,this.isCompleted = false, required this.detail});
}