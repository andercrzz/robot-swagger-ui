class CategoryModel {
  String nombre;
  String imagen;

  CategoryModel({
    required this.nombre,
    required this.imagen
  });

  // Método para crear un objeto ProductModel a partir de un documento de Firestore
  factory CategoryModel.fromFirestore(Map<String, dynamic> data) {
    return CategoryModel(
      nombre: data['nombre'] ?? '',
      imagen: data['imagen'] ?? ''
    );
  }

  // Método para convertir un objeto ProductModel a un mapa
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'imagen': imagen
    };
  }
}