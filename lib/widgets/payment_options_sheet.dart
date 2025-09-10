import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tienda_model/models/customer_model.dart';
import 'package:tienda_model/widgets/confirm_fiado_dialog.dart';

import '../providers/cart_provider.dart';
import '../providers/cash_flow_provider.dart';
import '../providers/sales_provider.dart';

class PaymentOptionsSheet extends StatefulWidget {
  final String notes;
  const PaymentOptionsSheet({super.key, required this.notes});

  @override
  State<PaymentOptionsSheet> createState() => _PaymentOptionsSheetState();
}

class _PaymentOptionsSheetState extends State<PaymentOptionsSheet> {
  var _isLoading = false;
  bool _fiadoIsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadFiadoPreference();
  }

  Future<void> _loadFiadoPreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _fiadoIsEnabled = prefs.getBool('fiado_enabled') ?? false;
      });
    }
  }

  // Função para lidar com vendas à vista e dar feedback ao usuário
  Future<void> _handleInstantSale(String paymentMethod) async {
    // Evita cliques múltiplos
    if (_isLoading) return;

    setState(() => _isLoading = true);
    final cart = Provider.of<CartProvider>(context, listen: false);
    final sales = Provider.of<SalesProvider>(context, listen: false);
    final cashFlow = Provider.of<CashFlowProvider>(context, listen: false);

    try {
      await sales.addInstantSale(
        cartProducts: cart.items.values.toList(),
        total: cart.totalAmount,
        paymentMethod: paymentMethod,
        cashFlow: cashFlow,
        notes: widget.notes,
      );
      cart.clear();
      if (mounted) {
        // Fecha tudo e volta para a tela de vendas
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Venda finalizada com sucesso!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        // Fecha tudo e volta para a tela de vendas, mesmo em caso de erro
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ERRO: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
    // Não precisamos do finally aqui, pois a tela será removida
  }

  // Função para mostrar o diálogo do PIX
  void _showPixDialog() {
    // Não fechamos o painel de opções aqui.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Pagar com PIX'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Escaneie o QR Code para efetuar o pagamento.'),
            const SizedBox(height: 20),
            Image.asset('assets/images/pix_qrcode.png'),
          ],
        ),
        actions: [
          ElevatedButton(
            child: const Text("Pagamento Concluído"),
            onPressed: () {
              // 1. Fecha o diálogo do PIX
              Navigator.of(dialogContext).pop();
              // 2. Chama a função que finaliza a venda e fecha o resto
              _handleInstantSale('PIX');
            },
          ),
        ],
      ),
    );
  }

  void _showCustomerSelectionDialog(String notes) {
    // Fecha o painel de opções antes de abrir o diálogo de clientes
    Navigator.of(context).pop();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Selecionar Cliente'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(user.uid).collection('customers').orderBy('name').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Nenhum cliente cadastrado.'));
                }
                final customersDocs = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: customersDocs.length,
                  itemBuilder: (context, index) {
                    final customerData = customersDocs[index].data() as Map<String, dynamic>;
                    final customer = Customer(
                      id: customersDocs[index].id,
                      name: customerData['name'] ?? 'Sem nome',
                      phone: customerData['phone'] ?? '',
                    );

                    print('RASTREAMENTO 1 - ID na seleção: ${customer.id}');

                    return ListTile(
                      title: Text(customer.name),
                      // DENTRO DE _showCustomerSelectionDialog

                      onTap: () {
                        final customer = Customer(
                          id: customersDocs[index].id,
                          name: customerData['name'] ?? 'Sem nome',
                          phone: customerData['phone'] ?? '',
                        );
                        print('RASTREAMENTO 1 - ID na seleção: ${customer.id}');

                        // 1. Primeiro, mandamos fechar o diálogo atual.
                        Navigator.of(ctx).pop();
                        showDialog(
                          context: context,
                          // Passe o cliente E as 'notes'
                          builder: (context) => ConfirmFiadoDialog(customer: customer, notes: notes),
                        );

                        // 2. Em seguida, agendamos a abertura do novo diálogo para DEPOIS
                        // que a renderização atual (o 'pop') terminar.
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          // Verificação de segurança para garantir que a tela ainda existe
                          if (context.mounted) {
                            showDialog(
                              context: context,
                              builder: (context) => ConfirmFiadoDialog(
                                customer: customer,
                                notes: notes, // <-- Adicione este argumento
                              ),
                            );
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        runSpacing: 10,
        children: <Widget>[
          const Text('Escolha a forma de pagamento', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10, width: double.infinity),
          ListTile(
            leading: const Icon(Icons.money, size: 30, color: Colors.green),
            title: const Text('Dinheiro', style: TextStyle(fontSize: 18)),
            onTap: () => _handleInstantSale('Dinheiro'),
          ),
          ListTile(
            leading: const Icon(Icons.credit_card, size: 30, color: Colors.blueAccent),
            title: const Text('Cartão', style: TextStyle(fontSize: 18)),
            onTap: () => _handleInstantSale('Cartão'),
          ),
          ListTile(
            leading: const Icon(Icons.pix, size: 30, color: Colors.cyan),
            title: const Text('PIX', style: TextStyle(fontSize: 18)),
            onTap: _showPixDialog,
          ),

          if (_fiadoIsEnabled) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_add_alt_1, size: 30, color: Colors.orange),
              title: const Text('Fiado / A Prazo', style: TextStyle(fontSize: 18)),
              onTap: () => _showCustomerSelectionDialog(widget.notes),
            ),
          ],
        ],
      ),
    );
  }
}