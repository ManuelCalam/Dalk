import 'package:flutter/material.dart';

class UserModel {
  final String name;
  final String photoUrl;

  UserModel({required this.name, required this.photoUrl});

  Map<String, dynamic> toJson() => {
        "name": name,
        "photoUrl": photoUrl,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json["name"] ?? "",
      photoUrl: json["photoUrl"] ?? "",
    );
  }

  UserModel copyWith({
    String? name,
    String? photoUrl,
    //String? uuid,
  }) {
    return UserModel(
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      //uuid: uuid ?? this.uuid,
    );
  }

}

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}