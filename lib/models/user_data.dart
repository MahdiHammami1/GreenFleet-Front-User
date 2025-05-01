class UserData {
  String? email;
  String? password;
  String? firstname;
  String? lastname;
  String? phoneNumber;
  String? dateOfBirth;

  // We'll store it as "Male" or "Female"
  String? gender;

  // You can also add a helper if needed:
  void setGenderFromTitle(String title) {
    gender = (title == "Mr.") ? "Male" : "Female";
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstname': firstname,
      'lastname': lastname,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
    };
  }
}