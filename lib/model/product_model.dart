class ProductModel {
  String nombre;
  String precio;
  String imagen;
  String descripcion;
  String tiempoDeEsperaEstimado;

  ProductModel({
    required this.nombre,
    required this.precio,
    required this.imagen,
    required this.descripcion,
    required this.tiempoDeEsperaEstimado,
  });

  // Método para crear un objeto ProductModel a partir de un documento de Firestore
  factory ProductModel.fromFirestore(Map<String, dynamic> data) {
    return ProductModel(
      nombre: data['nombre'] ?? '',
      precio: data['precio'] ?? '',
      imagen: data['imagen'] ?? '',
      descripcion: data['descripcion'] ?? '',
      tiempoDeEsperaEstimado: data['tiempoDeEsperaEstimado'] ?? '',
    );
  }

  // Método para convertir un objeto ProductModel a un mapa
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'precio': precio,
      'imagen': imagen,
      'descripcion': descripcion,
      'tiempoDeEsperaEstimado': tiempoDeEsperaEstimado,
    };
  }
}