import 'package:flutter/material.dart';
import 'package:robot/model/category_model.dart';
import 'package:robot/model/product_model.dart';
import 'package:robot/pages/cart.dart';
import 'package:robot/service/category_data.dart';
import 'package:robot/service/widget_support.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:robot/pages/product_detail.dart'; // Importa la página de detalles
import 'package:robot/service/cart.dart'; // Importa la clase Cart

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

  getData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("productos").get();
    products = querySnapshot.docs.map((doc) => ProductModel.fromFirestore(doc.data() as Map<String, dynamic>)).toList();
    print(products.first.nombre);
    setState(() {});
  }

  @override
  void initState() {
    db = FirebaseFirestore.instance;
    getData();
    categories = getCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(left: 20.0, top: 40.0),
        child: Column(
          children: [
            Row(
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
            SizedBox(height: 20.0),
            Container(
              height: 70,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index){
                  return CategoryTile(
                    categories[index].name!,
                    categories[index].image!,
                    index.toString(),);
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
                  return ProductTile(product: products[index]);
                },
              ),
            ),
          ]
        )
      )
    );
  }

  Widget CategoryTile(String name, String image, String categoryIndex) {
    return GestureDetector(
      onTap: () {
        track = categoryIndex.toString();
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

  const ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            "images/burger.png", // Asegúrate de tener una URL de imagen en tu modelo de producto
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
            },
            child: Text('Añadir a la cesta'),
          ),
        ],
      ),
    );
  }
}