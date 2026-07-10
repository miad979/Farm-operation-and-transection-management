import 'package:flutter/foundation.dart';

class LanguageProvider extends ChangeNotifier {
  bool _isBangla = false;

  bool get isBangla => _isBangla;

  void setBangla(bool value) {
    if (_isBangla == value) return;
    _isBangla = value;
    notifyListeners();
  }

  void toggle() {
    _isBangla = !_isBangla;
    notifyListeners();
  }

  String text(String english, String bangla) => _isBangla ? bangla : english;
}
