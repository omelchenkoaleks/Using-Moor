import 'dart:async';
// Include helper class, models and repository interface.
import '../repository.dart';
import 'database_helper.dart';
import '../models/models.dart';

// Create a new class named SqliteRepository that extends Repository.
class SqliteRepository extends Repository {
  // Add a dbHelper field, which is just a single instance of DatabaseHelper.
  final dbHelper = DatabaseHelper.instance;

  @override
  Future<List<Recipe>> findAllRecipes() {
    return dbHelper.findAllRecipes();
  }

  @override
  Stream<List<Recipe>> watchAllRecipes() {
    return dbHelper.watchAllRecipes();
  }

  @override
  Stream<List<Ingredient>> watchAllIngredients() {
    return dbHelper.watchAllIngredients();
  }

  @override
  Future<Recipe> findRecipeById(int id) {
    return dbHelper.findRecipeById(id);
  }

  @override
  Future<List<Ingredient>> findAllIngredients() {
    return dbHelper.findAllIngredients();
  }

  @override
  Future<List<Ingredient>> findRecipeIngredients(int id) {
    return dbHelper.findRecipeIngredients(id);
  }

  @override
  Future<int> insertRecipe(Recipe recipe) {
    // Return an asynchronous Future.
    return Future(() async {
      // Use your helper to insert the recipe and save the id.
      final id = await dbHelper.insertRecipe(recipe);
      // Set your recipe class’s id to this id.
      recipe.id = id;
      if (recipe.ingredients != null) {
        recipe.ingredients!.forEach((ingredient) {
          // Set each ingredient’s recipeId field to this id.
          ingredient.recipeId = id;
        });
        // Insert all the ingredients.
        insertIngredients(recipe.ingredients!);
      }
      // Return the new id.
      return id;
    });
  }

  @override
  Future<List<int>> insertIngredients(List<Ingredient> ingredients) {
    return Future(() async {
      if (ingredients.length != 0) {
        // Create a list of new ingredient IDs.
        final ingredientIds = <int>[];
        // Since you need to use await with insertIngredient, you need to wrap everything in an asynchronous Future. This is a bit tricky, but it allows you to wait for each ID. It returns a Future so the whole method can still run asynchronously.
        await Future.forEach(ingredients, (Ingredient ingredient) async {
          // Get the new ingredient’s ID.
          final futureId = await dbHelper.insertIngredient(ingredient);
          ingredient.id = futureId;
          // Add the ID to your return list.
          ingredientIds.add(futureId);
        });
        // Return the list of new IDs.
        return Future.value(ingredientIds);
      } else {
        return Future.value(<int>[]);
      }
    });
  }

  @override
  Future<void> deleteRecipe(Recipe recipe) {
    // Call the helper’s deleteRecipe().
    dbHelper.deleteRecipe(recipe);
    // Delete all of this recipe’s ingredients.
    if (recipe.id != null) {
      deleteRecipeIngredients(recipe.id!);
    }
    return Future.value();
  }

  @override
  Future<void> deleteIngredient(Ingredient ingredient) {
    dbHelper.deleteIngredient(ingredient);
    // Delete ingredients and ignore the number of deleted rows.
    return Future.value();
  }

  @override
  Future<void> deleteIngredients(List<Ingredient> ingredients) {
    // Delete all ingredients in the list passed in.
    dbHelper.deleteIngredients(ingredients);
    return Future.value();
  }

  @override
  Future<void> deleteRecipeIngredients(int recipeId) {
    // Delete all ingredients with the given recipe ID.
    dbHelper.deleteRecipeIngredients(recipeId);
    return Future.value();
  }

  @override
  Future init() async {
    // Await for the database to initialize.
    await dbHelper.database;
    return Future.value();
  }

  @override
  void close() {
    // Call the helper’s close() method.
    dbHelper.close();
  }
}
