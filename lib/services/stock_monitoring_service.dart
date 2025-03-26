import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StockService {
  final String apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:5146/api/v1';
  final String? token;
  final String? stockId;

  StockService({this.token,this.stockId});

  Future<List<Session>> getSessions() async {
    final fullUrl = '$apiUrl/sessions';
    try {
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print('Raw API response: $data');
        final List<dynamic> sessionList = data['items'] as List<dynamic>; // Lấy danh sách từ key "items"
        return sessionList.map((json) => Session.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load sessions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching sessions: $e');
    }
  }

  Future<List<Session>> getSessionsByStockId() async {
    final fullUrl = '$apiUrl/sessions/stocks/$stockId';

    try {
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body); // Parse as a List
        print('Raw API response: $data');

        return data.map((json) => Session.fromJson(json)).toList(); // Convert to Session objects
      } else {
        throw Exception('Failed to load sessions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching sessions: $e');
    }
  }




  Future<List<StockInSession>> getSessionStocks(int sessionId) async {
    final fullUrl = '$apiUrl/sessions/$sessionId/stocks';
    try {
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => StockInSession.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load stocks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching stocks: $e');
    }
  }
}

class Session {
  final int sessionId;
  final String? sessionType;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? status;

  Session({
    required this.sessionId,
    this.sessionType,
    this.startTime,
    this.endTime,
    this.status,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionId: json['sessionId'],
      sessionType: json['sessionType'],
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      status: json['status'],
    );
  }
}

class StockInSession {
  final int stockInSessionId;
  final int? stockId;
  final int? sessionId;
  final DateTime? dateTime;
  final double? openPrice;
  final double? closePrice;
  final double? highPrice;
  final double? lowPrice;
  final double? volume;

  StockInSession({
    required this.stockInSessionId,
    this.stockId,
    this.sessionId,
    this.dateTime,
    this.openPrice,
    this.closePrice,
    this.highPrice,
    this.lowPrice,
    this.volume,
  });

  factory StockInSession.fromJson(Map<String, dynamic> json) {
    return StockInSession(
      stockInSessionId: json['stockInSessionId'],
      stockId: json['stockId'],
      sessionId: json['sessionId'],
      dateTime: json['dateTime'] != null ? DateTime.parse(json['dateTime']) : null,
      openPrice: (json['openPrice'] as num?)?.toDouble(),
      closePrice: (json['closePrice'] as num?)?.toDouble(),
      highPrice: (json['highPrice'] as num?)?.toDouble(),
      lowPrice: (json['lowPrice'] as num?)?.toDouble(),
      volume: (json['volume'] as num?)?.toDouble(),
    );
  }
}