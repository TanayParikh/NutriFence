// Sets up Express server
module.exports.setupExpressServer = function(responseFunc) {
    var express = require('express'),
        app = express(),
        bodyParser = require('body-parser'),
        path = require('path');

    // add support for parsing different types of post data
    app.use(bodyParser.json({limit: '2.5mb'}));
    app.use(bodyParser.urlencoded({limit: '2.5mb', extended: true}));

    // tell express that www is the root of our public web folder
    app.use(express.static(path.join(__dirname, 'www')));

    // tell express what to do when the /ClassificationAPI route is requested
    app.post('/ClassificationAPI', function (request, response) {
        responseFunc(request, response);
    });

    // Waits for connection
    app.listen(process.env.PORT || 3000, function () {
        console.log('Server is running using express.js');
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