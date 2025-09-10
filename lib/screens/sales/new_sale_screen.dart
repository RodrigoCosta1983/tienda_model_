import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tienda_model/screens/settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../cart/cart_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../management/manage_customers_screen.dart';
import '../management/manage_products_screen.dart';
import '../reports/abc_report_screen.dart';
import '../reports/customer_report_screen.dart';
import '../reports/reports_hub_screen.dart';
import '../sales/sales_history_screen.dart';

class NewSaleScreen extends StatefulWidget {
  NewSaleScreen({super.key});

  @override
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  String _appVersion = 'Carregando...';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = info.version;
      });
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível abrir o link: $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(body: Center(child: Text("Erro: Nenhum usuário logado.")));
    }
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Nova Venda'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, _) => Badge(
              label: Text(cart.items.length.toString()),
              isLabelVisible: cart.itemCount > 0,
              child: IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => const CartScreen()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Gelo Gestor', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const DashboardScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Histórico de Vendas'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const SalesHistoryScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics_outlined),
              title: const Text('Análises e Relatórios'),
              onTap: () {
                Navigator.of(context).pop(); // Fecha o drawer
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const ReportsHubScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Gerenciar Produtos'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const ManageProductsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Gerenciar Clientes'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const ManageCustomersScreen()),
                );
              },
            ),


            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_outlined), // Ícone de engrenagem
              title: const Text('Configurações'),
              onTap: () {
                // 1. Fecha o menu lateral para uma transição suave
                Navigator.of(context).pop();

                // 2. Navega para a nova tela de configurações
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("Sobre"),
              onTap: () {
                final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                final Color textColor = isDarkMode ? Colors.white70 : Colors.black54;
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Sobre o aplicativo"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Este é um app de gestão para distribuidoras de gelo, desenvolvido por RodrigoCosta-DEV."),
                        const SizedBox(height: 20),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.link),
                          title: const Text("rodrigocosta-dev.com"),
                          onTap: () => _launchURL('http://rodrigocosta-dev.com'),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text(
                              'Versão do App: $_appVersion',
                              style: TextStyle(fontSize: 14, color: textColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        child: const Text("Fechar"),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () {
                FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: isDarkMode ? 0.4 : 0.15,
              child: Image.asset(
                isDarkMode
                    ? 'assets/backgrounds/background_light.png'
                    : 'assets/images/background_dark.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                int crossAxisCount = 2;
                double childAspectRatio = 1 / 1.15;

                if (screenWidth > 1200) {
                  crossAxisCount = 5;
                  childAspectRatio = 1 / 1.2;
                } else if (screenWidth > 800) {
                  crossAxisCount = 4;
                  childAspectRatio = 1 / 1.1;
                } else if (screenWidth > 600) {
                  crossAxisCount = 3;
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users').doc(user.uid)
                      .collection('products')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (ctx, productSnapshot) {
                    if (productSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (productSnapshot.hasError) {
                      return const Center(child: Text('Erro ao carregar produtos.'));
                    }
                    final productDocs = productSnapshot.data?.docs ?? [];
                    if (productDocs.isEmpty) {
                      return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('Nenhum produto cadastrado. Adicione produtos em "Gerenciar Produtos".', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                          )
                      );
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(10.0),
                      itemCount: productDocs.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: childAspectRatio,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (ctx, i) {
                        final productData = productDocs[i].data() as Map<String, dynamic>;
                        final imageUrl = productData['imageUrl'] as String?;
                        final product = Product(
                          id: productDocs[i].id,
                          name: productData['name'] ?? 'Produto sem nome',
                          price: (productData['price'] as num).toDouble(),
                          imageUrl: imageUrl ?? '',
                        );
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          clipBehavior: Clip.antiAlias,
                          color: Theme.of(context).cardColor.withOpacity(0.9),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Expanded(
                                child: (imageUrl != null && imageUrl.isNotEmpty)
                                    ? ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    loadingBuilder: (ctx, child, progress) {
                                      if (progress == null) return child;
                                      return const Center(child: CircularProgressIndicator());
                                    },
                                    errorBuilder: (ctx, err, stack) {
                                      return Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey));
                                    },
                                  ),
                                )
                                    : Center(
                                  child: Icon(Icons.ac_unit, size: 50, color: Theme.of(context).primaryColor.withOpacity(0.5)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  product.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                                child: Text(
                                  'R\$ ${product.price.toStringAsFixed(2)}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                                  label: const Text('Adicionar'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () {
                                    Provider.of<CartProvider>(context, listen: false).addItem(product);
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${product.name} adicionado ao carrinho!'),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}