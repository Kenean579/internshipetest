import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../models/service_item.dart';
import '../../services/db_service.dart';
import '../../utils/styles.dart';
import 'request_form_screen.dart';
import 'package:intl/intl.dart';

class PublicHomeScreen extends StatefulWidget {
  const PublicHomeScreen({super.key});

  @override
  State<PublicHomeScreen> createState() => _PublicHomeScreenState();
}

class _PublicHomeScreenState extends State<PublicHomeScreen> {
  final DbService _db = DbService();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          _buildSliverCategoryFilter(),
          _buildSliverServicesList(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(Icons.auto_awesome,
                    color: Colors.white.withValues(alpha: 0.1), size: 150),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Browse Categories',
                        style: AppTextStyles.body.copyWith(
                            color: Colors.white70, letterSpacing: 1.2)),
                    Text('Service Catalog',
                        style: AppTextStyles.display.copyWith(
                            color: Colors.white, fontSize: 32, height: 1.1)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () => _showSearchSheet(context),
        ),
      ],
    );
  }

  Widget _buildSliverCategoryFilter() {
    return StreamBuilder<List<ServiceCategory>>(
      stream: _db.getCategories(),
      builder: (context, snapshot) {
        final rawCats = snapshot.data ?? [];
        final uniqueCats = <String, ServiceCategory>{};
        for (var c in rawCats) {
          if (c.status == 'active' && !uniqueCats.containsKey(c.title)) {
            uniqueCats[c.title] = c;
          }
        }
        final categories = uniqueCats.values.toList();

        return SliverToBoxAdapter(
          child: Container(
            height: 60,
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                final isAll = index == 0;
                final label = isAll ? 'All' : categories[index - 1].title;
                final isSelected = _selectedCategory == label;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (val) =>
                        setState(() => _selectedCategory = label),
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.primary.withValues(alpha: 0.1),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverServicesList() {
    return StreamBuilder<List<ServiceCategory>>(
      stream: _db.getCategories(),
      builder: (context, catSnapshot) {
        final rawCats = catSnapshot.data ?? [];
        final uniqueCats = <String, ServiceCategory>{};
        for (var c in rawCats) {
          if (c.status == 'active' && !uniqueCats.containsKey(c.title)) {
            uniqueCats[c.title] = c;
          }
        }
        final filteredCats = uniqueCats.values.toList();

        final displayingCats = _selectedCategory == 'All'
            ? filteredCats
            : filteredCats.where((c) => c.title == _selectedCategory).toList();

        if (displayingCats.isEmpty) {
          return const SliverFillRemaining(
            child: Center(child: Text('No categories available.')),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildCategorySection(displayingCats[index]);
              },
              childCount: displayingCats.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategorySection(ServiceCategory category) {
    return StreamBuilder<List<ServiceItem>>(
      stream: _db.getServices(categoryId: category.id),
      builder: (context, snapshot) {
        var services = snapshot.data ?? [];
        if (services.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12)),
                    child: category.iconUrl.isNotEmpty
                        ? Image.network(
                            category.iconUrl,
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                            errorBuilder: (c, e, s) => Icon(
                                Icons.star_outline_rounded,
                                color: AppColors.primary,
                                size: 20),
                          )
                        : Icon(Icons.star_outline_rounded,
                            color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(category.title,
                        style: AppTextStyles.subHeader.copyWith(fontSize: 20)),
                  ),
                ],
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: services.length,
              itemBuilder: (context, index) =>
                  _buildModernServiceCard(context, services[index]),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  void _showSearchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'What are you looking for?',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                onChanged: (v) {
                  setSheetState(() => _searchQuery = v.toLowerCase());
                },
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _searchQuery.isEmpty
                    ? _buildRecentSearchEmptyState()
                    : _buildSearchResults(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearchEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_rounded, size: 80, color: AppColors.border),
        const SizedBox(height: 16),
        Text('Search for anything',
            style: AppTextStyles.header
                .copyWith(fontSize: 18, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        const Text('Try "Plumbing" or "Hair Styling"',
            style: TextStyle(color: AppColors.textLight)),
      ],
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder<List<ServiceItem>>(
      stream: _db.getServices(),
      builder: (context, snapshot) {
        final services = (snapshot.data ?? [])
            .where((s) => s.serviceName.toLowerCase().contains(_searchQuery))
            .toList();

        if (services.isEmpty)
          return const Center(child: Text('No matching services found.'));

        return ListView.builder(
          itemCount: services.length,
          itemBuilder: (context, index) =>
              _buildModernServiceCard(context, services[index], isGrid: false),
        );
      },
    );
  }

  Widget _buildModernServiceCard(BuildContext context, ServiceItem service,
      {bool isGrid = true}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.shadowSm,
      ),
      child: InkWell(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => RequestFormScreen(service: service))),
        borderRadius: BorderRadius.circular(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: isGrid ? 3 : 0,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                child: Stack(
                  children: [
                    Image.network(
                      service.imageUrl ?? 'https://picsum.photos/400/300',
                      height: isGrid ? double.infinity : 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: AppColors.background,
                        child: const Icon(Icons.image_outlined,
                            color: AppColors.textLight, size: 40),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: AppColors.shadowSm),
                        child: Text(
                          'ETB ${NumberFormat('#,##0').format(service.totalPrice)}',
                          style: const TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w900,
                              fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.serviceName,
                      style: AppTextStyles.subHeader.copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  if (!isGrid)
                    Text(service.description,
                        style: AppTextStyles.bodySecondary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.flash_on,
                          color: AppColors.primary, size: 14),
                      const SizedBox(width: 4),
                      const Text('Book Now',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
