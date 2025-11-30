import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_needs/services/order_service.dart';
import 'package:user_needs/widgets/order_card.dart';
import 'package:user_needs/theme.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderService = context.watch<OrderService>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders', style: context.textStyles.titleLarge?.bold),
      ),
      body: orderService.orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: LightModeColors.lightOnSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'No orders yet',
                    style: context.textStyles.titleLarge?.copyWith(
                      color: LightModeColors.lightOnSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Your order history will appear here',
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: LightModeColors.lightOnSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: AppSpacing.paddingLg,
              itemCount: orderService.orders.length,
              itemBuilder: (context, index) {
                final order = orderService.orders[index];
                return OrderCard(
                  order: order,
                  onTap: () => _showOrderDetails(context, order),
                );
              },
            ),
    );
  }

  void _showOrderDetails(BuildContext context, order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: LightModeColors.lightSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: LightModeColors.lightOnSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: AppSpacing.paddingLg,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order Details',
                      style: context.textStyles.titleLarge?.bold,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                      color: LightModeColors.lightOnSurface,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: AppSpacing.paddingLg,
                  children: [
                    Text(
                      'Order #${order.id.substring(order.id.length - 8)}',
                      style: context.textStyles.titleMedium?.semiBold,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Placed on ${_formatDate(order.createdAt)}',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: LightModeColors.lightOnSurfaceVariant,
                      ),
                    ),
                    if (order.trackingNumber != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Tracking: ${order.trackingNumber}',
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: LightModeColors.lightPrimary,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    const Divider(),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Items',
                      style: context.textStyles.titleMedium?.semiBold,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ...order.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                                child: Image.asset(
                                  item.product.imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 60,
                                    height: 60,
                                    color: LightModeColors.lightSurfaceVariant,
                                    child: const Icon(Icons.image),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: context.textStyles.titleSmall?.semiBold,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Qty: ${item.quantity}',
                                      style: context.textStyles.bodySmall?.copyWith(
                                        color: LightModeColors.lightOnSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '\$${item.totalPrice.toStringAsFixed(2)}',
                                style: context.textStyles.titleSmall?.semiBold,
                              ),
                            ],
                          ),
                        )),
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style: context.textStyles.titleLarge?.bold,
                        ),
                        Text(
                          '\$${order.totalAmount.toStringAsFixed(2)}',
                          style: context.textStyles.titleLarge?.copyWith(
                            color: LightModeColors.lightPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Delivery Address',
                      style: context.textStyles.titleMedium?.semiBold,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      order.deliveryAddress,
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: LightModeColors.lightOnSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
