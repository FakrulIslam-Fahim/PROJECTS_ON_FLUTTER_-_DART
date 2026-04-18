import 'dart:io';




const String appTitle = "Student Grader v1.0";


final Set<String> availableSubjects = {"Math", "English", "Science", "History"};


var students = <Map<String, dynamic>>[];



void main() {
  // Feature 2: do-while loop — menu runs at least once, exits on option 8
  var running = true;
  do {
    printMenu();
    var input = stdin.readLineSync()?.trim() ?? '';

    // switch statement to route menu options
    switch (input) {
      case '1':
        addStudent();
        break;
      case '2':
        recordScore();
        break;
      case '3':
        addBonus();
        break;
      case '4':
        addComment();
        break;
      case '5':
        viewAllStudents();
        break;
      case '6':
        viewReportCard();
        break;
      case '7':
        classSummary();
        break;
      case '8':
        running = false;
        print('\nGoodbye! 👋');
        break;
      default:
        print('Invalid option. Please choose 1–8.');
    }
  } while (running);
}

// ── Feature 2: Menu (multi-line string + string interpolation) ─────────────────

void printMenu() {
  // Multi-line string using triple quotes
  print('''
╔══════════════════════════════╗
║     $appTitle     ║
╚══════════════════════════════╝

1. Add Student
2. Record Score
3. Add Bonus Points
4. Add Comment
5. View All Students
6. View Report Card
7. Class Summary
8. Exit

Choose an option:''');
}

// ── Feature 3: Add Student ────────────────────────────────────────────────────

void addStudent() {
  stdout.write("Enter student's name: ");
  var name = stdin.readLineSync()?.trim() ?? '';
  if (name.isEmpty) {
    print('Name cannot be empty.');
    return;
  }

  // Map creation with spread operator {...availableSubjects} copies the Set
  var student = <String, dynamic>{
    "name":     name,
    "scores":   <int>[],                // List<int>
    "subjects": {...availableSubjects}, // Set<String> — spread operator
    "bonus":    null,                   // int?   — nullable
    "comment":  null,                   // String? — nullable
  };

  students.add(student);

  // String interpolation
  print('✓ Student "$name" added successfully!');
}

// ── Feature 4: Record Score ───────────────────────────────────────────────────

void recordScore() {
  if (students.isEmpty) { print('No students yet. Add one first.'); return; }

  // Indexed for loop
  for (int i = 0; i < students.length; i++) {
    print('  ${i + 1}. ${students[i]["name"]}');
  }
  stdout.write('Pick a student (number): ');
  var pick = int.tryParse(stdin.readLineSync() ?? '') ?? 0;
  if (pick < 1 || pick > students.length) { print('Invalid choice.'); return; }

  var student = students[pick - 1];
  print('Subjects: ${(student["subjects"] as Set).join(", ")}');
  stdout.write('Enter subject: ');
  var subject = stdin.readLineSync()?.trim() ?? '';
  if (!(student["subjects"] as Set).contains(subject)) {
    print('Not a valid subject.');
    return;
  }

  // while loop — input validation: re-prompts until score is 0–100
  int score = -1;
  while (score < 0 || score > 100) {
    stdout.write('Enter score for $subject (0–100): ');
    score = int.tryParse(stdin.readLineSync() ?? '') ?? -1;
    if (score < 0 || score > 100) print('Score must be between 0 and 100. Try again.');
  }

  (student["scores"] as List<int>).add(score);
  print('✓ Score $score recorded for ${student["name"]} in $subject.');
}

// ── Feature 5: Add Bonus Points ───────────────────────────────────────────────

void addBonus() {
  if (students.isEmpty) { print('No students yet.'); return; }
  _listStudents();
  stdout.write('Pick a student: ');
  var pick = int.tryParse(stdin.readLineSync() ?? '') ?? 0;
  if (pick < 1 || pick > students.length) { print('Invalid choice.'); return; }

  var student = students[pick - 1];
  stdout.write('Enter bonus points (1–10): ');
  var bonus = int.tryParse(stdin.readLineSync() ?? '') ?? 0;
  if (bonus < 1 || bonus > 10) { print('Bonus must be 1–10.'); return; }

  // ??= assigns only if the field is currently null
  student["bonus"] ??= bonus;

  if (student["bonus"] == bonus) {
    print('✓ Bonus of +$bonus added to ${student["name"]}.');
  } else {
    // if-else: bonus was already set
    print('Bonus already set to ${student["bonus"]}. Cannot overwrite.');
  }
}

// ── Feature 6: Add Comment ────────────────────────────────────────────────────

void addComment() {
  if (students.isEmpty) { print('No students yet.'); return; }
  _listStudents();
  stdout.write('Pick a student: ');
  var pick = int.tryParse(stdin.readLineSync() ?? '') ?? 0;
  if (pick < 1 || pick > students.length) { print('Invalid choice.'); return; }

  var student = students[pick - 1];
  stdout.write('Enter comment: ');
  var comment = stdin.readLineSync()?.trim();
  student["comment"] = comment;

  // ?. (null-aware access) + ?? (null fallback)
  String display = (student["comment"] as String?)?.toUpperCase() ?? "No comment provided";
  print('✓ Comment saved: "$display"');
}

// ── Feature 7: View All Students ─────────────────────────────────────────────

void viewAllStudents() {
  if (students.isEmpty) { print('No students yet.'); return; }

  print('\n── All Students ──────────────────');

  // for-in loop
  for (var student in students) {
    // collection if — conditionally include a bonus tag in the list literal
    var tags = [
      student["name"] as String,
      '${(student["scores"] as List).length} scores',
      if (student["bonus"] != null) '★ Has Bonus',
    ];
    print('  ${tags.join(" · ")}');
  }
  print('');
}

// ── Feature 8: View Report Card ───────────────────────────────────────────────

void viewReportCard() {
  if (students.isEmpty) { print('No students yet.'); return; }
  _listStudents();
  stdout.write('Pick a student: ');
  var pick = int.tryParse(stdin.readLineSync() ?? '') ?? 0;
  if (pick < 1 || pick > students.length) { print('Invalid choice.'); return; }

  var student = students[pick - 1];
  var scores   = student["scores"] as List<int>;

  // Arithmetic operators: sum then average
  double rawAvg = 0;
  if (scores.isNotEmpty) {
    int sum = 0;
    for (int i = 0; i < scores.length; i++) sum += scores[i];
    rawAvg = sum / scores.length;
  }

  // ?? for bonus fallback; cap at 100
  double finalAvg = rawAvg + (student["bonus"] ?? 0);
  if (finalAvg > 100) finalAvg = 100;

  // Relational operators (>=, <) for grade thresholds — if/else if chain
  String grade;
  if (finalAvg >= 90) {
    grade = 'A';
  } else if (finalAvg >= 80) {
    grade = 'B';
  } else if (finalAvg >= 70) {
    grade = 'C';
  } else if (finalAvg >= 60) {
    grade = 'D';
  } else {
    grade = 'F';
  }

  // switch expression (Dart 3) for feedback
  String feedback = switch (grade) {
    "A" => "Outstanding performance!",
    "B" => "Good work, keep it up!",
    "C" => "Satisfactory. Room to improve.",
    "D" => "Needs improvement.",
    "F" => "Failing. Please seek help.",
    _   => "Unknown grade.",
  };

  // ?. and ?? for safe comment access
  String commentDisplay =
      (student["comment"] as String?)?.toUpperCase() ?? "No comment provided";

  // Multi-line string report card with string interpolation
  print('''
╔══════════════════════════════╗
║         REPORT CARD          ║
╠══════════════════════════════╣
║  Name:    ${_pad(student["name"] as String, 19)}║
║  Scores:  ${_pad(scores.toString(), 19)}║
║  Bonus:   ${_pad(student["bonus"] != null ? '+${student["bonus"]}' : 'none', 19)}║
║  Average: ${_pad(finalAvg.toStringAsFixed(1), 19)}║
║  Grade:   ${_pad(grade, 19)}║
║  Comment: ${_pad(commentDisplay.length > 19 ? commentDisplay.substring(0, 16) + '...' : commentDisplay, 19)}║
╚══════════════════════════════╝

  Feedback: $feedback
''');
}

// ── Feature 9: Class Summary ─────────────────────────────────────────────────

void classSummary() {
  if (students.isEmpty) { print('No students yet.'); return; }

  int total = students.length;
  int passCount = 0;

  // logical operators (&& and ||) in a condition
  for (var s in students) {
    var scores = s["scores"] as List<int>;
    var avg    = _calculateAvg(s);
    if (scores.isNotEmpty && avg >= 60) passCount++;
  }

  var allAvgs = students.map((s) => _calculateAvg(s)).toList();
  double classAvg  = allAvgs.reduce((a, b) => a + b) / total;
  double highest   = allAvgs.reduce((a, b) => a > b ? a : b);
  double lowest    = allAvgs.reduce((a, b) => a < b ? a : b);

  // collection for — builds summary list inline
  var summaryLines = [
    for (var s in students) '  ${s["name"]}: ${_calculateAvg(s).toStringAsFixed(1)}',
  ];

  // Set to collect unique grade letters
  var uniqueGrades = <String>{};
  for (var s in students) {
    uniqueGrades.add(_getGrade(_calculateAvg(s)));
  }

  print('''
── Class Summary ──────────────
  Total students : $total
  Class average  : ${classAvg.toStringAsFixed(1)}
  Highest avg    : ${highest.toStringAsFixed(1)}
  Lowest avg     : ${lowest.toStringAsFixed(1)}
  Passing (≥60)  : $passCount
  Grade spread   : ${uniqueGrades.toList()..sort()}

  All averages:''');

  summaryLines.forEach(print);
  print('');
}

// ── Helpers ───────────────────────────────────────────────────────────────────

void _listStudents() {
  for (int i = 0; i < students.length; i++) {
    print('  ${i + 1}. ${students[i]["name"]}');
  }
}

double _calculateAvg(Map<String, dynamic> student) {
  var scores = student["scores"] as List<int>;
  if (scores.isEmpty) return 0;
  int sum = 0;
  for (int i = 0; i < scores.length; i++) sum += scores[i];
  double raw   = sum / scores.length;
  double final_ = raw + (student["bonus"] ?? 0);
  return final_ > 100 ? 100 : final_;
}

String _getGrade(double avg) {
  if (avg >= 90) return 'A';
  if (avg >= 80) return 'B';
  if (avg >= 70) return 'C';
  if (avg >= 60) return 'D';
  return 'F';
}

String _pad(String s, int width) {
  return s.length >= width ? s.substring(0, width) : s.padRight(width);
}
