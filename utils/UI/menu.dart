import 'dart:io';

class UI {
  static void showMenu() {
    print('==============================================');
    print('=========== Government Queue System ==========');
    print('==============================================');
    print('1. Register New User');
    print('2. Login');
    print('3. View Departments');
    print('4. Exit');
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
        showDepartments(['Health', 'Education', 'Finance']);
        break;
      case 4:
        print('Goodbye!');
        exit(0);
      default:
        print('Invalid choice. Please try again.');
        showMenu();
    }
  }

  static void showLoginForm() {
    print('\n=== Login ===');
  }

  static void showRegistrationForm() {
    print('\n=== Register New User ===');
  }

  static void showDepartments(List<String> departments) {
    print('\n=== Available Departments ===');
    for (int i = 0; i < departments.length; i++) {
      print('${i + 1}. ${departments[i]}');
    }
  }

  static void showQueueStatus() {
    print('\n=== Current Queue Status ===');
    // Queue display logic
  }
}
