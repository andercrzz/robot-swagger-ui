import 'package:flutter/material.dart';
import 'package:robot/model/category_model.dart';
import 'package:robot/model/product_model.dart';
import 'package:robot/service/cart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:robot/service/widget_support.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  String track = "0";

  List<CategoryModel> categories = [];
  List<ProductModel> products = [];
  late FirebaseFirestore db;

  @override
  void initState() {
    super.initState();
    db = FirebaseFirestore.instance;
    getCategories();
  }

  getCategories() async {
    QuerySnapshot querySnapshot = await db.collection("categorias").get();
    categories = querySnapshot.docs.map((doc) => CategoryModel.fromFirestore(doc.data() as Map<String, dynamic>)).toList();
    if (categories.isNotEmpty) {
      getProducts(categories[0].nombre); // Cargar productos de la primera categoría
      track = "0"; // Seleccionar la primera categoría
    }
    setState(() {});
  }

  getProducts(String category) async {
    QuerySnapshot querySnapshot = await db.collection(category).get();
    products = querySnapshot.docs.map((doc) => ProductModel.fromFirestore(doc.data() as Map<String, dynamic>)).toList();
    setState(() {});
  }

  double getTotalPrice() {
    double result = Cart.items.fold(0, (total, current) => total + double.parse(current.precio));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 250, // Ancho del menú lateral
            color: Color.fromARGB(168, 56, 39, 23),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(168, 56, 39, 23),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            "images/logo.png",
                            height: 50,
                            width: 110,
                            fit: BoxFit.contain),
                          Text("Order your favorite food",
                            style: AppWidget.SimpleTextFieldStyle()
                          ),
                      ]),
                    ],
                  ),
                ),
                ...categories.map((category) {
                  return ListTile(
                    title: Text(category.nombre, style: TextStyle(color: Colors.white)),
                    onTap: () {
                      getProducts(category.nombre);
                      track = categories.indexOf(category).toString();
                      setState(() {});
                    },
                  );
                }).toList(),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 20.0, top: 40.0),
              child: Column(
                children: [
                  Container(
                    height: 70,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index){
                        return CategoryTile(
                          categories[index].nombre,
                          //categories[index].image,
                          "images/burger.png",
                          index.toString(),
                          onTap: () {
                            getProducts(categories[index].nombre);
                          },
                        );
                      }),
                  ),
                  SizedBox(height: 20.0),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return ProductTile(
                          product: products[index],
                          onAddToCart: () {
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Total: \$${getTotalPrice().toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CartPage(onCartUpdated: () {
                          setState(() {});
                        })),
                      );
                    },
                    child: Text('Terminar compra'),
                  ),
                ]
              )
            ),
          ),
        ],
      ),
    );
  }

  Widget CategoryTile(String name, String image, String categoryIndex, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () {
        track = categoryIndex.toString();
        onTap();
        setState(() {});
      },
      child: track == categoryIndex ? Container(
        padding: EdgeInsets.only(left: 20.0, right: 20.0),
        margin: EdgeInsets.only(right: 20.0),
        decoration: BoxDecoration(color: Color.fromARGB(255, 128, 189, 255), borderRadius: BorderRadius.circular(30.0)),
        child: Row(
          children: [
            Image.asset(
              image,
              height: 40,
              width: 40,
              fit: BoxFit.cover
            ),
            SizedBox(width: 10.0),
            Text(name, style: AppWidget.whiteTextFieldStyle()) 
          ],
        )
      ) : Container(
        padding: EdgeInsets.only(left: 20.0, right: 20.0), 
        margin: EdgeInsets.only(right: 20.0),
        decoration: BoxDecoration(color: Color(0xFFececf8), borderRadius: BorderRadius.circular(30.0)),
        child: Row(
          children: [
            Image.asset(
              image,
              height: 40,
              width: 40,
              fit: BoxFit.cover
            ),
            SizedBox(width: 10.0),
            Text(name, style: AppWidget.SimpleTextFieldStyle()) 
          ],
        )
      )
    );
  }
}

class ProductTile extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onAddToCart;

  const ProductTile({required this.product, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            product.imagen, // Asegúrate de tener una URL de imagen en tu modelo de producto
            height: 100,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              product.nombre,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              product.descripcion,
              style: TextStyle(fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '\$${product.precio}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Cart.addItem(product);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${product.nombre} añadido a la cesta')),
              );
              onAddToCart();
            },
            child: Text('Añadir a la cesta'),
          ),
        ],
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  final VoidCallback onCartUpdated;

  const CartPage({required this.onCartUpdated});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
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
                  leading: Image.network(
                    product.imagen, // Asegúrate de tener una URL de imagen en tu modelo de producto
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(product.nombre),
                  subtitle: Text('Precio: \$${product.precio}'),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_circle),
                    onPressed: () {
                      setState(() {
                        Cart.removeItem(product);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${product.nombre} eliminado de la cesta')),
                      );
                      widget.onCartUpdated();
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
                setState(() {
                  Cart.clear();
                });
                widget.onCartUpdated();
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