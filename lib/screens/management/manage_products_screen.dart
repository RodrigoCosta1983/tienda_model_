import 'dart:io';
import 'package:flutter/foundation.dart'; // Importante para o 'kIsWeb'
import 'dart:typed_data'; // Importante para os bytes da imagem na web
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Diálogo para Adicionar/Editar Produto
class _ProductDialog extends StatefulWidget {
  final DocumentSnapshot? product;
  const _ProductDialog({this.product});

  @override
  _ProductDialogState createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _minimumStockController = TextEditingController();
  var _isLoading = false;

  // Variáveis de estado para a imagem (Multiplataforma)
  File? _selectedImageFile; // Para mobile (Android/iOS)
  Uint8List? _selectedImageBytes; // Para Web
  String? _existingImageUrl;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final productData = widget.product!.data() as Map<String, dynamic>;
      _nameController.text = productData['name'];
      _priceController.text = productData['price'].toString();
      _quantityController.text = (productData['quantity'] ?? 0).toString();
      _minimumStockController.text = (productData['minimumStock'] ?? 0).toString();
      if (productData.containsKey('imageUrl')) {
        _existingImageUrl = productData['imageUrl'];
      }
    }
  }

  // Lógica de seleção de imagem (Multiplataforma)
  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50, maxWidth: 600);
    if (pickedImage == null) return;

    if (kIsWeb) {
      _selectedImageBytes = await pickedImage.readAsBytes();
    } else {
      _selectedImageFile = File(pickedImage.path);
    }
    setState(() {});
  }

  // Lógica para salvar o produto (Multiplataforma)
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    // Verificação anti-duplicidade (somente ao criar)
    if (!_isEditing) {
      final user = FirebaseAuth.instance.currentUser!;
      final name = _nameController.text;
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users').doc(user.uid)
          .collection('products')
          .where('name_lowercase', isEqualTo: name.toLowerCase())
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: Um produto com o nome "$name" já existe.'), backgroundColor: Colors.red),
          );
        }
        return;
      }
    }

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    final String name = _nameController.text;
    final double price = double.parse(_priceController.text);
    final int quantity = int.tryParse(_quantityController.text) ?? 0;
    final int minimumStock = int.tryParse(_minimumStockController.text) ?? 0;
    String imageUrl = _existingImageUrl ?? '';

    try {
      if (_selectedImageFile != null || _selectedImageBytes != null) {
        final ref = FirebaseStorage.instance.ref().child('product_images').child(user.uid).child('${DateTime.now().toIso8601String()}.jpg');

        if (kIsWeb) {
          await ref.putData(_selectedImageBytes!);
        } else {
          await ref.putFile(_selectedImageFile!);
        }
        imageUrl = await ref.getDownloadURL();
      }

      final productData = {
        'name': name,
        'name_lowercase': name.toLowerCase(),
        'price': price,
        'quantity': quantity,
        'minimumStock': minimumStock,
        'imageUrl': imageUrl,
      };

      if (_isEditing) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('products').doc(widget.product!.id).update(productData);
      } else {
        productData['createdAt'] = Timestamp.now();
        await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('products').add(productData);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar produto: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _minimumStockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lógica para decidir qual imagem mostrar na UI
    ImageProvider? provider;
    if (_selectedImageBytes != null) {
      provider = MemoryImage(_selectedImageBytes!);
    } else if (_selectedImageFile != null) {
      provider = FileImage(_selectedImageFile!);
    } else if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
      provider = NetworkImage(_existingImageUrl!);
    }

    return AlertDialog(
      title: Text(_isEditing ? 'Editar Produto' : 'Adicionar Novo Produto'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: provider,
                child: (provider == null)
                    ? const Icon(Icons.inventory_2, size: 40, color: Colors.grey)
                    : null,
              ),
              TextButton.icon(
                icon: const Icon(Icons.image_search),
                label: Text(_isEditing ? 'Alterar Imagem' : 'Selecionar Imagem'),
                onPressed: _pickImage,
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome do Produto'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor, insira um nome.';
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Preço (ex: 10.50)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor, insira um preço.';
                  if (double.tryParse(value) == null) return 'Por favor, insira um número válido.';
                  return null;
                },
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantidade em Estoque'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor, insira a quantidade.';
                  if (int.tryParse(value) == null || int.parse(value) < 0) return 'Insira um número válido.';
                  return null;
                },
              ),
              TextFormField(
                controller: _minimumStockController,
                decoration: const InputDecoration(labelText: 'Estoque Mínimo para Alerta'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Defina um estoque mínimo.';
                  if (int.tryParse(value) == null || int.parse(value) < 0) return 'Insira um número válido.';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _isLoading ? null : () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveProduct,
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Salvar'),
        ),
      ],
    );
  }
}

// A tela principal de gerenciamento de produtos (sem alterações aqui)
class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showProductDialog(BuildContext context, {DocumentSnapshot? product}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ProductDialog(product: product),
    );
  }

  void _deleteProduct(BuildContext context, String productId, String productName) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Você tem certeza que deseja excluir o produto "$productName"?'),
        actions: [
          TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(ctx).pop()),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Excluir'),
            onPressed: () {
              FirebaseFirestore.instance.collection('users').doc(user.uid).collection('products').doc(productId).delete();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(body: Center(child: Text('Erro: Nenhum usuário logado.')));
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Query query = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('products');

    if (_searchQuery.isNotEmpty) {
      final searchQueryLower = _searchQuery.toLowerCase();
      query = query
          .where('name_lowercase', isGreaterThanOrEqualTo: searchQueryLower)
          .where('name_lowercase', isLessThanOrEqualTo: '$searchQueryLower\uf8ff')
          .orderBy('name_lowercase');
    } else {
      query = query.orderBy('createdAt', descending: true);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Gerenciar Produtos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showProductDialog(context),
          ),
        ],
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar por nome...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                          : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).cardColor.withOpacity(0.85),
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: query.snapshots(),
                    builder: (ctx, productSnapshot) {
                      if (productSnapshot.hasError) return const Center(child: Text('Ocorreu um erro!'));
                      if (productSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final productDocs = productSnapshot.data?.docs ?? [];
                      if (productDocs.isEmpty) return const Center(child: Text('Nenhum produto encontrado.'));

                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 4),
                        itemCount: productDocs.length,
                        itemBuilder: (ctx, index) {
                          final productDocument = productDocs[index];
                          final productData = productDocument.data() as Map<String, dynamic>;
                          final price = productData.containsKey('price') ? productData['price'] as num : 0.0;
                          final productName = productData['name'] ?? 'Nome indisponível';
                          final imageUrl = productData['imageUrl'] as String?;
                          final quantity = productData['quantity'] as int? ?? 0;
                          final minimumStock = productData['minimumStock'] as int? ?? 0;

                          final bool needsRestock = quantity <= minimumStock;

                          return Card(
                            color: needsRestock
                                ? Colors.black.withOpacity(0.85)
                                : Theme.of(context).cardColor.withOpacity(0.9),
                            shape: needsRestock
                                ? RoundedRectangleBorder(
                              side: BorderSide(color: Colors.redAccent, width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                            )
                                : null,
                            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey.shade300,
                                backgroundImage: (imageUrl != null && imageUrl.isNotEmpty) ? NetworkImage(imageUrl) : null,
                                child: (imageUrl == null || imageUrl.isEmpty) ? const Icon(Icons.inventory_2_outlined, color: Colors.white70) : null,
                              ),
                              title: Text(productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                needsRestock
                                    ? 'Em estoque: $quantity (Mín: $minimumStock)'
                                    : 'Em estoque: $quantity',
                                style: TextStyle(
                                  color: needsRestock ? Colors.amber.shade900 : null,
                                  fontWeight: needsRestock ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (needsRestock)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                                    ),
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                                    onPressed: () => _showProductDialog(context, product: productDocument),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                                    onPressed: () => _deleteProduct(context, productDocument.id, productName),
                                  ),
                                ],
                              ),
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
        ],
      ),
    );
  }
}