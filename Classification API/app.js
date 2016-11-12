var unsafeList;
var unfriendlyList;
var redisClient = setupRedis();
var autoCorrectAPIKey = getBingSpellcheckAPIKey();
setupExpressServer();


// start Redis
function setupRedis() {
    var redis = require('redis');
    var client = redis.createClient();
    client.on('connect', function () {
        console.log('Redis connection established.');
    });

    // fetch the unsafe/unfriendly ingredients data from Redis
    var populateDatabase = require("./populateDatabase.js");
    populateDatabase.addCeliacUnsafe();
    populateDatabase.addCeliacUnfriendly();
    // populateDatabase.printMembers();                         // uncomment for testing

    client.smembers('Celiac Unsafe', function(err, list) {
        unsafeList = list;
    });


    client.smembers('Celiac Unfriendly', function(err, list) {
        unfriendlyList = list;
    });

    return client;
}

// gets autocorrect api key from file
function getBingSpellcheckAPIKey() {
    var fileName = './azure_autocorrect_api_key.txt';
    var fs = require('fs');
    var autoCorrectAPIKey = fs.readFileSync(fileName, 'utf8');
    return autoCorrectAPIKey;
}

function setupExpressServer() {
    var express = require('express'),
        app = express(),
        bodyParser = require('body-parser'),
        path = require("path");

    // add support for parsing different types of post data
    app.use(bodyParser.json());
    app.use(bodyParser.urlencoded({extended: true}));

    // tell express that www is the root of our public web folder
    app.use(express.static(path.join(__dirname, 'www')));

    // tell express what to do when the /ClassificationAPI route is requested
    app.post('/ClassificationAPI', function (request, response) {
        interpretAndSendData(request, response);
    });

    // wait for a connection
    app.listen(3000, function () {
        console.log('Server is running using express.js');
    });
}


var res;
function interpretAndSendData(req, response) {
    res = response;
    var rawIngredients = req.body.responses[0].textAnnotations[0].description;
    // rawIngredients = splitIntoSubgroups(rawIngredients);             // adds supheadings - buggy though

    // format the raw ingredients
    rawIngredients = rawIngredients.toLowerCase();
    var index = rawIngredients.indexOf("ingredients") + 13;
    rawIngredients = rawIngredients.substring(index, rawIngredients.length - 1);
    rawIngredients = rawIngredients.replace(/(\n)+/g, ' ');
    rawIngredients = rawIngredients.replace(/[.]+/g, ',');
    
    spellCheckIngredients(rawIngredients);

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

function spellCheckIngredients(rawIngredients) {
    var request = require('request');

    // Set the headers
    var headers = {
        'Ocp-Apim-Subscription-Key': autoCorrectAPIKey
        //'Content-Type':     'application/x-www-form-urlencoded'
    };

    // Configure the request
    var options = {
        url: 'https://api.cognitive.microsoft.com/bing/v5.0/spellcheck/',
        method: 'GET',
        headers: headers,
        qs: {'text': rawIngredients, 'mode': 'proof'}
    };

    // Start the request
    request(options, function (error, response, body) {
        if (!error && response.statusCode == 200) {
            rawIngredients = correctSpellingErrors(body, rawIngredients);
        } else {
            console.log("Issue with trying to connect to spellcheck API");
            console.log("ERROR:  " + error);
            console.log("STATUS:  " + response.statusCode);
            console.log("BODY: " + body);
        }
        
        formatRawIngredients2(rawIngredients);
    });

    function correctSpellingErrors(response, rawIngredients) {
        var spellChecked = JSON.parse(response);

        spellChecked.flaggedTokens.forEach(function (word) {
            rawIngredients = rawIngredients.replace(word.token, word.suggestions[0].suggestion);
        });

        return rawIngredients;
    }
}

function formatRawIngredients2(rawIngredients) {
    rawIngredients = rawIngredients.replace(/[)]+/g, ',');
    rawIngredients = rawIngredients.replace(/[(]+/g, '(,');
    rawIngredients = rawIngredients.split(",");

    for (var i=0; i<rawIngredients.length; i++) {
        if (rawIngredients[i].includes("(")) rawIngredients.splice(i, 1);
        rawIngredients[i] = rawIngredients[i].replace(/^\s+|\s+$/g, '');
    }

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
}
