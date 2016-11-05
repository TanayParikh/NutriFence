/*
	TODO: check for may contain -> mayContainGluten = true automatically
	 					contains -> isGlutenFree = false automatically
*/


var redis = require('redis');
var client = redis.createClient();

client.on('connect', function() {
    console.log('app connected');
});

var populateDatabase = require("./populateDatabase.js");
populateDatabase.addCeliacUnsafe();
populateDatabase.addCeliacUnfriendly();

var unsafeList;
client.smembers('Celiac Unsafe', function(err, list) {
    unsafeList = list;
});

var unfriendlyList;
client.smembers('Celiac Unfriendly', function(err, list) {
    unfriendlyList = list;
});

//require the express nodejs module
var express = require('express'),

//set an instance of express
    app = express(),

//require the body-parser nodejs module
    bodyParser = require('body-parser'),

//require the path nodejs module
    path = require("path");

//support parsing of application/json type post data
app.use(bodyParser.json());

//support parsing of application/x-www-form-urlencoded post data
app.use(bodyParser.urlencoded({ extended: true }));

//tell express that www is the root of our public web folder
app.use(express.static(path.join(__dirname, 'www')));

//tell express what to do when the /ClassificationAPI route is requested
app.post('/ClassificationAPI',function(req, res){
    var rawIngredients = req.body.responses[0].textAnnotations[0].description;
    rawIngredients = rawIngredients.toLowerCase();

    var index = rawIngredients.indexOf("ingredients") + 13;
    rawIngredients = rawIngredients.substring(index, rawIngredients.length-1);
    rawIngredients = rawIngredients.replace(/(\n)+/g, ' ');
    rawIngredients = rawIngredients.replace(/[(]+/g, ',');
    rawIngredients = rawIngredients.replace(/[)]+/g, ',');
    rawIngredients = rawIngredients.split(",");

    var goodIngredients = [];
    var badIngredients = [];
    var unsureIngredients = [];

    rawIngredients.forEach(function(ingredient) {
        if (!isUnsafe(ingredient) && !isUnfriendly(ingredient)) {
            if (ingredient) goodIngredients.push(ingredient);
        }
    });

    function isUnsafe(ingredient) {
        unsafeList.forEach(function (unsafeItem) {
            if (ingredient.includes(unsafeItem)) {
                badIngredients.push(ingredient);
                return true;
            }
        });

        return false;
    }

    function isUnfriendly(ingredient) {
        unfriendlyList.forEach(function (unfriendlyItem) {
            if (ingredient.includes(unfriendlyItem)) {
                unsureIngredients.push(ingredient);
                return true;
            }
        });

        return false;
    }
    
    var pass = !(badIngredients.length != 0);
    var maybe = (unsureIngredients.length != 0);
    
    res.setHeader('Content-Type', 'application/rawIngredients');

    //mimic a slow network connection
    setTimeout(function(){

        res.send(JSON.stringify({
            Bad_Ingredients: badIngredients,
        	Unsure_Ingredients: unsureIngredients,
            Good_Ingredients: goodIngredients,
            isGlutenFree: pass,
            mayContainGluten: maybe
        }));

    }, 1000);

    //debugging output for the terminal
    console.log('you posted Response: ' + badIngredients);
});

//wait for a connection
app.listen(3000, function () {
    console.log('Server is running. Point your browser to: http://localhost:3000');
});
