import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/customer_model.dart';
import '../providers/cart_provider.dart';
import '../providers/sales_provider.dart';

class ConfirmFiadoDialog extends StatefulWidget {
  final Customer customer;
  final String notes;

  const ConfirmFiadoDialog({
    super.key,
    required this.customer,
    required this.notes,
  });

  @override
  State<ConfirmFiadoDialog> createState() => _ConfirmFiadoDialogState();
}

class _ConfirmFiadoDialogState extends State<ConfirmFiadoDialog> {
  DateTime? _selectedDate;
  var _isLoading = false;

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return AlertDialog(
      title: const Text('Confirmar Venda Fiado'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Cliente: ${widget.customer.name}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Valor Total: R\$ ${cart.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(height: 24),
          const Text('Definir data de vencimento:'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                _selectedDate == null
                    ? 'Nenhuma data'
                    : DateFormat('dd/MM/yyyy').format(_selectedDate!),
              ),
              TextButton(
                onPressed: _presentDatePicker,
                child: const Text('Escolher Data'),
              ),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: (_selectedDate == null || _isLoading)
              ? null
              : () async {
            setState(() => _isLoading = true);

            final salesProvider = Provider.of<SalesProvider>(context, listen: false);



            try {
              await salesProvider.addOrder(
                cartProducts: cart.items.values.toList(),
                total: cart.totalAmount,
                customer: widget.customer,
                dueDate: _selectedDate!,
                notes: widget.notes,
              );

              // Se a venda for um sucesso:
              cart.clear();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Venda finalizada com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Fecha TUDO e volta para a tela de vendas
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            } catch (e) {
              // --- LÓGICA DE ERRO MELHORADA ---
              if (mounted) {
                // Fecha TUDO primeiro para não deixar o usuário preso
                Navigator.of(context).popUntil((route) => route.isFirst);

                // Depois mostra a mensagem de erro clara
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('ERRO: ${e.toString().replaceAll('Exception: ', '')}'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5), // Mais tempo para ler
                  ),
                );
              }
            } finally {
              if (mounted) {
                setState(() => _isLoading = false);
              }
            }
          },
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Confirmar Venda'),
        ),
      ],
    );
  }
}