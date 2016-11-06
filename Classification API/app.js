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
// populateDatabase.printMembers();                         // uncomment for testing

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
app.post('/ClassificationAPI', function(request, response) {
    interpretAndSendData(request, response);
});

// wait for a connection
app.listen(3000, function () {
    console.log('Server is running. Point your browser to: http://localhost:3000');
});

function interpretAndSendData(req, res) {
    var rawIngredients = req.body.responses[0].textAnnotations[0].description;
    rawIngredients = formatRawIngredients(rawIngredients);
    // rawIngredients = splitIntoSubgroups(rawIngredients);             // adds supheadings - buggy though

    var mayContain = [];
    var goodIngredients = [];
    var badIngredients = [];
    var unsureIngredients = [];
    var pass, mayContainGluten;


    for (var k=0; k<rawIngredients.length; k++) {
        parseMayContain(rawIngredients[k], k);
    }

    rawIngredients.forEach(function (ingredient) {
        if (!isUnsafe(ingredient) && !isUnfriendly(ingredient)) {
            if (ingredient) goodIngredients.push(ingredient);
        }
    });

    pass = !(badIngredients.length != 0);
    if (!mayContainGluten) mayContainGluten = (unsureIngredients.length != 0);

    res.setHeader('Content-Type', 'application/rawIngredients');
    res.send(JSON.stringify({
        Bad_Ingredients: badIngredients,
        Unsure_Ingredients: unsureIngredients,
        Good_Ingredients: goodIngredients,
        May_Contain: mayContain,
        isGlutenFree: pass,
        mayContainGluten: mayContainGluten
    }));

    /********************* Helper functions **************************/
    function formatRawIngredients(rawIngredients) {
        rawIngredients = rawIngredients.toLowerCase();
        var index = rawIngredients.indexOf("ingredients") + 13;
        rawIngredients = rawIngredients.substring(index, rawIngredients.length - 1);
        rawIngredients = rawIngredients.replace(/(\n)+/g, ' ');
        rawIngredients = rawIngredients.replace(/[.]+/g, ',');
        rawIngredients = rawIngredients.replace(/[)]+/g, ',');
        rawIngredients = rawIngredients.replace(/[(]+/g, '(,');
        rawIngredients = rawIngredients.split(",");

        for (var i=0; i<rawIngredients.length; i++) {
            if (rawIngredients[i].includes("(")) rawIngredients.splice(i, 1);
            rawIngredients[i] = rawIngredients[i].replace(/^\s+|\s+$/g, '');
        }

        return rawIngredients;
    }

    function parseMayContain(ingredient, index) {
        if (ingredient.includes("may contain")) {
            var temp = ingredient.substring(ingredient.indexOf("may contain") + 13, ingredient.length);
            if (temp.includes("wheat")) mayContainGluten = true;
            mayContain.push(temp);

            for (var i = index + 1; i < rawIngredients.length; i++) {
                if (rawIngredients[i].includes("wheat")) mayContainGluten = true;
                mayContain.push(rawIngredients[i]);
            }

            rawIngredients.splice(k, rawIngredients.length - k);
        }
    }

    function isUnsafe(ingredient) {
        var unsafe = false;
        unsafeList.forEach(function (unsafeItem) {
            if (ingredient.includes(unsafeItem)) {
                badIngredients.push(ingredient);
                unsafe = true;
            }
        });

        return unsafe;
    }

    function isUnfriendly(ingredient) {
        var unfriendly = false;
        unfriendlyList.forEach(function (unfriendlyItem) {
            if (ingredient.includes(unfriendlyItem)) {
                unsureIngredients.push(ingredient);
                unfriendly = true;
            }
        });

        return unfriendly;
    }

    // unused function for adding subheadings
    function splitIntoSubgroups(rawIngredients) {
        var subGroupHead = null;

        for (var i = 0; i < rawIngredients.length - 1; ++i) {
            var ingredient = rawIngredients[i];

            if (ingredient.indexOf('(') != -1) {
                var index = ingredient.indexOf('(');
                subGroupHead = ingredient.substr(0, index - 1); //ingredient.replace(/[(]+/g, '');
                rawIngredients[i] = ingredient.substr(index + 1) + "(" + subGroupHead + ")";
            } else if ((ingredient.indexOf(')') != -1) && subGroupHead) {
                rawIngredients[i] = ingredient.replace(/[)]+/g, '') + " (" + subGroupHead + ")";

                subGroupHead = null;
            } else if (subGroupHead) {
                rawIngredients[i] = ingredient + " (" + subGroupHead + ")";
            }
        }
        return rawIngredients;
    }
}
