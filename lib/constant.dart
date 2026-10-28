class Constant {
  // ignore: non_constant_identifier_names
  static String IP = '10.10.2.147';
  static String BASE_URL = 'http://' + IP + '/flutter';
  static String USER_REGISTRATION = '/User_Registration.php';
  static String LOGIN = '/Login.php?';
  static String WS_PROJECT_NAME = '/WSRetrovolley';
  static String KEY_IP_PREFERENCE = 'base_IP';
  static String KEY_BASED_URL = 'http://' + KEY_IP_PREFERENCE + WS_PROJECT_NAME;
}
