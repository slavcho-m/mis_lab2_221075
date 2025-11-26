import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/category.dart';
import '../models/meal_sum.dart';
import '../models/meal_details.dart';

class ApiService {
  static const String base = 'www.themealdb.com';

  static Future<List<MealCategory>> getCategories() async {
    final url = Uri.https(base, '/api/json/v1/1/categories.php');
    final res = await http.get(url);
    final data = jsonDecode(res.body);

    final list = data['categories'] as List;
    return list.map((e) => MealCategory.fromJson(e)).toList();
  }

  static Future<List<MealSummary>> getMealsByCategory(String category) async {
    final url = Uri.https(base, '/api/json/v1/1/filter.php', {'c': category});
    final res = await http.get(url);
    final data = jsonDecode(res.body);

    final list = data['meals'] as List;
    return list.map((e) => MealSummary.fromJson(e)).toList();
  }

  static Future<MealDetail> getMealDetail(String id) async {
    final url = Uri.https(base, '/api/json/v1/1/lookup.php', {'i': id});
    final res = await http.get(url);
    final data = jsonDecode(res.body);

    return MealDetail.fromJson(data['meals'][0]);
  }

  static Future<MealDetail> getRandomMeal() async {
    final url = Uri.https(base, '/api/json/v1/1/random.php');
    final res = await http.get(url);
    final data = jsonDecode(res.body);

    return MealDetail.fromJson(data['meals'][0]);
  }

  static Future<List<MealSummary>> searchMeals(String query) async {
    final url = Uri.https(base, '/api/json/v1/1/search.php', {'s': query});
    final res = await http.get(url);
    final data = jsonDecode(res.body);

    if (data['meals'] == null) return [];

    final list = data['meals'] as List;
    return list.map((e) => MealSummary.fromJson(e)).toList();
  }
}
