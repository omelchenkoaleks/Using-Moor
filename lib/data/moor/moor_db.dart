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


// TODO: Add MoorIngredient table definition here

// TODO: Add @UseMoor() and RecipeDatabase() here

// TODO: Add RecipeDao here

// TODO: Add IngredientDao

// TODO: Add moorRecipeToRecipe here

// TODO: Add MoorRecipeData here

// TODO: Add moorIngredientToIngredient and MoorIngredientCompanion here
