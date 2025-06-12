class User {
  String name;
  String username;
  String password;
  User({
    required this.name,
    required this.username,
    required this.password,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        name: json['name'],
        username: json['username'],
        password: json['password']);
  }
}
