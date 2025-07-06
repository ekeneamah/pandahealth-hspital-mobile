String? validatePhoneNumber(String string) {
  // Null or empty string is invalid phone number
  if (string.isEmpty) {
    return 'Please enter mobile number';
  }
  // You may need to change this pattern to fit your requirement.
  // I just copied the pattern from here: https://regexr.com/3c53v
  const pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
  final regExp = RegExp(pattern);
  if (!regExp.hasMatch(string)) {
    return 'Please enter valid mobile number';
  }
  return null;
}

RegExp nameRegExp = RegExp(r"^[A-Za-z]+$");
String? validateName(String value) {
  if (value.isEmpty) {
    return 'Field is required';
  }

  return null;
}

RegExp numberRegExp = RegExp(r'^[0-9]+$');
String? validateNumber(String value) {
  if (value.isEmpty) {
    return 'Field is required';
  }
  if (!numberRegExp.hasMatch(value)) {
    return 'Please enter valid number';
  }
  return null;
}


RegExp emailRegExp = RegExp(r'\S+@\S+\.\S+');
String? validateEmail(String value) {
  if (value.isEmpty) {
    return 'Field is required';
  }
  if (!emailRegExp.hasMatch(value)) {
    return 'Please enter valid email';
  }
  return null;
}

RegExp passwordRegExp = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
String? validatePassword(String value) {
  if (value.isEmpty) {
    return 'Field is required';
  }
  if (!passwordRegExp.hasMatch(value)) {
    return 'Password must have at least one Uppercase, lowercase, digit, special characters & 8 characters';
  }
  return null;
}
