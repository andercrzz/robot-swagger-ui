import 'package:flutter/material.dart';
import 'package:robot/model/product_model.dart';
import 'package:robot/service/cart.dart'; // Importa la clase Cart

class ProductDetailPage extends StatelessWidget {
  final ProductModel product;

  const ProductDetailPage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.nombre),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              "images/burger.png", // Asegúrate de tener una URL de imagen en tu modelo de producto
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16.0),
            Text(
              product.nombre,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              product.descripcion,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8.0),
            Text(
              'Precio: \$${product.precio}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Tiempo de espera estimado: ${product.tiempoDeEsperaEstimado} minutos',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Cart.addItem(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${product.nombre} añadido a la cesta')),
                );
              },
              child: Text('Añadir a la cesta'),
            ),
          ],
        ),
      ),
    );
  }
}