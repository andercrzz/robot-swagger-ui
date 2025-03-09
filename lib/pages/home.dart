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
            child: Column(
              children: [
                Expanded(
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.add, color: Colors.white),
                                onPressed: () {
                                  _showAddProductDialog(category.nombre);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.white),
                                onPressed: () {
                                  _deleteCategory(category);
                                },
                              ),
                            ],
                          ),
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _showAddCategoryDialog();
                    },
                    child: Text('Añadir Categoría'),
                  ),
                ),
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
                          onDelete: () {
                            _deleteProduct(products[index], categories[int.parse(track)].nombre);
                          },
                        );
                      },
                    ),
                  ),
                ]
              )
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    final TextEditingController nameController = TextEditingController();
    String? imagePath;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Añadir Nueva Categoría'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nombre de la Categoría'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  // Implementar lógica para seleccionar imagen
                  // imagePath = await _pickImage();
                  imagePath = "images/burger.png";
                },
                child: Text('Seleccionar Imagen'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && imagePath != null) {
                  _addCategory(nameController.text, imagePath!);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Añadir'),
            ),
          ],
        );
      },
    );
  }

  void _showAddProductDialog(String categoryName) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController tiempoDeEsperaEstimadoController = TextEditingController();
    String? imagePath;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Añadir Nuevo Producto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nombre del Producto'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Descripción del Producto'),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Precio del Producto'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: tiempoDeEsperaEstimadoController,
                decoration: InputDecoration(labelText: 'Tiempo de Espera Estimado'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  // Implementar lógica para seleccionar imagen
                  // imagePath = await _pickImage();
                  imagePath = "images/burger.png";
                },
                child: Text('Seleccionar Imagen'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && descriptionController.text.isNotEmpty && priceController.text.isNotEmpty && tiempoDeEsperaEstimadoController.text.isNotEmpty && imagePath != null) {
                  _addProduct(categoryName, nameController.text, descriptionController.text, priceController.text, tiempoDeEsperaEstimadoController.text, imagePath!);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Añadir'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addCategory(String name, String imagePath) async {
    print("Se está añadiendo la categoría $name con la imagen $imagePath");
    final newCategory = CategoryModel(nombre: name, imagen: imagePath);
    await db.collection('categorias').add(newCategory.toMap());
    await db.collection(name).add({'initialized': true}); // Añadir una nueva colección con un documento inicial
    getCategories();
  }

  Future<void> _addProduct(String categoryName, String name, String description, String price, String tiempoDeEsperaEstimado, String imagePath) async {
    print("Se está añadiendo el producto $name a la categoría $categoryName");
    final newProduct = ProductModel(nombre: name, descripcion: description, precio: price, tiempoDeEsperaEstimado: tiempoDeEsperaEstimado, imagen: imagePath);
    await db.collection(categoryName).add(newProduct.toMap());
    getProducts(categoryName);
  }

  Future<void> _deleteCategory(CategoryModel category) async {
    print("Se está eliminando la categoría ${category.nombre}");
    await db.collection('categorias').where('nombre', isEqualTo: category.nombre).get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
    await db.collection(category.nombre).get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
    await db.collection(category.nombre).doc().delete(); // Eliminar la colección
    getCategories();
  }

  Future<void> _deleteProduct(ProductModel product, String categoryName) async {
    print("Se está eliminando el producto ${product.nombre} de la categoría $categoryName");
    await db.collection(categoryName).where('nombre', isEqualTo: product.nombre).get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
    getProducts(categoryName);
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
        decoration: BoxDecoration(color: Color.fromARGB(168, 56, 39, 23), borderRadius: BorderRadius.circular(30.0)),
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
  final VoidCallback onDelete;

  const ProductTile({required this.product, required this.onAddToCart, required this.onDelete});

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
              '${product.precio}€',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: onDelete,
              ),
            ],
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
                  subtitle: Text('Precio: ${product.precio}€'),
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