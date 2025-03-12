import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
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
    final fullUrl = '$apiUrl/watchlists/user';

    final box = GetStorage();

    final Uri uri = Uri.parse(fullUrl).replace(queryParameters: {
      'userId' : box.read<String>('user_id')
    });

    try{
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );
      if(response.statusCode == 200){
        final json = jsonDecode(response.body);
        return !json.isEmpty();
      } else{
        print('Error: ${response.statusCode}, ${response.body}');
        return false;
      }
    }catch (e) {
      print('Failed to fetch stocks: $e');
      return false;
    }
  }


}