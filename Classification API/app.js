// import required modules
var servers = require('./serverSetup');
var API = require('./APIs');
var interpret = require('./interpret');

// set up the express server to call interpretAndSendData when a post request is made
servers.setupExpressServer(interpretAndSendData);

function interpretAndSendData(req, res) {
    // Pull the required database from redis
    // TODO: pull out the 'key' from the request indicating which database to use (for now, use CeliacUnsafe)
    var key = 'CeliacUnsafe';
    var p1 = servers.getFromDB(key);

    // Handle the request: send to OCR, then parse and send to spell check
    var imageContent = API.imageOCR(req);
    var p2 = API.parseAndSpellCheck(imageContent);

    // Once both promises are resolved: determine results and send back response
    Promise.all([p1, p2]).then(function (values) {
        var unsafeList = values[0];
        var ingredients = values[1];

        var results = interpret.getResults(unsafeList, ingredients);
        
        res.setHeader('Content-Type', 'application/rawIngredients');
        res.send(JSON.stringify({
            Bad_Ingredients: results[0],    // array
            Good_Ingredients: results[1],   // array
            May_Contain: results[2],        // array
            Passes_Test: results[3]         // bool
        }));
    }, function (err) {
        console.log("Error: " + err);
    });
}