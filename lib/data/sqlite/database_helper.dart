import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlbrite/sqlbrite.dart';
import 'package:synchronized/synchronized.dart';
import '../models/models.dart';

// This class will handle all the SQLite database operations.
class DatabaseHelper {
  // Constants for the database name and version.
  static const _databaseName = 'MyRecipes.db';
  static const _databaseVersion = 1;

  // Define the names of the tables.
  static const recipeTable = 'Recipe';
  static const ingredientTable = 'Ingredient';
  static const recipeId = 'recipeId';
  static const ingredientId = 'ingredientId';

  // Our sqlbrite database instance. late indicates the variable is non-nullable and that it will be initialized after it’s been declared.
  static late BriteDatabase _streamDatabase;

  // make this a singleton class

  //Make the constructor private and provide a public static instance.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  // Define lock, which you’ll use to prevent concurrent access.
  static var lock = Lock();

  // only have a single app-wide reference to the database
  // Private sqflite database instance.
  static Database? _database;

  // SQL code to create the database table
  // Pass an sqflite database db into the method. It will create the tables.
  Future _onCreate(Database db, int version) async {
    // Create recipeTable with the same columns as the model using CREATE TABLE.
    await db.execute('''
        CREATE TABLE $recipeTable (
          $recipeId INTEGER PRIMARY KEY,
          label TEXT,
          image TEXT,
          url TEXT,
          calories REAL,
          totalWeight REAL,
          totalTime REAL
        )
        ''');
    // Create ingredientTable.
    await db.execute('''
        CREATE TABLE $ingredientTable (
          $ingredientId INTEGER PRIMARY KEY,
          $recipeId INTEGER,
          name TEXT,
          weight REAL
        )
        ''');
  }

  // this opens the database (and creates it if it doesn't exist)
  // Declare that the method returns a Future, as the operation is asynchronous.
  Future<Database> _initDatabase() async {
    // Get the app document’s directory name, where you’ll store the database.
    final documentsDirectory = await getApplicationDocumentsDirectory();

    // Create a path to the database by appending the database name to the directory path.
    final path = join(documentsDirectory.path, _databaseName);

    // Turn on debugging. Remember to turn this off when you’re ready to deploy your app to the store(s).
    Sqflite.setDebugModeOn(true);

    // Use sqflite’s openDatabase() to create and store the database file in the path.
    return openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  // Other methods and classes can use this getter to access (get) the database.
  Future<Database> get database async {
    // If _database is not null, it’s already been created, so you return the existing one.
    if (_database != null) return _database!;
    // Use lock to ensure that only one process can be in this section of code at a time.
    await lock.synchronized(() async {
      // lazily instantiate the db the first time it is accessed
      // Check to make sure the database is null.
      if (_database == null) {
        // Call the _initDatabase(), which you defined above.
        _database = await _initDatabase();
        // Create a BriteDatabase instance, wrapping the database.
        _streamDatabase = BriteDatabase(_database!);
      }
    });
    return _database!;
  }

  // Define an asynchronous getter method.
  Future<BriteDatabase> get streamDatabase async {
    // Await the result — because it also creates _streamDatabase.
    await database;
    return _streamDatabase;
  }

  List<Recipe> parseRecipes(List<Map<String, dynamic>> recipeList) {
    final recipes = <Recipe>[];
    // Iterate over a list of recipes in JSON format.
    recipeList.forEach((recipeMap) {
      // Convert each recipe into a Recipe instance.
      final recipe = Recipe.fromJson(recipeMap);
      // Add the recipe to the recipe list.
      recipes.add(recipe);
    });
    // Return the list of recipes.
    return recipes;
  }

  List<Ingredient> parseIngredients(List<Map<String, dynamic>> ingredientList) {
    final ingredients = <Ingredient>[];
    ingredientList.forEach((ingredientMap) {
      // Convert each ingredient in JSON format into a list of Ingredients.
      final ingredient = Ingredient.fromJson(ingredientMap);
      ingredients.add(ingredient);
    });
    return ingredients;
  }

  Future<List<Recipe>> findAllRecipes() async {
    // Get your database instance.
    final db = await instance.streamDatabase;
    // Use the database query() to get all the recipes. query() has other parameters, but you don’t need them here.
    final recipeList = await db.query(recipeTable);
    // Use parseRecipes() to get a list of recipes.
    final recipes = parseRecipes(recipeList);
    return recipes;
  }

  Stream<List<Recipe>> watchAllRecipes() async* {
    final db = await instance.streamDatabase;
    // yield* creates a Stream using the query.
    yield* db
        // Create a query using recipeTable.
        .createQuery(recipeTable)
        // For each row, convert the row to a list of recipes.
        .mapToList((row) => Recipe.fromJson(row));
  }

  Stream<List<Ingredient>> watchAllIngredients() async* {
    final db = await instance.streamDatabase;
    yield* db
        .createQuery(ingredientTable)
        .mapToList((row) => Ingredient.fromJson(row));
  }

  // ----- FINDING RECIPES -----

  Future<Recipe> findRecipeById(int id) async {
    final db = await instance.streamDatabase;
    final recipeList = await db.query(recipeTable, where: 'id = $id');
    final recipes = parseRecipes(recipeList);
    return recipes.first;
  }

  Future<List<Ingredient>> findAllIngredients() async {
    final db = await instance.streamDatabase;
    final ingredientList = await db.query(ingredientTable);
    final ingredients = parseIngredients(ingredientList);
    return ingredients;
  }

  Future<List<Ingredient>> findRecipeIngredients(int recipeId) async {
    final db = await instance.streamDatabase;
    final ingredientList =
        await db.query(ingredientTable, where: 'recipeId = $recipeId');
    final ingredients = parseIngredients(ingredientList);
    return ingredients;
  }

  // ----- INSERTING DATA INTO TABLES -----

  // Take the table name and the JSON map.
  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await instance.streamDatabase;
    // Use Sqlbrite’s insert().
    return db.insert(table, row);
  }

  Future<int> insertRecipe(Recipe recipe) {
    // Return values from insert() using the recipe’s table and JSON data.
    return insert(recipeTable, recipe.toJson());
  }

  Future<int> insertIngredient(Ingredient ingredient) {
    // Return values from insert() using the ingredient’s table and JSON data.
    return insert(ingredientTable, ingredient.toJson());
  }

  // ----- DELETING DATA -----

  // Create a private function, _delete, which will delete data from the table with the provided column and row id.
  Future<int> _delete(String table, String columnId, int id) async {
    final db = await instance.streamDatabase;
    // Delete a row where columnId equals the passed-in id.
    return db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> deleteRecipe(Recipe recipe) async {
    // Call _delete(), which deletes a recipe with the passed ID.
    if (recipe.id != null) {
      return _delete(recipeTable, recipeId, recipe.id!);
    } else {
      return Future.value(-1);
    }
  }

  Future<int> deleteIngredient(Ingredient ingredient) async {
    if (ingredient.id != null) {
      return _delete(ingredientTable, ingredientId, ingredient.id!);
    } else {
      return Future.value(-1);
    }
  }

  Future<void> deleteIngredients(List<Ingredient> ingredients) {
    // For each ingredient, delete that entry from the ingredients table.
    ingredients.forEach((ingredient) {
      if (ingredient.id != null) {
        _delete(ingredientTable, ingredientId, ingredient.id!);
      }
    });
    return Future.value();
  }

  Future<int> deleteRecipeIngredients(int id) async {
    final db = await instance.streamDatabase;
    // Delete all ingredients that have the given recipeId.
    return db.delete(ingredientTable, where: '$recipeId = ?', whereArgs: [id]);
  }

  void close() {
    _streamDatabase.close();
  }
}
