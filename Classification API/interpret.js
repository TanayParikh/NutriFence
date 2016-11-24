// TODO: optimize getResults
// its current time complexity makes me want to cry just a lil bit
module.exports.getResults = function(unsafeList, ingredients) {
    ingredients = formatIngredients(ingredients);

    var temp = handleContains(ingredients);
    ingredients = temp.ingredients;
    var mayContainList = temp.mayContain;

    var goodIngredientsList = [];
    var badIngredientsList = [];
    ingredients.forEach(function (ingr) {
        if (isSafe(unsafeList, ingr)) goodIngredientsList.push(ingr);
        else {
            if (ingr) badIngredientsList.push(ingr);
        }
    });

    var passesTest = (badIngredientsList.length == 0);

    return [badIngredientsList, goodIngredientsList, mayContainList, passesTest];
};


// Cleans up raw ingredients list
function formatIngredients(ingredientsList) {
    ingredientsList = ingredientsList.replace(/[)]+/g, ',');
    ingredientsList = ingredientsList.replace(/[(]+/g, '(,');
    ingredientsList = ingredientsList.split(",");

    for (var i = 0; i < ingredientsList.length; i++) {
        if (ingredientsList[i].includes("(")) ingredientsList.splice(i, 1);
        ingredientsList[i] = ingredientsList[i].replace(/^\s+|\s+$/g, '');
    }
    return ingredientsList;
}

// Check if the list has either 'contains' or 'may contain' and handle both
function handleContains(ingredients) {
    var mayContainList = [];
    for (var i=0; i<ingredients.length; i++) {
        if (ingredients[i].includes("may contain")) {
            for (var j = i + 1; j < ingredients.length; j++) {
                mayContainList.push(ingredients[j]);
            }
            ingredients.splice(i, ingredients.length - i);
        }
        if (ingredients[i].includes("contains")) {
            ingredients[i] = ingredients[i].slice(0, ingredients[i].indexOf("contains"));
        }
    }
    return {'ingredients': ingredients, 'mayContain': mayContainList};
}

// Checks if an ingredient is in the banned list of ingredients
function isSafe(unsafeList, ingredient) {
    var safe = true;
    unsafeList.forEach(function (unsafeItem) {
        if (ingredient.includes(unsafeItem)) {
            safe = false;
        }
    });
    return safe;
}