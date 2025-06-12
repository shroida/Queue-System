import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../../models/queue_ticket .dart';
import '../../models/user.dart';

class UI {
  User currentUser =
      User(name: 'name', username: 'username', password: 'password');
  static void showMenu() {
    print('==============================================');
    print('=========== Government Queue System ==========');
    print('==============================================');
    print('1. Register New User');
    print('2. Login');
    print('3. Exit');
    stdout.write('Choose an option: ');

    String? input = stdin.readLineSync();
    int? choice = int.tryParse(input ?? '');

    switch (choice) {
      case 1:
        showRegistrationForm();
        break;
      case 2:
        showLoginForm();
        break;
      case 3:
        print('Goodbye!');
        exit(0);
      default:
        print('Invalid choice. Please try again.');
        showMenu();
    }
  }

  static void showLoginForm() {
    final ui = UI();

    print('==============================================');
    print('==================== Login ===================');
    print('==============================================');
    stdout.write('Enter username:  ');
    String? username = stdin.readLineSync();

    stdout.write('Enter password:  ');
    String? password = stdin.readLineSync();
    bool isExist =
        ui.ifUserExist(username!, password!, File('data/users.json'));
    if (isExist) {
      clearTerminal();
      print('Login successful!');
      showLoggedInMenu();
    } else {
      clearTerminal();
      print('Wrong username or password');
      print('Please try again');
      showLoginForm();
    }
  }

  static void showLoggedInMenu() {
    print('==============================================');
    print('============= Logged In Menu ================');
    print('==============================================');
    print('1. Queues 🚶‍♂️🚶‍♂️🚶‍♂️');
    print('2. Queues Status');
    print('3. Exit');
    stdout.write('Choose an option: ');

    String? input = stdin.readLineSync();
    int? choice = int.tryParse(input ?? '');

    switch (choice) {
      case 1:
        showQueues([
          'Passport Issuance',
          'National ID Card Issuance',
          'Birth Certificate Issuance',
        ]);
        break;
      case 2:
        showQueueStatus();
        break;
      case 3:
        print('Goodbye!');
        exit(0);
      default:
        print('Invalid choice. Please try again.');
        showLoggedInMenu();
    }
  }

  static Future<void> showRegistrationForm() async {
    print('==============================================');
    print('=============   Register New User  ===========');
    print('==============================================');

    stdout.write('Enter your name:  ');
    String? name = stdin.readLineSync();

    stdout.write('Enter username:  ');
    String? username = stdin.readLineSync();

    stdout.write('Enter password:  ');
    String? password = stdin.readLineSync();

    if (username != null && password != null && name != null) {
      User newUser = User(name: name, username: username, password: password);

      final file = File('data/users.json');
      List<User> users = [];

      if (await file.exists()) {
        String contents = await file.readAsString();
        if (contents.isNotEmpty) {
          List<dynamic> jsonData = jsonDecode(contents);
          users = jsonData.map((e) => User.fromJson(e)).toList();
        }
      }

      users.add(newUser);

      await file.writeAsString(
          jsonEncode(users.map((e) => e.toJson()).toList()),
          flush: true);

      clearTerminal();
      print('\n✅ User registered successfully!');
      showLoginForm();
    } else {
      print('\n❌ Invalid input. Please try again.');
    }
  }

  static Future<void> showQueues(List<String> departments) async {
    final ui = UI();
    print('\n=== Available Departments ===');
    for (int i = 0; i < departments.length; i++) {
      print('${i + 1}. ${departments[i]}');
    }

    stdout.write('Select a queue to join (or 0 to go back): ');
    String? input = stdin.readLineSync();
    int? choice = int.tryParse(input ?? '');

    if (choice == null || choice == 0) {
      clearTerminal();
      showLoggedInMenu();
      return;
    }

    if (choice >= 1 && choice <= departments.length) {
      final selectedDept = departments[choice - 1];
      await ui.joinQueue(selectedDept);
    } else {
      print('Invalid choice. Please try again.');
      showQueues(departments);
    }
  }

  Future<void> joinQueue(String department) async {
    final queueFile = File('data/queues.json');
    List<QueueTicket> tickets = [];

    if (await queueFile.exists()) {
      final contents = await queueFile.readAsString();
      if (contents.isNotEmpty) {
        final jsonData = jsonDecode(contents) as List;
        tickets = jsonData.map((e) => QueueTicket.fromJson(e)).toList();
      }
    }

    final deptTickets =
        tickets.where((t) => t.department == department).toList();
    final position = deptTickets.length + 1;
    final ticketId =
        '${department.substring(0, 3)}-${Random().nextInt(9000) + 1000}';

    // Create new ticket
    final newTicket = QueueTicket(
      id: ticketId,
      department: department,
      user: currentUser,
      timestamp: DateTime.now(),
      position: position,
    );

    // Add to queue and save
    tickets.add(newTicket);
    await queueFile.writeAsString(
      jsonEncode(tickets.map((t) => t.toJson()).toList()),
      flush: true,
    );

    // Print ticket
    printTicket(newTicket, deptTickets.length);

    print('\nPress any key to return to menu...');
    stdin.readLineSync();
    clearTerminal();
    showLoggedInMenu();
  }

  static void printTicket(QueueTicket ticket, int usersBefore) {
    clearTerminal();
    print('==============================================');
    print('=============== YOUR TICKET ==================');
    print('==============================================');
    print('Ticket ID: ${ticket.id}');
    print('Department: ${ticket.department}');
    print('Name: ${ticket.user.name}');
    print('Date: ${ticket.timestamp}');
    print('Position in queue: ${ticket.position}');
    print('Users before you: $usersBefore');
    print('Users after you: 0 (you are last in line)');
    print('==============================================');
  }

  static void showQueueStatus() {
    print('\n=== Current Queue Status ===');
    // Queue display logic
  }

  static void clearTerminal() {
    if (Platform.isWindows) {
      // This works in most modern Windows terminals (e.g., Windows Terminal)
      stdout.write('\x1B[2J\x1B[0;0H');
    } else {
      // Linux/macOS
      stdout.write('\x1B[2J\x1B[H');
    }
  }

  bool ifUserExist(String username, String password, File fileJson) {
    if (!fileJson.existsSync()) return false;

    String contents = fileJson.readAsStringSync();
    if (contents.isEmpty) return false;

    List<dynamic> jsonData = jsonDecode(contents);

    for (var user in jsonData) {
      if (user['username'] == username && user['password'] == password) {
        currentUser =
            User(name: user['name'], username: username, password: password);
        return true;
      }
    }

    return false;
  }
}
