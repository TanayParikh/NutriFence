var redis = require('redis');
var client = redis.createClient();

client.on('connect', function() {
    console.log('connected');
});

client.scard("Celiac Unsafe", redis.print);
client.scard("Celiac Unfriendly", redis.print);
