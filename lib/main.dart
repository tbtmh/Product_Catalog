import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/responsive_text.dart';
import 'features/shell/main_shell.dart';

void main() {
  runApp(const ProviderScope(child: ProductCatalogApp()));
}

class ProductCatalogApp extends StatelessWidget {
  const ProductCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Catalog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      builder: (context, child) => ResponsiveTextScale(child: child!),
      home: const MainShell(),
    );
  }
}
