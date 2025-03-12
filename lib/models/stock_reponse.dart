import 'dart:convert';

class StockResponse {
  final List<StockItem> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final bool hasNextPage;
  final bool hasPreviousPage;

  StockResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory StockResponse.fromJson(Map<String, dynamic> json) {
    return StockResponse(
      items: List<StockItem>.from(json['items'].map((x) => StockItem.fromJson(x))),
      page: json['page'],
      pageSize: json['pageSize'],
      totalCount: json['totalCount'],
      hasNextPage: json['hasNextPage'],
      hasPreviousPage: json['hasPreviousPage'],
    );
  }
}

class StockItem {
  final int stockId;
  final int companyId;
  final String stockSymbol;
  final int marketId;
  final String listedDate;
  final String companyName;
  final String marketName;

  StockItem({
    required this.stockId,
    required this.companyId,
    required this.stockSymbol,
    required this.marketId,
    required this.listedDate,
    required this.companyName,
    required this.marketName,
  });

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      stockId: json['stockId'],
      companyId: json['companyId'],
      stockSymbol: json['stockSymbol'],
      marketId: json['marketId'],
      listedDate: json['listedDate'],
      companyName: json['companyName'],
      marketName: json['marketName'],
    );
  }
}
