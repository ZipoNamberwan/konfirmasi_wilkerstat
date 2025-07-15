// lib/helpers/telegram_logger.dart
import 'package:dio/dio.dart';

class TelegramLogger {
  static const String _token = '7650669494:AAEmJYC5TLslZ5W7l121FgvfV3tyXJvqcpw';
  static const String _chatId = '-4961166858'; // group ID

  static final Dio _dio = Dio();

  static Future<void> send(String message) async {
    try {
      await _dio.post(
        'https://api.telegram.org/bot$_token/sendMessage',
        data: {'chat_id': _chatId, 'text': message},
      );
    } catch (e) {
      // silent failure, do not throw
    }
  }
}
