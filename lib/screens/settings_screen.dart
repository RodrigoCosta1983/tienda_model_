// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _fiadoEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFiadoPreference();
  }

  // Carrega a preferência salva no dispositivo de forma segura
  Future<void> _loadFiadoPreference() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _fiadoEnabled = prefs.getBool('fiado_enabled') ?? false;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar configurações: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Salva a preferência quando o usuário muda o interruptor
  Future<void> _saveFiadoPreference(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _fiadoEnabled = value;
      });
      await prefs.setBool('fiado_enabled', value);
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuração salva!'), duration: Duration(seconds: 1)),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar configuração: $error')),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
      // 👇 ADICIONE ESTE NOVO ITEM AQUI 👇
      ListTile(
      leading: const Icon(Icons.person_outline),
      title: const Text('Minha Conta'),
      //subtitle: const Text('Edite seus dados pessoais ou da empresa.'),
        subtitle: const Text('Dados pessoais e Segurança.'),

      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (ctx) => const ProfileScreen()),
        );
      },
    ),

          const Divider(height: 20, indent: 16, endIndent: 16),
          SwitchListTile(
            title: const Text('Habilitar Vendas "Fiado"'),
            subtitle: const Text('Permite registrar vendas a prazo para clientes.'),
            value: _fiadoEnabled,
            onChanged: _saveFiadoPreference,
            secondary: const Icon(Icons.receipt_long_outlined),
          ),
        ],
      ),
    );
  }
}