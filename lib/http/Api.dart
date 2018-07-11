class Api {
  static const bool PRODUCT = false;

  static const String DEV_BASE_URL = 'https://api.dev/';
  static const String PRODUCT_BASE_URL = 'https://api/';

  static const String BASE_URL = PRODUCT ? PRODUCT_BASE_URL : DEV_BASE_URL;

  static const String LOGIN = 'login';
}