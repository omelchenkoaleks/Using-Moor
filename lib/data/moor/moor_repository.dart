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

  // ----- Finding recipes -----

  @override
  Future<Recipe> findRecipeById(int id) {
    return _recipeDao
        .findRecipeById(id)
        .then((listOfRecipes) => moorRecipeToRecipe(listOfRecipes.first));
  }

  @override
  Future<List<Ingredient>> findAllIngredients() {
    return _ingredientDao.findAllIngredients().then<List<Ingredient>>(
      (List<MoorIngredientData> moorIngredients) {
        final ingredients = <Ingredient>[];
        moorIngredients.forEach(
          (ingredient) {
            ingredients.add(moorIngredientToIngredient(ingredient));
          },
        );
        return ingredients;
      },
    );
  }

  @override
  Future<List<Ingredient>> findRecipeIngredients(int recipeId) {
    return _ingredientDao.findRecipeIngredients(recipeId).then(
      (listOfIngredients) {
        final ingredients = <Ingredient>[];
        listOfIngredients.forEach(
          (ingredient) {
            ingredients.add(moorIngredientToIngredient(ingredient));
          },
        );
        return ingredients;
      },
    );
  }

  // ----- Inserting recipes -----

  @override
  Future<int> insertRecipe(Recipe recipe) {
    return Future(
      () async {
        // Use the recipe DAO to insert a converted model recipe.
        final id =
            await _recipeDao.insertRecipe(recipeToInsertableMoorRecipe(recipe));
        if (recipe.ingredients != null) {
          // Set the recipe ID for each ingredient.
          recipe.ingredients!.forEach(
            (ingredient) {
              ingredient.recipeId = id;
            },
          );
          // Insert all the ingredients. You’ll define these next.
          insertIngredients(recipe.ingredients!);
        }
        return id;
      },
    );
  }

  @override
  Future<List<int>> insertIngredients(List<Ingredient> ingredients) {
    return Future(
      () {
        // Checks to make sure you have at least one ingredient.
        if (ingredients.length == 0) {
          return <int>[];
        }
        final resultIds = <int>[];
        ingredients.forEach(
          (ingredient) {
            // Converts the ingredient.
            final moorIngredient =
                ingredientToInsertableMoorIngredient(ingredient);
            // Inserts the ingredient into the database and adds a new ID to the list.
            _ingredientDao
                .insertIngredient(moorIngredient)
                .then((int id) => resultIds.add(id));
          },
        );
        return resultIds;
      },
    );
  }

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
