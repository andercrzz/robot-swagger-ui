import 'package:robot/model/category_model.dart';

List<CategoryModel> getCategories(){
  //CategoryModel categoryModel = new CategoryModel(image: iamge, name: name);

  List<CategoryModel> category = [];
  CategoryModel categoryModel = new CategoryModel();

  categoryModel.image = "images/pizza.png";
  categoryModel.name = "Pizza";
  category.add(categoryModel);
  categoryModel = new CategoryModel();

  categoryModel.image = "images/burger.png";
  categoryModel.name = "Burger";
  category.add(categoryModel);
  categoryModel = new CategoryModel();

  categoryModel.image = "images/chinese.png";
  categoryModel.name = "Chinese";
  category.add(categoryModel);
  categoryModel = new CategoryModel();

  categoryModel.image = "images/tacos.png";
  categoryModel.name = "Mexican";
  category.add(categoryModel);
  categoryModel = new CategoryModel();

  return category;
}