mport 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:user_needs/services/cart_service.dart';
import 'package:user_needs/services/order_service.dart';
import 'package:user_needs/services/address_service.dart';
import 'package:user_needs/widgets/cart_item_card.dart';
import 'package:user_needs/theme.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartService = context.watch<CartService>();
    final orderService = context.watch<OrderService>();
    final addressService = context.watch<AddressService>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart', style: context.textStyles.titleLarge?.bold),
        actions: [
          if (cartService.items.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Cart'),
                    content: const Text('Are you sure you want to remove all items?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          cartService.clearCart();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Clear', style: TextStyle(color: LightModeColors.lightError)),
                      ),
                    ],
                  ),
                );
              },
              child: Text(
                'Clear All',
                style: context.textStyles.titleSmall?.copyWith(
                  color: LightModeColors.lightError,
                ),
              ),
            ),
        ],
      ),
      body: cartService.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: LightModeColors.lightOnSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Your cart is empty',
                    style: context.textStyles.titleLarge?.copyWith(
                      color: LightModeColors.lightOnSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LightModeColors.lightPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shopping_bag, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Start Shopping',
                          style: context.textStyles.titleMedium?.bold.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: AppSpacing.paddingLg,
              children: cartService.items.map((item) {
                return CartItemCard(
                  item: item,
                  onQuantityChanged: (newQuantity) {
                    cartService.updateQuantity(item.id, newQuantity);
                  },
                  onRemove: () => cartService.removeFromCart(item.id),
                );
              }).toList(),
            ),
      bottomNavigationBar: cartService.items.isEmpty
          ? null
          : Container(
              padding: AppSpacing.paddingLg,
              decoration: BoxDecoration(
                color: LightModeColors.lightSurface,
                boxShadow: [
                  BoxShadow(
                    color: LightModeColors.lightShadow.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal (${cartService.itemCount} items)',
                          style: context.textStyles.titleMedium,
                        ),
                        Text(
                          '\$${cartService.totalAmount.toStringAsFixed(2)}',
                          style: context.textStyles.titleMedium?.semiBold,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Shipping',
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: LightModeColors.lightOnSurfaceVariant,
                          ),
                        ),
                        Text(
                          cartService.totalAmount >= 50 ? 'FREE' : '\$5.99',
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: cartService.totalAmount >= 50 ? Colors.green : LightModeColors.lightOnSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: context.textStyles.titleLarge?.bold,
                        ),
                        Text(
                          '\$${(cartService.totalAmount + (cartService.totalAmount >= 50 ? 0 : 5.99)).toStringAsFixed(2)}',
                          style: context.textStyles.titleLarge?.copyWith(
                            color: LightModeColors.lightPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final defaultAddress = addressService.defaultAddress;
                          if (defaultAddress == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please add a delivery address')),
                            );
                            return;
                          }

                          final orderId = await orderService.createOrder(
                            userId: 'user1',
                            items: cartService.items,
                            totalAmount: cartService.totalAmount + (cartService.totalAmount >= 50 ? 0 : 5.99),
                            deliveryAddress: defaultAddress.fullAddress,
                          );

                          await cartService.clearCart();

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Order placed successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            context.go('/orders');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: LightModeColors.lightPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.payment, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Proceed to Checkout',
                              style: context.textStyles.titleMedium?.bold.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
