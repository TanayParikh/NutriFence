/*
 * 1. Set up the express server to listen for requests
 * 2. Upon reception of a request, simultaneously
 *      pull out 'key' indicating which ingredients database to pull info from -> pull this from Redis -> return list
 *      send request to OCR -> parse return information -> send to spellcheck -> return raw ingredients list
 * 3. Once both are resolved, compare both lists and determine results
 */

