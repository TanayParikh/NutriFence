
// deleteFromDatabase('Test');
// addToRedis('test.txt', 'Test');
// updateExisting('test.txt', 'Test');

/*
 * addToRedis: str str -> none
 * 
 * Takes 2 inputs:
 *      path to a text file containing the elements you want to input in your database
 *      what you want to name your database
 *
 * Checks to see if there's already a database with this name
 * If not, it reads the file specified by the inputted filePath and adds the elements
 * in that file to a database in Redis with the inputted name.
 */
function addToRedis(filePath, databaseName) {
    var redis = require('redis');
    var client = redis.createClient();
    client.on('connect', function() {
        console.log('Redis connection established.');
    });

    client.exists(databaseName, function(err, reply) {
        if (reply) {
            console.log("Error: a database already exists with this name.");
            return;
        }

        var fs = require('fs');
        var newDB = fs.readFileSync(filePath,'utf-8');
        newDB = newDB.split("\n");
        newDB = newDB.unshift(databaseName);

        client.sadd(newDB);

        console.log("New Database '" + databaseName + "' Added: ");

        client.smembers(databaseName, function(err, reply) {
            console.log(reply);
        });
    });
}

/*
 * deleteFromDatabase: str -> none
 *
 * Takes 1 input: name of database you want to delete
 *
 * Deletes a database in Redis. If it doesn't exist, logs an error message.
 */
function deleteFromDatabase(databaseName) {
    var redis = require('redis');
    var client = redis.createClient();
    client.on('connect', function() {
        console.log('Redis connection established.');
    });

    client.del(databaseName, function (err, reply) {
        if (reply) console.log("deleted");
        else console.log("Error: database does not exist");
    });
}

/*
 * updateExisting: str str -> none
 *
 * Takes 2 inputs:
 *      path to a text file containing the database's elements
 *      name of the database
 *
 * Deletes the database you inputted. If it doesn't exist, throws an error.
 * Then, recreates the database with the elements in the inputted file.
 */
function updateExisting(filePath, databaseName) {
    var redis = require('redis');
    var client = redis.createClient();
    client.on('connect', function() {
        console.log('Redis connection established.');
    });

    client.del(databaseName, function (err, reply) {
        if (!reply) throw new Error("Can't update database '" + databaseName +"', it doesn't exist.");

        var fs = require('fs');
        var newDB = fs.readFileSync(filePath,'utf-8');
        newDB = newDB.split("\n");
        newDB = newDB.unshift(databaseName);

        client.sadd(newDB);

        console.log("Database '" + databaseName + "' Updated: ");

        client.smembers(databaseName, function(err, reply) {
            console.log(reply);
        });
    });
}

// used in app.js to pull list of members of a database from Redis
module.exports.getFromDB = function(key) {
    return new Promise(function(resolve, reject) {
        var redis = require('redis');
        var client = redis.createClient();

        client.on('connect', function() {
            console.log('Redis connection established.');
        });

        client.smembers(key, function(err, list) {
            resolve(list);
        });
    });
};