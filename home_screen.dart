import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:user_needs/services/product_service.dart';
import 'package:user_needs/services/category_service.dart';
import 'package:user_needs/services/cart_service.dart';
import 'package:user_needs/widgets/product_card.dart';
import 'package:user_needs/widgets/banner_card.dart';
import 'package:user_needs/widgets/category_chip.dart';
import 'package:user_needs/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final productService = context.watch<ProductService>();
    final categoryService = context.watch<CategoryService>();
    final cartService = context.watch<CartService>();
    
    final products = _selectedCategoryId == null
        ? productService.products
        : productService.getProductsByCategory(_selectedCategoryId!);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [LightModeColors.lightPrimary, LightModeColors.lightTertiary],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(Icons.shopping_bag, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'User Needs',
                    style: context.textStyles.titleLarge?.bold,
                  ),
                ],
              ),
              actions: [
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined),
                      onPressed: () => context.go('/cart'),
                      color: LightModeColors.lightOnSurface,
                    ),
                    if (cartService.itemCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: LightModeColors.lightSecondary,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            '${cartService.itemCount}',
                            style: context.textStyles.labelSmall?.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () {},
                  color: LightModeColors.lightOnSurface,
                ),
              ],
            ),
            SliverPadding(
              padding: AppSpacing.paddingMd,
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    padding: AppSpacing.paddingMd,
                    decoration: BoxDecoration(
                      color: LightModeColors.lightSurface,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: LightModeColors.lightOutline),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: LightModeColors.lightOnSurfaceVariant),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Search products...',
                            style: context.textStyles.bodyMedium?.copyWith(
                              color: LightModeColors.lightOnSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    height: 140,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        BannerCard(
                          title: 'Special Offers',
                          subtitle: 'Up to 50% off',
                          backgroundColor: LightModeColors.lightSecondary,
                          textColor: Colors.white,
                          imageUrl: 'assets/images/special_offer_null_1764268163120.png',
                        ),
                        BannerCard(
                          title: 'Student Deals',
                          subtitle: 'Extra 10% discount',
                          backgroundColor: LightModeColors.lightTertiary,
                          textColor: Colors.white,
                        ),
                        BannerCard(
                          title: 'Free Shipping',
                          subtitle: 'On orders over \$50',
                          backgroundColor: LightModeColors.lightPrimary,
                          textColor: Colors.white,
                          imageUrl: 'assets/images/shopping_banner_null_1764268162201.png',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Categories',
                    style: context.textStyles.titleLarge?.bold,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        CategoryChip(
                          label: 'All',
                          icon: Icons.apps,
                          isSelected: _selectedCategoryId == null,
                          onTap: () => setState(() => _selectedCategoryId = null),
                        ),
                        const SizedBox(width: 8),
                        ...categoryService.categories.map((category) {
                          final iconData = _getIconData(category.icon);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CategoryChip(
                              label: category.name,
                              icon: iconData,
                              isSelected: _selectedCategoryId == category.id,
                              onTap: () => setState(() => _selectedCategoryId = category.id),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Featured Products',
                        style: context.textStyles.titleLarge?.bold,
                      ),
                      TextButton(
                        onPressed: () => context.go('/products'),
                        child: Text(
                          'See All',
                          style: context.textStyles.titleSmall?.copyWith(
                            color: LightModeColors.lightPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () => context.push('/product/${product.id}'),
                    );
                  },
                  childCount: products.length,
                ),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: AppSpacing.xl)),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'phone_android': return Icons.phone_android;
      case 'laptop': return Icons.laptop;
      case 'headphones': return Icons.headphones;
      case 'watch': return Icons.watch;
      case 'tablet': return Icons.tablet;
      case 'camera_alt': return Icons.camera_alt;
      case 'more_horiz': return Icons.more_horiz;
      default: return Icons.category;
    }
  }
}
