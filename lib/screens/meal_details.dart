import 'package:flutter/material.dart';
import '../models/meal_details.dart';
import '../services/api.dart';
import '../widgets/glass_card.dart';
import 'package:url_launcher/url_launcher.dart';

class MealDetailScreen extends StatefulWidget {
  final MealDetail? meal;
  final String? mealId;

  const MealDetailScreen({super.key, this.meal, this.mealId});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  MealDetail? meal;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.meal != null) {
      meal = widget.meal;
      loading = false;
    } else {
      load();
    }
  }

  Future<void> load() async {
    final data = await ApiService.getMealDetail(widget.mealId!);
    setState(() {
      meal = data;
      loading = false;
    });
  }

  Future<void> _openYoutube(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading || meal == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // header image
            Stack(
              children: [
                Hero(
                  tag: 'meal-${meal!.id}',
                  child: SizedBox(
                    height: 240,
                    width: double.infinity,
                    child: Image.network(
                      meal!.thumbnail,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: GlassCard(
                    borderRadius: 12,
                    padding: const EdgeInsets.all(6),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: GlassCard(
                    borderRadius: 12,
                    padding: const EdgeInsets.all(6),
                    child: IconButton(
                      onPressed: () {}, // reserved for favorite or share later
                      icon: const Icon(Icons.favorite_border),
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassCard(
                      borderRadius: 12,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal!.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: meal!.ingredients.map((ing) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  ing,
                                  style: const TextStyle(fontSize: 12, color: Colors.white),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    GlassCard(
                      borderRadius: 12,
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Instructions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                          const SizedBox(height: 8),
                          Text(
                            meal!.instructions,
                            style: const TextStyle(color: Colors.white70),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),

                    if (meal!.youtube != null && meal!.youtube!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _openYoutube(meal!.youtube!),
                        child: GlassCard(
                          borderRadius: 12,
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(Icons.play_circle_fill, color: Colors.redAccent),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Watch on YouTube',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                                ),
                              ),
                              const Icon(Icons.open_in_new, color: Colors.white70),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
