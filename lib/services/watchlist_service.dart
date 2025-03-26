import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:source_code_mobile/models/user_response.dart';
import 'package:source_code_mobile/models/watchlist_response.dart';
import '../models/stock_reponse.dart';

class WatchListService{
  final String apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:5146/api/v1';

  Future<StockResponse?> fetchStock({
    String? searchTerm,
    String? sortColumn,
    String? sortOrder,
    int page = 1,
    int pageSize = 20,
    }) async
  {
    final fullUrl = '$apiUrl/stocks';

    final Uri uri = Uri.parse(fullUrl).replace(queryParameters: {
      if (searchTerm != null) 'searchTerm': searchTerm,
      if (sortColumn != null) 'sortColumn': sortColumn,
      if (sortOrder != null) 'sortOrder': sortOrder,
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    });

    try{
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        // Parse the JSON response
        final data = jsonDecode(response.body);
        return StockResponse.fromJson(data);
      } else {
        print('Error: ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (e) {
      print('Failed to fetch stocks: $e');
      return null;
    }
  }

  Future<bool> checkWatchListExist() async {
    final box = GetStorage();
    String? userid = box.read<String>('user_id');

    final fullUrl = '$apiUrl/watchlists/user/$userid';

    final Uri uri = Uri.parse(fullUrl);


    try{
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body);

        // Ensure the response is a List before checking its content
        if (decodedBody is List) {
          print(decodedBody.isNotEmpty);
          return decodedBody.isNotEmpty; // Returns true if the list has items, false if empty
        } else {
          print('Unexpected response format: $decodedBody');
          return false;
        }
      } else {
        print('Error: ${response.statusCode}, ${response.body}');
        return false;
      }
    }catch (e) {
      print('Failed to fetch stocks: $e');
      return false;
    }
  }

  Future<WatchListResponse?> createWatchList() async {
    final fullUrl = '$apiUrl/watchlists';

    try{
      final box = GetStorage();

      final response = await http.post(
        Uri.parse(fullUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': box.read<String>('user_id'),
          'label' : "My WacthList",
          'status': "NEW",
        }),
      );

      if(response.statusCode == 200){
        final json = jsonDecode(response.body);
        final watchList = WatchListResponse.fromJson(json);
        return watchList;
      }else{
        print('Error: ${response.statusCode}, ${response.body}');
        return null;
      }
    }catch (e) {
      print('Failed to fetch stocks: $e');
      return null;
    }
  }

  Future<WatchListResponse?> getWatchListByUserId() async {
    final box = GetStorage();
    String? userid = box.read<String>('user_id');

    final fullUrl = '$apiUrl/watchlists/user/$userid';
    final Uri uri = Uri.parse(fullUrl);

    try {
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json is List && json.isNotEmpty) {
          final firstElement = json[0]; // Get the first element
          return WatchListResponse.fromJson(firstElement);
        } else {
          print('Unexpected response format or empty list: $json');
          return null;
        }
      } else {
        print('Error: ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (e) {
      print('Failed to fetch stocks: $e');
      return null;
    }
  }

  Future<void> AddStockToWatchList(String stockId) async {
    final box = GetStorage();

    final watchListId = box.read('watchlist_id')?.toString();

    final fullUrl = '$apiUrl/watchlists/stock/$watchListId/$stockId';
    final Uri uri = Uri.parse(fullUrl);

    try {
      final response = await http.put(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print(json);
      } else {
        print('Error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Failed to fetch stocks: $e');
    }
  }

// Phương thức mới để lấy danh sách theo dõi theo userId
  Future<List<WatchlistResponse>?> fetchWatchlistsByUserId(int userId, {String? searchTerm}) async {
    final fullUrl = '$apiUrl/watchlists/user/$userId'; // Dùng userId động
    final Uri uri = Uri.parse(fullUrl).replace(queryParameters: {
      if (searchTerm != null) 'searchTerm': searchTerm, // Thêm searchTerm nếu có
    });

    try {
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<WatchlistResponse>.from(data.map((x) => WatchlistResponse.fromJson(x)));
      } else {
        print('Error: ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (e) {
      print('Failed to fetch watchlists: $e');
      return null;
    }
  }
}