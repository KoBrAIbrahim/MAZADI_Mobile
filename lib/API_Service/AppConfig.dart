class AppConfig {
  // Update these URLs to match your server configuration
  static const String baseUrl = 'http://192.168.1.20:8080'; // Replace with your server IP
  // WebSocket URL
  static const String webSocketUrl = 'ws://192.168.1.20:8080/ws'; // Replace with your server IP

  // API endpoints
  static String get postsUrl => '$baseUrl/posts';
  static String postTimerUrl(int postId) => '$baseUrl/posts/$postId/start-timer';
  static String postTimerStatusUrl(int postId) => '$baseUrl/posts/$postId/timer-status';
  static String placeBidUrl(int postId, double amount) => '$baseUrl/posts/$postId/increase-price?amount=$amount';
  static String getCurrentActivePostUrl(int auctionId) => '$baseUrl/posts/auction/$auctionId/current-active';
  static String startNextPostUrl(int auctionId) => '$baseUrl/posts/auction/$auctionId/start-next';
}