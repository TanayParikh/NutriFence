var redis = require('redis');
var client = redis.createClient();

client.on('connect', function() {
    console.log('connected');
});

client.scard("Celiac Unsafe", redis.print);
client.scard("Celiac Unfriendly", redis.print);

var express = require('express');

/*var app = express();

app.get('/notes', function(req, res) {
    res.json({notes: "This is your notebook. Edit this to start saving your notes!"})
});

app.listen(3000);

var bodyParser = require('body-parser');
var app = express();
port = parseInt(process.env.PORT, 10) || 8080;

// parse application/x-www-form-urlencoded
app.use(bodyParser.urlencoded({ extended: true }));

// parse application/json
app.use(bodyParser.json());

app.listen(port);

app.post("/someRoute", function(req, res) {
    console.log(req.body);
    res.status(200).json({ status: 'SUCCESS' });
}*/