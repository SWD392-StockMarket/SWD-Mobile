import 'package:source_code_mobile/models/stock_reponse.dart';

class WatchlistResponse {
  final int watchListId;
  final int userId;
  final String label;
  final String createdDate;
  final String lastEdited;
  final String status;
  final List<StockItem> stocks;

  WatchlistResponse({
    required this.watchListId,
    required this.userId,
    required this.label,
    required this.createdDate,
    required this.lastEdited,
    required this.status,
    required this.stocks,
  });

  factory WatchlistResponse.fromJson(Map<String, dynamic> json) {
    return WatchlistResponse(
      watchListId: json['watchListId'],
      userId: json['userId'],
      label: json['label'],
      createdDate: json['createdDate'],
      lastEdited: json['lastEdited'],
      status: json['status'],
      stocks: List<StockItem>.from(json['stocks'].map((x) => StockItem.fromJson(x))),
    );
  }
}