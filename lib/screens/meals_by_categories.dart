import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/meal_sum.dart';
import '../services/api.dart';
import '../widgets/meal_grid_item.dart';
import '../widgets/glass_card.dart';
import 'meal_details.dart';

class MealsByCategoryScreen extends StatefulWidget {
  final MealCategory category;

  const MealsByCategoryScreen({super.key, required this.category});

  @override
  State<MealsByCategoryScreen> createState() => _MealsByCategoryScreenState();
}

class _MealsByCategoryScreenState extends State<MealsByCategoryScreen> {
  List<MealSummary> meals = [];
  bool loading = true;
  String search = '';

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    final data = await ApiService.getMealsByCategory(widget.category.name);
    setState(() {
      meals = data;
      loading = false;
    });
  }

  Future<void> searchMeals(String q) async {
    search = q;
    if (q.isEmpty) return load();
    final res = await ApiService.searchMeals(q);
    setState(() => meals = res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // keep glass background theme
      body: SafeArea(
        child: Column(
          children: [
            // Header with image and back button
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  ),
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      borderRadius: 12,
                      child: Row(
                        children: [
                          Hero(
                            tag: 'cat-${widget.category.id}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                widget.category.thumbnail,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.category.name,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontSize: 16,
                                    )),
                                const SizedBox(height: 4),
                                Text(
                                  widget.category.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search within category
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
              child: GlassCard(
                borderRadius: 12,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: TextField(
                  onChanged: searchMeals,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Пребарај јадења...',
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
                  : GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.7,
                ),
                itemCount: meals.length,
                itemBuilder: (_, i) {
                  final m = meals[i];
                  return MealGridItem(
                    meal: m,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MealDetailScreen(mealId: m.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
