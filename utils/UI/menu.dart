import 'dart:convert';
import 'dart:io';

import '../../models/user.dart';

class UI {
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
    print('==============================================');
    print('==================== Login ===================');
    print('==============================================');
    stdout.write('Enter username:  ');
    String? username = stdin.readLineSync();

    stdout.write('Enter password:  ');
    String? password = stdin.readLineSync();

    if (ifUserExist(username!, password!, File('data/users.json'))) {
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
      await joinQueue(selectedDept);
    } else {
      print('Invalid choice. Please try again.');
      showQueues(departments);
    }
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

  static bool ifUserExist(String username, String password, File fileJson) {
    if (!fileJson.existsSync()) return false;

    String contents = fileJson.readAsStringSync();
    if (contents.isEmpty) return false;

    List<dynamic> jsonData = jsonDecode(contents);

    for (var user in jsonData) {
      if (user['username'] == username && user['password'] == password) {
        return true;
      }
    }

    return false;
  }
}
