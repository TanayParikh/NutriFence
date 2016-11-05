// start Redis
var redis = require('redis');
var client = redis.createClient();

client.on('connect', function() {
    console.log('app connected');
});

// fetch the unsafe/unfriendly ingredients data from Redis
var populateDatabase = require("./populateDatabase.js");
populateDatabase.addCeliacUnsafe();
populateDatabase.addCeliacUnfriendly();
// populateDatabase.printMembers();

var unsafeList;
client.smembers('Celiac Unsafe', function(err, list) {
    unsafeList = list;
});

var unfriendlyList;
client.smembers('Celiac Unfriendly', function(err, list) {
    unfriendlyList = list;
});

// require and initialize the necessary modules
var express = require('express'),
    app = express(),
    bodyParser = require('body-parser'),
    path = require("path");

// add support for parsing different types of post data
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// tell express that www is the root of our public web folder
app.use(express.static(path.join(__dirname, 'www')));

// tell express what to do when the /ClassificationAPI route is requested
app.post('/ClassificationAPI',function(req, res){
    var rawIngredients = req.body.responses[0].textAnnotations[0].description;
    rawIngredients = rawIngredients.toLowerCase();

    var index = rawIngredients.indexOf("ingredients") + 13;
    rawIngredients = rawIngredients.substring(index, rawIngredients.length-1);
    rawIngredients = rawIngredients.replace(/(\n)+/g, ' ');
    rawIngredients = rawIngredients.replace(/[.]+/g, ',');
    rawIngredients = rawIngredients.split(",");

    // Parses ingredients with sub-group
    var subGroupHead = null;

    for (var i = 0; i < rawIngredients.length-1; ++i) {
        var ingredient = rawIngredients[i];

        if (ingredient.indexOf('(') != -1) {
            var index = ingredient.indexOf('(');
            subGroupHead = ingredient.substr(0, index-1); //ingredient.replace(/[(]+/g, '');
            rawIngredients[i] = ingredient.substr(index+1) + "(" + subGroupHead + ")";
        } else if ((ingredient.indexOf(')') != -1) && subGroupHead) {
            rawIngredients[i] = ingredient.replace(/[)]+/g, '') + " (" + subGroupHead + ")";
            
            subGroupHead = null;
        } else if (subGroupHead) {
            rawIngredients[i] = ingredient + " (" + subGroupHead + ")";
        }
    }

    var mayContain = [];
    var goodIngredients = [];
    var badIngredients = [];
    var unsureIngredients = [];

    for (var k=0; k<rawIngredients.length; k++) {
        if ( rawIngredients[k].includes("may contain") ) {
            var temp = rawIngredients[k].substring(rawIngredients[k].indexOf("may contain")+12, rawIngredients[k].length);
            mayContain.push(temp);
            for (var j=k+1; j<rawIngredients.length; j++) {
                mayContain.push(rawIngredients[j]);
            }

            rawIngredients.splice(k, rawIngredients.length-k);
        }
    }

    rawIngredients.forEach( function(ingredient) {
        if (!isUnsafe(ingredient) && !isUnfriendly(ingredient)) {
            if (ingredient) goodIngredients.push(ingredient);
        }
    });

    function isUnsafe(ingredient) {
        unsafeList.forEach( function (unsafeItem) {
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

    res.send(JSON.stringify({
        Bad_Ingredients: badIngredients,
        Unsure_Ingredients: unsureIngredients,
        Good_Ingredients: goodIngredients,
        May_Contain: mayContain,
        isGlutenFree: pass,
        mayContainGluten: maybe
    }));
});

//wait for a connection
app.listen(3000, function () {
    console.log('Server is running. Point your browser to: http://localhost:3000');
});
