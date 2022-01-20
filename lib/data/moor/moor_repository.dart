import 'dart:async';
import '../models/models.dart';

import '../repository.dart';
import 'moor_db.dart';

class MoorRepository extends Repository {
  // Stores an instance of the Moor RecipeDatabase.
  late RecipeDatabase recipeDatabase;
  // Creates a private RecipeDao to handle recipes.
  late RecipeDao _recipeDao;
  // Creates a private IngredientDao that handles ingredients.
  late IngredientDao _ingredientDao;
  // Creates a stream that watches ingredients.
  Stream<List<Ingredient>>? ingredientStream;
  // Creates a stream that watches recipes.
  Stream<List<Recipe>>? recipeStream;

  // TODO: Add findAllRecipes()
  // TODO: Add watchAllRecipes()
  // TODO: Add watchAllIngredients()
  // TODO: Add findRecipeById()
  // TODO: Add findAllIngredients()
  // TODO: Add findRecipeIngredients()
  // TODO: Add insertRecipe()
  // TODO: Add insertIngredients()
  // TODO: Add Delete methods

  @override
  Future init() async {
    // Creates your database.
    recipeDatabase = RecipeDatabase();
    // Gets instances of your DAOs.
    _recipeDao = recipeDatabase.recipeDao;
    _ingredientDao = recipeDatabase.ingredientDao;
  }

  @override
  void close() {
    // Closes the database.
    recipeDatabase.close();
  }
}
