import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/meal_sum.dart';
import '../services/api.dart';
import '../widgets/category_card.dart';
import '../widgets/glass_card.dart';
import 'meals_by_categories.dart';
import 'meal_details.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<MealCategory> categories = [];
  List<MealCategory> filtered = [];
  String query = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    final data = await ApiService.getCategories();
    setState(() {
      categories = data;
      filtered = data;
      loading = false;
    });
  }

  void onSearch(String q) {
    query = q;
    if (q.isEmpty) {
      setState(() => filtered = categories);
      return;
    }
    final lower = q.toLowerCase();
    setState(() {
      filtered = categories.where((c) {
        return c.name.toLowerCase().contains(lower) ||
            c.description.toLowerCase().contains(lower);
      }).toList();
    });
  }

  Future<void> showRandomMeal() async {
    final meal = await ApiService.getRandomMeal();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MealDetailScreen(meal: meal)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // layered background for subtle gradient
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFf8fafc), Color(0xFFe9f1fb)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // AppBar-like area with blur & random button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          borderRadius: 12,
                          child: Row(
                            children: [
                              const Icon(Icons.restaurant_menu, color: Colors.white70),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Категории на јадења',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: Colors.white,
                                          fontSize: 16,
                                        )),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Изберете категорија или пребарајте',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GlassCard(
                        borderRadius: 12,
                        padding: const EdgeInsets.all(8),
                        child: IconButton(
                          icon: const Icon(Icons.shuffle, size: 22),
                          color: Colors.white,
                          onPressed: showRandomMeal,
                          tooltip: 'Random meal',
                        ),
                      ),
                    ],
                  ),
                ),

                // Search field
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
                  child: GlassCard(
                    borderRadius: 12,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: TextField(
                      onChanged: onSearch,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Пребарај категории...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                    onRefresh: load,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20, top: 8),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final c = filtered[i];
                        return CategoryCard(
                          category: c,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MealsByCategoryScreen(category: c),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
