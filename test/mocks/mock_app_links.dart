import 'dart:async';

class MockAppLinks {
  Stream<Uri?> get uriLinkStream => Stream.empty();

  Future<Uri?> getInitialLink() async {
    return null;
  }
}