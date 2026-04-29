import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MoaApp());
}

String moneyText(int value) {
  return NumberFormat('#,###').format(value);
}

class MoaApp extends StatelessWidget {
  const MoaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.notoSansKrTextTheme(),
      ),
      home: const HomeScreen(),
    );
  }
}

// 모델
class Goal {
  String title;
  int target;
  int saved = 0;
  List<Task> tasks = [];

  Goal({required this.title, required this.target});
}

class Task {
  String title;
  int price;
  bool done = false;
  String? imagePath;
  DateTime? completedAt;

  Task({required this.title, required this.price});
}

// 홈
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Goal> goals = [];

  final List<List<Color>> goalColors = [
    [Color(0xFF6C63FF), Color(0xFF9C8CFF)],
    [Color(0xFFFF8A65), Color(0xFFFFB74D)],
    [Color(0xFF4DB6AC), Color(0xFF81C784)],
    [Color(0xFF64B5F6), Color(0xFF4FC3F7)],
  ];

  void addGoalDialog() {
    final title = TextEditingController();
    final price = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("새 목표 만들기 ✨"),
              TextField(
                controller: title,
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(hintText: "목표 이름"),
              ),
              TextField(
                controller: price,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  addGoal(title.text, price.text);
                },
                decoration: const InputDecoration(hintText: "금액"),
              ),
              IconButton(
                icon: const Text("➕"),
                onPressed: () {
                  addGoal(title.text, price.text);
                },
              )
            ],
          ),
        );
      },
    );
  }

  void addGoal(String title, String price) {
    if (title.isEmpty || price.isEmpty) return;

    setState(() {
      goals.add(Goal(title: title, target: int.parse(price)));
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MOA")),
      floatingActionButton: FloatingActionButton(
        onPressed: addGoalDialog,
        child: const Icon(Icons.add),
      ),
      body: goals.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.savings,
                  size: 56,
                  color: Color(0xFF6C63FF),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "아직 목표가 없어요",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "작은 행동을 완료할 때마다\n스스로에게 보상을 저금해보세요.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: addGoalDialog,
                icon: const Icon(Icons.add),
                label: const Text("목표 시작하기 🚀"),
              ),
            ],
          ),
        ),
      )
          : ListView.builder(
        itemCount: goals.length,
        itemBuilder: (_, i) {
          final g = goals[i];
          final colors = goalColors[i % goalColors.length];

          return Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(colors: colors),
            ),
            child: ListTile(
              title: Text(
                g.title,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "₩${moneyText(g.saved)} / ₩${moneyText(g.target)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,        // ⭐ 크게
                  fontWeight: FontWeight.w600, // ⭐ 강조
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GoalDetailScreen(
                      goal: g,
                      color: colors[0],
                    ),
                  ),
                ).then((_) => setState(() {}));
              },
            ),
          );
        },
      ),
    );
  }
}

// 상세
class GoalDetailScreen extends StatefulWidget {
  final Goal goal;
  final Color color;

  const GoalDetailScreen({
    super.key,
    required this.goal,
    required this.color,
  });

  @override
  State<GoalDetailScreen> createState() =>
      _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  final picker = ImagePicker();

  void addTaskDialog() {
    final controller = TextEditingController();
    final price = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("할일 추가 ✨"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(hintText: "할일"),
            ),
            TextField(
              controller: price,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                addTask(controller.text, price.text);
              },
              decoration: const InputDecoration(hintText: "금액"),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Text("➕"),
            onPressed: () {
              addTask(controller.text, price.text);
            },
          )
        ],
      ),
    );
  }

  void addTask(String text, String price) {
    if (text.isEmpty || price.isEmpty) return;

    setState(() {
      widget.goal.tasks.add(
        Task(title: text, price: int.parse(price)),
      );
    });

    Navigator.pop(context);
  }

  Future<void> completeTask(int index) async {
    final picked =
    await picker.pickImage(source: ImageSource.camera);

    if (picked == null) return;

    setState(() {
      final t = widget.goal.tasks[index];
      t.done = true;
      t.imagePath = picked.path;
      t.completedAt = DateTime.now();
      widget.goal.saved += t.price;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("₩${moneyText(widget.goal.tasks[index].price)} 저금 완료!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.goal;

    return Scaffold(
      appBar: AppBar(
        title: Text(g.title),
        actions: [
          // ✅ 여기만 추가됨 (History 복구)
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryScreen(goal: g),
                ),
              );
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTaskDialog,
        backgroundColor: widget.color,
        child: const Icon(Icons.add),
      ),
      body: g.tasks.isEmpty
          ? const Center(child: Text("할일을 추가해보세요 ✨"))
          : ListView.builder(
        itemCount: g.tasks.length,
        itemBuilder: (_, i) {
          final t = g.tasks[i];

          return ListTile(
            leading: Icon(
              t.done ? Icons.check_circle : Icons.circle_outlined,
              color: t.done ? widget.color : Colors.grey,
            ),
            title: Text(
              t.title,
              style: TextStyle(
                decoration:
                t.done ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text("₩${moneyText(t.price)}"),
            trailing: IconButton(
              icon: Icon(Icons.camera_alt, color: widget.color),
              onPressed:
              t.done ? null : () => completeTask(i),
            ),
          );
        },
      ),
    );
  }
}

// ✅ 이것도 추가됨 (History 화면)
class HistoryScreen extends StatelessWidget {
  final Goal goal;

  const HistoryScreen({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final list = goal.tasks.where((t) => t.done).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("기록")),
      body: list.isEmpty
          ? const Center(child: Text("기록 없음"))
          : ListView.builder(
        itemCount: list.length,
        itemBuilder: (_, i) {
          final t = list[i];

          return ListTile(
            leading: t.imagePath != null
                ? Image.file(File(t.imagePath!))
                : const Icon(Icons.image),
            title: Text(t.title),
            subtitle: Text(
              t.completedAt
                  ?.toString()
                  .substring(0, 16) ??
                  "",
            ),
          );
        },
      ),
    );
  }
}