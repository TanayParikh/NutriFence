module.exports.setupExpressServer = function() {
    var express = require('express'),
        app = express(),
        bodyParser = require('body-parser'),
        path = require("path");

    // add support for parsing different types of post data
    app.use(bodyParser.json({limit: '2.5mb'}));
    app.use(bodyParser.urlencoded({limit: '2.5mb', extended: true}));

    // tell express that www is the root of our public web folder
    app.use(express.static(path.join(__dirname, 'www')));

    // tell express what to do when the /ClassificationAPI route is requested
    app.post('/ClassificationAPI', function (request, response) {
        interpretAndSendData(request, response);
    });

    // Waits for connection
    app.listen(process.env.PORT || 3000, function () {
        console.log('Server is running using express.js');
    });
};

module.exports.imageOCR = function(req) {
    var request = require('sync-request');
    var requestURL = 'https://vision.googleapis.com/v1/images:annotate?key=' + process.env.GOOGLE_VISION_API_KEY;

    var res = request('POST', requestURL, {
        json:
        {
            "requests": [
                {
                    "image":{
                        "content": req.body.request.imageContent
                    },
                    "features": [
                        {
                            "type":"TEXT_DETECTION",
                            "maxResults":1
                        }
                    ]
                }
            ]
        }
    });

    return JSON.parse(res.getBody('utf8')).responses[0].textAnnotations[0].description;
};