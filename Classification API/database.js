/*
 * Note about database naming conventions:
 * For consistency, all databases and their corresponding text files
 * are going to be named in camel case with the first letter being uppercase
 */

databaseOperation();

function databaseOperation() {
    const readline = require('readline');
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
    });

    rl.question("What database operation would you like to perform? \n" +
        "1: delete a database \n" +
        "2: add a database to Redis \n" +
        "3: update a database already in Redis \n", function(res) {

        var fileName, dbName;
        switch (res) {
            case '1':
                rl.question("What is the name of the database you want to delete? \n", function(res) {
                    dbName = res;
                    deleteFromDatabase(dbName);
                    rl.close();
                });
                break;
            case '2':
                rl.question("What is the name of the text file you have added " +
                    "(include the .txt extension)? \n", function(res) {
                    fileName = res;
                    dbName = fileName.replace('.txt','');
                    addToRedis(fileName, dbName);
                    rl.close();
                });
                break;
            case '3':
                rl.question("What is the name of the text file you have edited " +
                    "(include the .txt extension)? \n", function(res) {
                    fileName = res;
                    dbName = fileName.replace('.txt','');
                    updateExisting(fileName, dbName);
                    rl.close();
                });
                break;
            default:
                console.log("Sorry, that was not a valid choice.");
                rl.close();
                break;
        }
    });
}

/*
 * addToRedis: str str -> none
 * 
 * Takes 2 inputs:
 *      name of text file containing the elements you want to input in your database
 *      what you want to name your database
 *
 * Checks to see if there's already a database with this name
 * If not, it reads the file specified by the inputted fileName and adds the elements
 * in that file to a database in Redis with the inputted name.
 */
function addToRedis(fileName, databaseName) {
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
        var newDB = fs.readFileSync('Ingredients/' + fileName,'utf-8');
        newDB = newDB.split("\n");
        newDB.unshift(databaseName);
        
        client.sadd(newDB);

        client.smembers(databaseName, function(err, reply) {
            console.log("New Database '" + databaseName + "' Added: ");
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
 *      name of text file containing the database's elements
 *      name of the database
 *
 * Deletes the database you inputted. If it doesn't exist, throws an error.
 * Then, recreates the database with the elements in the inputted file.
 */
function updateExisting(fileName, databaseName) {
    var redis = require('redis');
    var client = redis.createClient();
    client.on('connect', function() {
        console.log('Redis connection established.');
    });

    client.del(databaseName, function (err, reply) {
        if (!reply) throw new Error("Can't update database '" + databaseName +"', it doesn't exist.");

        var fs = require('fs');
        var newDB = fs.readFileSync('Ingredients/' + fileName,'utf-8');
        newDB = newDB.split("\n");
        newDB.unshift(databaseName);

        client.sadd(newDB);

        client.smembers(databaseName, function(err, reply) {
            console.log("Database '" + databaseName + "' Updated: ");
            console.log(reply);
        });
    });
}