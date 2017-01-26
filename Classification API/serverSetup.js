// Sets up Express server
module.exports.setupExpressServer = function(responseFunc) {
    var express = require('express'),
        app = express(),
        bodyParser = require('body-parser'),
        path = require('path'),
        https = require('https'),
        fs = require('fs');

    // Fetches SSL privkey and cert
    var options = {
      key: fs.readFileSync('/etc/letsencrypt/live/node.nutrifence.com/privkey.pem', 'utf-8'),
      cert: fs.readFileSync('/etc/letsencrypt/live/node.nutrifence.com/cert.pem', 'utf-8'),
    };

    // add support for parsing different types of post data
    app.use(bodyParser.json({limit: '2.5mb'}));
    app.use(bodyParser.urlencoded({limit: '2.5mb', extended: true}));

    // tell express that www is the root of our public web folder
    app.use(express.static(path.join(__dirname, 'www')));

    // Spawns https server with SSL cert + privkey
    var server = https.createServer(options, app).listen(process.env.PORT || 4000, function () {
        console.log('Server is running using express.js');
    });

    // tell express what to do when the /ClassificationAPI route is requested
    app.post('/ClassificationAPI', function (request, response) {
        responseFunc(request, response);
    });

    // Informs user of failed GET request
    app.get('/ClassificationAPI', function (req, res) {
        res.writeHead(403);
        res.end("This API Endpoint does not support GET Requests\n");
    });
};


// Connects to redis once
var redis = require('redis');
var client = redis.createClient();

client.on('connect', function() {
    console.log('Redis connection established.');
});

// Pulls list of members of a database from Redis
module.exports.getFromDB = function(key) {
    return new Promise(function(resolve, reject) {
        client.smembers(key, function(err, list) {
            resolve(list);
        });
    });
};
