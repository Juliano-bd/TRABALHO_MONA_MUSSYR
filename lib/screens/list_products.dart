import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/product_service.dart';
import '../providers/cart_provider.dart';
import 'add_product.dart';
import 'cart_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductService _service = ProductService();
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _service.getProducts();
      setState(() {
        _allProducts = products;
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterProducts(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((p) {
        final nameMatch = p.name.toLowerCase().contains(lowerQuery);
        final categoryMatch = p.category.toLowerCase().contains(lowerQuery);
        return nameMatch || categoryMatch;
      }).toList();
    });
  }

  Widget _buildFallbackIcon() {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Icon(Icons.spa, size: 40, color: Colors.grey[800]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SECRET DESIRE', 
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 3, color: Colors.white)
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) => Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Badge(
                label: Text(cart.totalItemCount.toString()),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                isLabelVisible: cart.items.isNotEmpty,
                child: IconButton(
                  icon: const Icon(Icons.shopping_bag, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartScreen()),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'O que você deseja hoje?',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
              ),
              onChanged: _filterProducts,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F)))
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: product.imageUrl.isNotEmpty
                                    ? Image.network(
                                        product.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => _buildFallbackIcon(),
                                      )
                                    : _buildFallbackIcon(),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold, 
                                            color: Colors.white,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          product.category.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10, 
                                            color: Theme.of(context).colorScheme.secondary,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          currency.format(product.price),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900, 
                                            color: Colors.white,
                                            fontSize: 16
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Provider.of<CartProvider>(context, listen: false).addToCart(product);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: const Text('Item adicionado com discrição!'),
                                                backgroundColor: const Color(0xFFD32F2F),
                                                duration: const Duration(seconds: 1),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFD32F2F),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.favorite, size: 18, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD32F2F),
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductFormScreen()),
          );
          if (result == true) _loadProducts();
        },
      ),
    );
  }
}