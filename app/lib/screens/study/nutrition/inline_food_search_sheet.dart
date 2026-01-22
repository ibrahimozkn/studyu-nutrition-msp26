import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/barcode_scanner_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/services/usda_api_service.dart';
import 'package:studyu_app/util/template_storage_manager.dart';
import 'package:studyu_core/core.dart' as studyu;

class InlineFoodSearchSheet extends StatefulWidget {
  const InlineFoodSearchSheet({
    super.key,
    this.onSelected,
    this.scrollController,
  });

  final ValueChanged<studyu.FoodEntry>? onSelected;
  final ScrollController? scrollController;

  static Future<studyu.FoodEntry?> show(
    BuildContext context, {
    ValueChanged<studyu.FoodEntry>? onSelected,
  }) {
    return showModalBottomSheet<studyu.FoodEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        minChildSize: 0.3,
        maxChildSize: 0.95,
        expand: false,
        builder: (sheetContext, scrollController) => InlineFoodSearchSheet(
          onSelected: onSelected,
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  State<InlineFoodSearchSheet> createState() =>
      _InlineFoodSearchSheetState();
}

class _InlineFoodSearchSheetState extends State<InlineFoodSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  final _templateManager = TemplateStorageManager();

  List<Product> _openFoodFactsResults = [];
  List<UsdaFoodItem> _usdaResults = [];
  List<studyu.SavedFoodTemplate> _templateResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    OpenFoodAPIConfiguration.userAgent = UserAgent(
      name: 'StudyU',
      version: '1.0',
      system: 'Flutter',
      url: 'https://studyu.health',
    );
    OpenFoodAPIConfiguration.globalLanguages = [OpenFoodFactsLanguage.ENGLISH];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchFood() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _openFoodFactsResults = [];
      _usdaResults = [];
      _templateResults = [];
    });

    final appState = context.read<AppState>();
    final userId = appState.activeSubject?.userId;

    await Future.wait([
      _searchOpenFoodFacts(query),
      _searchUsda(query),
      if (userId != null) _searchTemplates(userId, query),
    ]);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchOpenFoodFacts(String query) async {
    try {
      final searchResult = await OpenFoodAPIClient.searchProducts(
        null,
        ProductSearchQueryConfiguration(
          parametersList: [SearchTerms(terms: [query])],
          language: OpenFoodFactsLanguage.ENGLISH,
          fields: [
            ProductField.NAME,
            ProductField.BRANDS,
            ProductField.BARCODE,
            ProductField.NUTRIMENTS,
            ProductField.SERVING_SIZE,
            ProductField.QUANTITY,
            ProductField.IMAGE_FRONT_SMALL_URL,
          ],
          version: ProductQueryVersion.v3,
        ),
      );

      if (mounted &&
          searchResult.products != null &&
          searchResult.products!.isNotEmpty) {
        setState(() {
          _openFoodFactsResults = searchResult.products!;
        });
      }
    } catch (e) {
      debugPrint('OpenFoodFacts search error: $e');
    }
  }

  Future<void> _searchUsda(String query) async {
    try {
      final searchResult = await UsdaApiService.searchFoods(query: query);

      if (mounted && searchResult.foods.isNotEmpty) {
        final sortedResults = List<UsdaFoodItem>.from(searchResult.foods)
          ..sort((a, b) {
            int getPriority(String? dataType) {
              if (dataType == null) return 2;
              if (dataType.toLowerCase().contains('foundation')) return 0;
              if (dataType.toLowerCase().contains('sr legacy') ||
                  dataType.toLowerCase().contains('sr_legacy')) {
                return 1;
              }
              return 2;
            }

            final priorityA = getPriority(a.dataType);
            final priorityB = getPriority(b.dataType);

            if (priorityA != priorityB) {
              return priorityA.compareTo(priorityB);
            }
            return (a.description ?? '').compareTo(b.description ?? '');
          });

        setState(() {
          _usdaResults = sortedResults;
        });
      }
    } catch (e) {
      debugPrint('USDA search error: $e');
    }
  }

  Future<void> _searchTemplates(String userId, String query) async {
    try {
      final templates = await _templateManager.searchFoodTemplates(
        userId,
        query,
      );
      if (mounted) {
        setState(() {
          _templateResults = templates;
        });
      }
    } catch (e) {
      debugPrint('Template search error: $e');
    }
  }

  Future<void> _scanBarcode() async {
    final result = await Navigator.push(context, BarcodeScannerScreen.route());
    if (result != null && mounted) {
      _notifySelection(result);
    }
  }

  void _notifySelection(studyu.FoodEntry entry) {
    widget.onSelected?.call(entry);
    Navigator.pop(context, entry);
  }

  studyu.FoodEntry _convertUsdaToFoodEntry(UsdaFoodItem food) {
    final servingSizeGrams = food.servingSize ?? 100.0;
    final servingSizeUnit = food.servingSizeUnit ?? 'g';
    final scale = servingSizeGrams / 100.0;

    return studyu.FoodEntry.withId(
      entryType: studyu.FoodEntryType.brandedProduct,
      name: food.description ?? 'Unknown Food',
      brandName: food.brandOwner ?? food.brandName,
      description: food.ingredients,
      amount: 1,
      unit: servingSizeUnit,
      servingSizeGrams: servingSizeGrams,
      portionReference: food.householdServingFullText,
      portionEstimationMethod: studyu.PortionEstimationMethod.standardUnit,
      portionState: studyu.PortionState.asServed,
      yieldFactor: 1.0,
      nutrition: studyu.NutritionProfile(
        energyKcal: (food.energyKcal100g * scale).roundToDouble(),
        protein: food.protein100g * scale,
        carbs: food.carbohydrates100g * scale,
        fat: food.fat100g * scale,
        sugars: food.sugars100g * scale,
        fiber: food.fiber100g * scale,
        saturatedFat: food.saturatedFat100g * scale,
        transFat: 0,
        cholesterol: 0,
        sodium: food.sodium100g * scale,
        waterContent: 0,
        micros: {},
      ),
      foodCode: food.gtinUpc,
      externalId: food.fdcId.toString(),
      source: studyu.FoodSource.usda,
      confidenceScore: 1.0,
      originalValues: {
        'fdcId': food.fdcId,
        'dataType': food.dataType,
        'description': food.description,
      },
    );
  }

  studyu.FoodEntry _convertToFoodEntry(Product product) {
    final nutriments = product.nutriments;
    final energyKcal =
        nutriments?.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams) ?? 0;
    final protein =
        nutriments?.getValue(Nutrient.proteins, PerSize.oneHundredGrams) ?? 0;
    final carbs =
        nutriments?.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams) ??
        0;
    final fat =
        nutriments?.getValue(Nutrient.fat, PerSize.oneHundredGrams) ?? 0;
    final sugars =
        nutriments?.getValue(Nutrient.sugars, PerSize.oneHundredGrams) ?? 0;
    final fiber =
        nutriments?.getValue(Nutrient.fiber, PerSize.oneHundredGrams) ?? 0;
    final saturatedFat =
        nutriments?.getValue(Nutrient.saturatedFat, PerSize.oneHundredGrams) ??
        0;
    final sodium =
        (nutriments?.getValue(Nutrient.sodium, PerSize.oneHundredGrams) ?? 0) *
        1000;

    double servingSizeGrams = 100.0;
    if (product.servingSize != null) {
      final match = RegExp(r'(\d+(?:\.\d+)?)\s*g')
          .firstMatch(product.servingSize!);
      if (match != null) {
        servingSizeGrams = double.tryParse(match.group(1)!) ?? 100.0;
      }
    }

    return studyu.FoodEntry.withId(
      entryType: studyu.FoodEntryType.brandedProduct,
      name: product.productName ?? 'Unknown Product',
      brandName: product.brands,
      description: product.genericName,
      amount: 1,
      unit: 'serving',
      servingSizeGrams: servingSizeGrams,
      portionReference: product.servingSize,
      portionEstimationMethod: studyu.PortionEstimationMethod.standardUnit,
      portionState: studyu.PortionState.asServed,
      yieldFactor: 1.0,
      nutrition: studyu.NutritionProfile(
        energyKcal: energyKcal,
        protein: protein,
        carbs: carbs,
        fat: fat,
        sugars: sugars,
        fiber: fiber,
        saturatedFat: saturatedFat,
        transFat: 0,
        cholesterol: 0,
        sodium: sodium,
        waterContent: 0,
        micros: {},
      ),
      foodCode: product.barcode,
      externalId: product.barcode,
      source: studyu.FoodSource.openfoodfacts,
      confidenceScore: 1.0,
      originalValues: product.toJson(),
    );
  }

  void _selectProduct(Product product) {
    _notifySelection(_convertToFoodEntry(product));
  }

  void _selectUsdaFood(UsdaFoodItem food) {
    _notifySelection(_convertUsdaToFoodEntry(food));
  }

  void _selectTemplate(studyu.SavedFoodTemplate template) {
    _notifySelection(template.prototype);
  }

  void _navigateToManualEntry() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FoodEntryScreen()),
    ).then((result) {
      if (result != null && mounted) {
        _notifySelection(result as studyu.FoodEntry);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Material(
        color: theme.colorScheme.surface,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Search foods', style: theme.textTheme.titleLarge),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
            const Divider(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search food (e.g., "apple")',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _openFoodFactsResults = [];
                              _usdaResults = [];
                              _templateResults = [];
                              _hasSearched = false;
                            });
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        tooltip: 'Scan Barcode',
                        onPressed: _scanBarcode,
                      ),
                    ],
                  ),
                ),
                onSubmitted: (_) => _searchFood(),
                onChanged: (_) => setState(() {}),
              ),
            ),
            Expanded(child: _buildResultsArea()),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsArea() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching databases...'),
          ],
        ),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'Search or Scan',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter food name or scan barcode to search across all databases.',
                style: TextStyle(color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_templateResults.isEmpty &&
        _openFoodFactsResults.isEmpty &&
        _usdaResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'No results found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Try a different term, scan a barcode, or create a custom food.',
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _navigateToManualEntry,
                icon: const Icon(Icons.edit),
                label: const Text('Enter Manually'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount:
          _templateResults.length +
          _openFoodFactsResults.length +
          _usdaResults.length +
          1,
      itemBuilder: (context, index) {
        if (index < _templateResults.length) {
          final template = _templateResults[index];
          return _buildTemplateCard(template)
              .animate(delay: (30 * index).ms)
              .fadeIn()
              .slideX(begin: 0.1, duration: 200.ms);
        }

        int adjustedIndex = index - _templateResults.length;
        if (adjustedIndex < _openFoodFactsResults.length) {
          final product = _openFoodFactsResults[adjustedIndex];
          return _buildProductCard(product)
              .animate(delay: (30 * index).ms)
              .fadeIn()
              .slideX(begin: 0.1, duration: 200.ms);
        }

        adjustedIndex -= _openFoodFactsResults.length;
        if (adjustedIndex < _usdaResults.length) {
          final food = _usdaResults[adjustedIndex];
          return _buildUsdaFoodCard(food)
              .animate(delay: (30 * index).ms)
              .fadeIn()
              .slideX(begin: 0.1, duration: 200.ms);
        }

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: OutlinedButton.icon(
              onPressed: _navigateToManualEntry,
              icon: const Icon(Icons.edit),
              label: const Text("Don't see your food? Enter Manually"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2);
      },
    );
  }

  Widget _buildTemplateCard(studyu.SavedFoodTemplate template) {
    final food = template.prototype;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _selectTemplate(template),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.star,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildNutrientBadge(
                          '${food.nutrition.energyKcal.round()}',
                          'kcal',
                          Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Your Template',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _selectTemplate(template),
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final nutriments = product.nutriments;
    final energyKcal =
        nutriments?.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams) ?? 0;
    final protein =
        nutriments?.getValue(Nutrient.proteins, PerSize.oneHundredGrams) ?? 0;
    final carbs =
        nutriments?.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams) ??
        0;
    final fat =
        nutriments?.getValue(Nutrient.fat, PerSize.oneHundredGrams) ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _selectProduct(product),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'product_img_${product.barcode}',
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    image: product.imageFrontSmallUrl != null
                        ? DecorationImage(
                            image: NetworkImage(product.imageFrontSmallUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: product.imageFrontSmallUrl == null
                      ? Icon(
                          Icons.fastfood,
                          color: Colors.grey.shade300,
                          size: 24,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName ?? 'Unknown Product',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    if (product.brands != null)
                      Text(
                        product.brands!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildNutrientBadge(
                          '${energyKcal.round()}',
                          'kcal',
                          Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        _buildNutrientBadge(
                          '${protein.round()}g',
                          'P',
                          Colors.blue,
                        ),
                        const SizedBox(width: 6),
                        _buildNutrientBadge(
                          '${carbs.round()}g',
                          'C',
                          Colors.green,
                        ),
                        const SizedBox(width: 6),
                        _buildNutrientBadge(
                          '${fat.round()}g',
                          'F',
                          Colors.purple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _selectProduct(product),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsdaFoodCard(UsdaFoodItem food) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _selectUsdaFood(food),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'USDA',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.description ?? 'Unknown Food',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (food.householdServingFullText != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        food.householdServingFullText!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildNutrientBadge(
                          '${food.energyKcal100g.round()}',
                          'kcal',
                          Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        _buildNutrientBadge(
                          '${food.protein100g.round()}g',
                          'P',
                          Colors.blue,
                        ),
                        const SizedBox(width: 6),
                        _buildNutrientBadge(
                          '${food.carbohydrates100g.round()}g',
                          'C',
                          Colors.green,
                        ),
                        const SizedBox(width: 6),
                        _buildNutrientBadge(
                          '${food.fat100g.round()}g',
                          'F',
                          Colors.purple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _selectUsdaFood(food),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientBadge(String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: value,
              style: TextStyle(
                color: color.withValues(alpha: 0.9),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
            TextSpan(
              text: unit,
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
