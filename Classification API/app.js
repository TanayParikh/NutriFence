var redis = require('redis');
var client = redis.createClient();

client.on('connect', function() {
    console.log('app connected');
});

var populateDatabase = require("./populateDatabase.js");

var unsafeList;
client.smembers('Celiac Unsafe', function(err, list) {
    unsafeList = list;
})

var unfriendlyList;
client.smembers('Celiac Unfriendly', function(err, list) {
    unfriendlyList = list;
})

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
	var json = req.body.responses[0].textAnnotations[0].description;
	json = json.toLowerCase();

	var index = json.indexOf("ingredients") + 13;
	json = json.substring(index, json.length-1);
	json = json.replace(/(\n)+/g, ' ');
	json = json.replace(/[(]+/g, ',');
	json = json.replace(/[)]+/g, ',');
	json = json.split(",");

  foreach (item in json) {
    

  }

    res.setHeader('Content-Type', 'application/json');

    //mimic a slow network connection
    setTimeout(function(){

        res.send(JSON.stringify({
            Response:
        }));

    }, 1000);

    //debugging output for the terminal
    console.log('you posted Response: ' + );
});

//wait for a connection
app.listen(3000, function () {
    console.log('Server is running. Point your browser to: http://localhost:3000');
});
