# ArchHacks 2016: NutriFence
#### Matthew Watt, Tanay Parikh, Isabelle Sauve, Daihan Zhu

### Core Features:
- NutriFence is an iOS app that allows you to take an image of a list of ingredients and 
  have it tell you whether or not that item is safe for consumption
- Core requirements: 
   - Capture the image & format it correctly
   - Send this image to Processing API (OCR)
   - Send the OCR results to the Classification API
   - Recieve and display information on the safety of the ingredients


### Components
#### Database
- Redis (Mac): http://redis.io/download
- Redis (Windows): https://github.com/MSOpenTech/redis/releases

#### OCR
- Google Cloud Vision API: https://cloud.google.com/vision/docs/


### Classification API
#### Requirements
- Recieve a POST request in JSON format from the app
- Compare this information to a database of "unsafe" items
- Determine which ingredients are 'safe', which are 'unsafe', which are 'risky'
  and send these back to the app
- Draw conclusions based on extracted data and send this back to the app
   - is it definitely not gluten-free?
   - are there contains that indicate it might not be gluten-free?
   - does the item actually say "may contain wheat" on it?

#### Implementation
- uses Redis as a data store for storing the categorization of ingredients
- uses ExpressJS and Node.js to recieve and handle POST request
- pulls lists of unsafe/unfriendly ingredients from Redis, then parses the request
- execute algorithm for cleaning up the raw data recieved
- sort every item into appropriate category by comparing the ingredients in the request
  with the lists of ingredients from Redis
- return data & conclusions in JSON format back to the app (POST reply)
