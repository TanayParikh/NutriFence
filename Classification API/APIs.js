require('dotenv').config();

module.exports.imageOCR = function(req) {
    var request = require('sync-request');
    var requestURL = 'https://vision.googleapis.com/v1/images:annotate?key=' + process.env.GOOGLE_VISION_API_KEY;

    var res = request('POST', requestURL, {
        json:
        {
            "requests": [
                {
                    "image":{
                        "content": req.body.request.imageContent
                    },
                    "features": [
                        {
                            "type":"TEXT_DETECTION",
                            "maxResults":1
                        }
                    ]
                }
            ]
        }
    });
    return JSON.parse(res.getBody('utf8')).responses[0].textAnnotations[0].description;
};


module.exports.parseAndSpellCheck = function(rawData) {
    return new Promise(function(resolve, reject) {
        var rawIngredients = parseIngredients(rawData);

        var request = require('request');

        // Set the headers
        var headers = {
            'Ocp-Apim-Subscription-Key': process.env.BING_SPELLCHECK_API_KEY
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

            resolve(rawIngredients);
        });
    })
};


// Helper functions for parseAndSpellCheck
function parseIngredients(rawData) {
    rawData = rawData.toLowerCase();
    var index = rawData.indexOf("ingredients:") + 13;
    rawData = rawData.substring(index, rawData.length - 1);
    rawData = rawData.replace(/(\n)+/g, ' ');
    rawData = rawData.replace(/[.]+/g, ',');
    return rawData;
}

function correctSpellingErrors(response, rawIngredients) {
    var spellChecked = JSON.parse(response);

    spellChecked.flaggedTokens.forEach(function (word) {
        rawIngredients = rawIngredients.replace(word.token, word.suggestions[0].suggestion);
    });

    return rawIngredients;
}
