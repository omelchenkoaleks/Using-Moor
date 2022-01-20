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

  @override
  Future<List<Recipe>> findAllRecipes() {
    // Uses RecipeDao to find all recipes.
    return _recipeDao.findAllRecipes()
        // Takes the list of MoorRecipeData items, executing then after findAllRecipes() finishes.
        .then<List<Recipe>>(
      (List<MoorRecipeData> moorRecipes) {
        final recipes = <Recipe>[];
        // For each recipe:
        moorRecipes.forEach(
          (moorRecipe) async {
            // Converts the Moor recipe to a model recipe.
            final recipe = moorRecipeToRecipe(moorRecipe);
            // Calls the method to get all recipe ingredients, which you’ll define later.
            if (recipe.id != null) {
              recipe.ingredients = await findRecipeIngredients(recipe.id!);
            }
            recipes.add(recipe);
          },
        );
        return recipes;
      },
    );
  }

  @override
  Stream<List<Recipe>> watchAllRecipes() {
    if (recipeStream == null) {
      recipeStream = _recipeDao.watchAllRecipes();
    }
    return recipeStream!;
  }

  @override
  Stream<List<Ingredient>> watchAllIngredients() {
    if (ingredientStream == null) {
      // Gets a stream of ingredients.
      final stream = _ingredientDao.watchAllIngredients();
      // Maps each stream list to a stream of model ingredients
      ingredientStream = stream.map(
        (moorIngredients) {
          final ingredients = <Ingredient>[];
          // Converts each ingredient in the list to a model ingredient.
          moorIngredients.forEach(
            (moorIngredient) {
              ingredients.add(moorIngredientToIngredient(moorIngredient));
            },
          );
          return ingredients;
        },
      );
    }
    return ingredientStream!;
  }

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
