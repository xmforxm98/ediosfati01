enum Gender { male, female }

class UserData {
  String? nickname;
  String? firstName;
  String? middleName;
  String? lastName;
  String? year;
  String? month;
  String? day;
  String? hour;
  String? minute;
  Gender? gender;
  String? country;
  String? state;
  String? city;

  UserData({
    this.nickname,
    this.firstName,
    this.middleName,
    this.lastName,
    this.year,
    this.month,
    this.day,
    this.hour,
    this.minute,
    this.gender,
    this.country,
    this.state,
    this.city,
  });

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'year': year,
      'month': month,
      'day': day,
      'hour': hour,
      'minute': minute,
      'gender':
          gender == null ? null : (gender == Gender.male ? 'male' : 'female'),
      'country': country,
      'state': state,
      'city': city,
    };
  }
}
