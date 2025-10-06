import 'package:flutter/material.dart';
import '/user_provider.dart';
import '/user_prefs.dart';
import '/backend/supabase/supabase.dart';
import '/auth/supabase_auth/auth_util.dart';
import 'package:provider/provider.dart';

class UserModel {
  final String? uuid;
  final String? name;
  final String? email;
  final String? birthdate;
  final String? gender;
  final String? address;
  final String? houseNumber;
  final String? zipCode;
  final String? neighborhood;
  final String? city;
  final String? usertype;
  final String? photoUrl;
  final String? createdAt;
  final String? phone;

  UserModel({
    this.uuid,
    this.name,
    this.email,
    this.birthdate,
    this.gender,
    this.address,
    this.houseNumber,
    this.zipCode,
    this.neighborhood,
    this.city,
    this.usertype,
    this.photoUrl,
    this.createdAt,
    this.phone,
  });

  Map<String, dynamic> toJson() => {
        "uuid": uuid,
        "name": name,
        "email": email,
        "birthdate": birthdate,
        "gender": gender,
        "address": address,
        "houseNumber": houseNumber,
        "zipCode": zipCode,
        "neighborhood": neighborhood,
        "city": city,
        "usertype": usertype,
        "photoUrl": photoUrl,
        "createdAt": createdAt,
        "phone": phone,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uuid: json["uuid"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      birthdate: json["birthdate"] ?? "",
      gender: json["gender"] ?? "",
      address: json["address"] ?? "",
      houseNumber: json["houseNumber"] ?? "",
      zipCode: json["zipCode"] ?? "",
      neighborhood: json["neighborhood"] ?? "",
      city: json["city"] ?? "",
      usertype: json["usertype"] ?? "",
      photoUrl: json["photoUrl"] ?? "",
      createdAt: json["createdAt"] ?? "",
      phone: json["phone"] ?? "",
    );
  }

  UserModel copyWith({
    String? uuid,
    String? name,
    String? email,
    String? birthdate,
    String? gender,
    String? address,
    String? houseNumber,
    String? zipCode,
    String? neighborhood,
    String? city,
    String? usertype,
    String? photoUrl,
    String? createdAt,
    String? phone,
  }) {
    return UserModel(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      email: email ?? this.email,
      birthdate: birthdate ?? this.birthdate,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      houseNumber: houseNumber ?? this.houseNumber,
      zipCode: zipCode ?? this.zipCode,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      usertype: usertype ?? this.usertype,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      phone: phone ?? this.phone,
    );
  }
}

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  Future<void> loadUser({bool forceRefresh = false}) async {
    // 1. Intentar cargar del cache
    final cachedUser = await UserPrefs.getUser();
    if (cachedUser != null && !forceRefresh) {
      _user = cachedUser;
      notifyListeners();
      debugPrint("Usuario cargado desde cache: ${cachedUser.name}");
      return; // ⚡ Salimos aquí si no queremos refrescar
    }

    // 2. Traer de Supabase solo si forceRefresh es true o no hay cache
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('uuid, name, email, birthdate, gender, address, houseNumber, zipCode, neighborhood, city, usertype, photo_url, createdAt, phone')
          .eq('uuid', currentUserUid)
          .maybeSingle();

      if (response != null) {
        final newUser = UserModel(
          uuid: response['uuid'] ?? '',
          name: response['name'] ?? '',
          email: response['email'] ?? '',
          birthdate: response['birthdate'] ?? '',
          gender: response['gender'] ?? '',
          address: response['address'] ?? '',
          houseNumber: response['houseNumber'] ?? '',
          zipCode: response['zipCode'] ?? '',
          neighborhood: response['neighborhood'] ?? '',
          city: response['city'] ?? '',
          usertype: response['usertype'] ?? '',
          photoUrl: response['photo_url'] ?? '',
          createdAt: response['createdAt'] ?? '',
          phone: response['phone'] ?? '',
        );

        _user = newUser;
        notifyListeners();
        await UserPrefs.saveUser(newUser);
        debugPrint("Usuario actualizado desde Supabase: ${newUser.name}");
      } else {
        debugPrint("No se encontró el usuario en Supabase");
      }
    } catch (e) {
      debugPrint("Error cargando usuario desde Supabase: $e");
    }
  }

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}