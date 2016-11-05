var redis = require('redis');
var client = redis.createClient();

client.on('connect', function() {
    console.log('app connected');
});

var populateDatabase = require("./populateDatabase.js");

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
	var description = req.body.responses.textAnnotations[0].description;

    res.setHeader('Content-Type', 'application/json');

    //mimic a slow network connection
    setTimeout(function(){

        res.send(JSON.stringify({
            First: description,
        }));

    }, 1000)

    //debugging output for the terminal
    console.log('you posted: First: ' + description);
});

//wait for a connection
app.listen(3000, function () {
    console.log('Server is running. Point your browser to: http://localhost:3000');
});