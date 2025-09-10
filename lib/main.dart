import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tienda_model/providers/cart_provider.dart';
import 'package:tienda_model/providers/sales_provider.dart';
import 'package:tienda_model/providers/cash_flow_provider.dart';
import 'package:tienda_model/screens/splash_screen.dart'; // Importe a SplashScreen
import 'package:tienda_model/themes/app_theme.dart';

// A função main agora fica mais simples
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // A lógica de pré-carregar as imagens continua aqui
  bool _imagesPrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesPrecached) {
      _precacheImages(context);
      _imagesPrecached = true;
    }
  }

  void _precacheImages(BuildContext context) {
    precacheImage(const AssetImage('assets/images/background_dark.jpg'), context);
    precacheImage(const AssetImage('assets/images/background_light.jpg'), context);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => CartProvider()),
        ChangeNotifierProvider(create: (ctx) => SalesProvider()),
        ChangeNotifierProvider(create: (ctx) => CashFlowProvider()),
      ],
      child: MaterialApp(
        title: 'Gelo Gestor',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,

        // A tela inicial agora é a nossa SplashScreen
        home: const SplashScreen(),
      ),
    );
  }
}