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


// TODO: Add RecipeDao here

// TODO: Add IngredientDao

// TODO: Add moorRecipeToRecipe here

// TODO: Add MoorRecipeData here

// TODO: Add moorIngredientToIngredient and MoorIngredientCompanion here
