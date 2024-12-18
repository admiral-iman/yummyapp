//This file will handle all our API calls to the
//Spoonacular API

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart';

class ApiService {
  ApiService._instantiate();
  static final ApiService instance = ApiService._instantiate();

  final String _baseURL = "api.spoonacular.com";
  static const String API_KEY = "abfdd1899eca428d83b95468b74e5134";

  Future<Recipe> fetchRecipe(String id) async {
    Map<String, String> parameters = {
      'includeNutrition': 'false',
      'apiKey': API_KEY,
    };

    //we call in our recipe id in the Uri, and parse in our parameters
    Uri uri = Uri.https(
      _baseURL,
      '/recipes/$id/information',
      parameters,
    );

    //And also specify that we want our header to return a json object
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    //finally, we put our response in a try catch block
    try {
      var response = await http.get(uri, headers: headers);
      Map<String, dynamic> data = json.decode(response.body);
      Recipe recipe = Recipe.fromMap(data);
      return recipe;
    } catch (err) {
      throw err.toString();
    }
  }

  Future<List<Recipe>> fetchAllRecipes({int limit = 100}) async {
    Map<String, String> parameters = {
      'apiKey': API_KEY,
      'number': limit.toString(), // Parameter to limit the number of recipes
    };

    Uri uri = Uri.https(
      _baseURL,
      '/recipes/random', // Endpoint for getting random recipes
      parameters,
    );

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    try {
      var response = await http.get(uri, headers: headers);
      Map<String, dynamic> data = json.decode(response.body);

      // Extract the list of recipes from the response
      List<dynamic> recipesData = data['recipes'];
      List<Recipe> recipes = recipesData.map((recipeData) {
        return Recipe.fromMap(recipeData);
      }).toList();

      return recipes;
    } catch (err) {
      throw err.toString();
    }
  }
}
