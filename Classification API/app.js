var redis = require('redis');
var client = redis.createClient();

client.on('connect', function() {
    console.log('connected');
});
