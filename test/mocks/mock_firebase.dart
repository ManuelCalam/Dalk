class MockFirebaseMessaging {
  Future<String> getToken() async => 'mock_token';
  Future<void> deleteToken() async {}
  void onMessage(Function(Map<String, dynamic>) handler) {
    handler({'notification': {'title': 'Mock'}}); 
  }
}