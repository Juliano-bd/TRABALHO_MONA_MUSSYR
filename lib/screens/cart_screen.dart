import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/cart_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _couponController = TextEditingController();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();
  }

  void _setupFirebaseMessaging() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${message.notification!.title}: ${message.notification!.body}'),
              backgroundColor: const Color(0xFFD32F2F),
            ),
          );
        }
      });
    }
  }

  Widget _buildSummaryRow(String label, double value, NumberFormat currency, {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
            color: Colors.white70,
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal
          )),
          Text(
            currency.format(value),
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.greenAccent : (isTotal ? const Color(0xFFD32F2F) : Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sacola de Desejos'),
      ),
      body: Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? const Center(child: Text('Sua sacola está vazia.', style: TextStyle(color: Colors.grey)))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(4),
                              image: item.product.imageUrl.isNotEmpty
                                  ? DecorationImage(image: NetworkImage(item.product.imageUrl), fit: BoxFit.cover)
                                  : null,
                            ),
                            child: item.product.imageUrl.isEmpty 
                                ? const Icon(Icons.spa, color: Colors.grey) 
                                : null,
                          ),
                          title: Text(item.product.name, style: const TextStyle(color: Colors.white)),
                          subtitle: Text(currency.format(item.product.price), style: TextStyle(color: Colors.grey[400])),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, color: Colors.white),
                                onPressed: () => cart.decrementQuantity(item.product.id),
                              ),
                              Text('${item.quantity}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add, color: Colors.white),
                                onPressed: () => cart.incrementQuantity(item.product.id),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Color(0xFFD32F2F)),
                                onPressed: () => cart.removeItem(item.product.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _couponController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Cupom (ex: AMOR10)',
                          prefixIcon: Icon(Icons.local_offer, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white10,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        cart.applyCoupon(_couponController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(cart.couponApplied ? 'Cupom aplicado com sucesso!' : 'Cupom inválido'),
                            backgroundColor: cart.couponApplied ? Colors.green : Colors.red,
                          ),
                        );
                      },
                      child: const Text('Aplicar'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSummaryRow('Subtotal:', cart.subtotal, currency),
                _buildSummaryRow('Frete Discreto:', cart.shippingCost, currency),
                _buildSummaryRow('Desconto:', -cart.discount, currency, isDiscount: true),
                const Divider(color: Colors.grey),
                _buildSummaryRow('TOTAL:', cart.total, currency, isTotal: true),
                
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    minimumSize: const Size(double.infinity, 55),
                    elevation: 5,
                  ),
                  onPressed: () async {
                    cart.clearCart();
                    String? token = await _firebaseMessaging.getToken(
                      vapidKey: "BIak-Tqra99UXdmjhYXprlu4Capk6d2f-iLclM_5AWlaxKGArj8YAG_yTTjtCSwiCzBP868PAU0Ig-pSSTpzFUE", 
                    );
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: const Color(0xFF2C2C2C),
                          title: const Text('Pedido Confirmado!', style: TextStyle(color: Colors.white)),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Enviaremos uma notificação discreta quando sair para entrega.',
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 10),
                              Text('Token: $token', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK', style: TextStyle(color: Colors.white)))
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text('FINALIZAR COMPRA SEGURA'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}