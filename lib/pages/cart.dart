import 'package:flutter/material.dart';
import 'package:robot/model/product_model.dart';
import 'package:robot/service/cart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Carrito'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: Cart.items.length,
              itemBuilder: (context, index) {
                final product = Cart.items[index];
                return ListTile(
                  leading: Image.asset(
                    "images/burger.png", // Asegúrate de tener una URL de imagen en tu modelo de producto
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(product.nombre),
                  subtitle: Text('Precio: \$${product.precio}'),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_circle),
                    onPressed: () {
                      Cart.removeItem(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${product.nombre} eliminado de la cesta')),
                      );
                      (context as Element).reassemble();
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                await _placeOrder();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pedido realizado con éxito')),
                );
                Cart.clear();
                Navigator.pop(context);
              },
              child: Text('Pagar'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference orders = firestore.collection('pedidos');

    final List<Map<String, dynamic>> orderItems = Cart.items.map((product) {
      return product.toMap();
    }).toList();

    await orders.add({
      'items': orderItems,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}