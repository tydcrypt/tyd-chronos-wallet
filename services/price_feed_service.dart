// Price Feed Service
// Fetches real-time cryptocurrency prices

import 'dart:convert';
import 'package:http/http.dart' as http;

class PriceFeedService {
  final String _apiKey = 'YOUR_API_KEY';
  
  Future<Map<String, double>> getCryptoPrices(List<String> symbols) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.coingecko.com/api/v3/simple/price?ids=${symbols.join(',')}&vs_currencies=usd')
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Map<String, double> prices = {};
        
        for (var symbol in symbols) {
          prices[symbol] = data[symbol]?['usd']?.toDouble() ?? 0.0;
        }
        
        return prices;
      } else {
        throw Exception('Failed to fetch prices: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching price data: $e');
    }
  }
}
