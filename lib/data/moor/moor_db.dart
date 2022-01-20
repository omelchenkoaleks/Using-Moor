import 'package:moor_flutter/moor_flutter.dart';
import '../models/models.dart';

part 'moor_db.g.dart';

// Create a class named MoorRecipe that extends Table.
class MoorRecipe extends Table {
  // You want a column named id that is an integer. autoIncrement() automatically creates the IDs for you.
  IntColumn get id => integer().autoIncrement()();

  // Create a label column made up of text.
  TextColumn get label => text()();

  TextColumn get image => text()();

  TextColumn get url => text()();

  RealColumn get calories => real()();

  RealColumn get totalWeight => real()();

  RealColumn get totalTime => real()();
}

class MoorIngredient extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get recipeId => integer()();

  TextColumn get name => text()();

  RealColumn get weight => real()();
}

// Describe the tables and DAOs this database will use.
@UseMoor(tables: [MoorRecipe, MoorIngredient], daos: [RecipeDao, IngredientDao])
// Extend _$RecipeDatabase, which the Moor generator will create. This doesn’t exist yet, but the part command at the top will include it.
class RecipeDatabase extends _$RecipeDatabase {
  RecipeDatabase()
      // When creating the class, call the super class’s constructor. This uses the built-in Moor query executor and passes the pathname of the file. It also sets logging to true.
      : super(FlutterQueryExecutor.inDatabaseFolder(
            path: 'recipes.sqlite', logStatements: true));

  // Set the database or schema version to 1.
  @override
  int get schemaVersion => 1;
}

// @UseDao specifies the following class is a DAO class for the MoorRecipe table.
@UseDao(tables: [MoorRecipe])
// Create the DAO class that extends the Moor DatabaseAccessor with the mixin, _$RecipeDaoMixin.
class RecipeDao extends DatabaseAccessor<RecipeDatabase> with _$RecipeDaoMixin {
  // Create a field to hold an instance of your database.
  final RecipeDatabase db;

  RecipeDao(this.db) : super(db);

  // Use a simple select query to find all recipes.
  Future<List<MoorRecipeData>> findAllRecipes() => select(moorRecipe).get();

  // Define watchAllRecipes(), but skip the implementation for now.
  Stream<List<Recipe>> watchAllRecipes() {
    // TODO: Add watchAllRecipes code here
  }

  // Define a more complex query that uses where to fetch recipes by ID.
  Future<List<MoorRecipeData>> findRecipeById(int id) =>
      (select(moorRecipe)..where((tbl) => tbl.id.equals(id))).get();

  // Use into() and insert() to add a new recipe.
  Future<int> insertRecipe(Insertable<MoorRecipeData> recipe) =>
      into(moorRecipe).insert(recipe);

  // Use delete() and where() to delete a specific recipe.
  Future deleteRecipe(int id) => Future.value(
      (delete(moorRecipe)..where((tbl) => tbl.id.equals(id))).go());
}

// Similar to RecipeDao, you define the table to use.
@UseDao(tables: [MoorIngredient])
// Extend DatabaseAccessor with _$IngredientDaoMixin.
class IngredientDao extends DatabaseAccessor<RecipeDatabase>
    with _$IngredientDaoMixin {
  final RecipeDatabase db;

  IngredientDao(this.db) : super(db);

  Future<List<MoorIngredientData>> findAllIngredients() =>
      select(moorIngredient).get();

  // Call watch() to create a stream.
  Stream<List<MoorIngredientData>> watchAllIngredients() =>
      select(moorIngredient).watch();

  // Use where() to select all ingredients that match the recipe ID.
  Future<List<MoorIngredientData>> findRecipeIngredients(int id) =>
      (select(moorIngredient)..where((tbl) => tbl.recipeId.equals(id))).get();

  // Use into() and insert() to add a new ingredient.
  Future<int> insertIngredient(Insertable<MoorIngredientData> ingredient) =>
      into(moorIngredient).insert(ingredient);

  // Use delete() plus where() to delete a specific ingredient.
  Future deleteIngredient(int id) => Future.value(
      (delete(moorIngredient)..where((tbl) => tbl.id.equals(id))).go());
}

// Conversion Methods
Recipe moorRecipeToRecipe(MoorRecipeData recipe) {
  return Recipe(
      id: recipe.id,
      label: recipe.label,
      image: recipe.image,
      url: recipe.url,
      calories: recipe.calories,
      totalWeight: recipe.totalWeight,
      totalTime: recipe.totalTime);
}

Insertable<MoorRecipeData> recipeToInsertableMoorRecipe(Recipe recipe) {
  return MoorRecipeCompanion.insert(
      label: recipe.label ?? '',
      image: recipe.image ?? '',
      url: recipe.url ?? '',
      calories: recipe.calories ?? 0,
      totalWeight: recipe.totalWeight ?? 0,
      totalTime: recipe.totalTime ?? 0);
}


// TODO: Add moorIngredientToIngredient and MoorIngredientCompanion here
