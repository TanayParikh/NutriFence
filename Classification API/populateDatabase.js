var redis = require('redis');
var client = redis.createClient();

client.on('connect', function() {
    console.log('populateDatabase connected');
});

var exports = module.exports = {};

exports.addCeliacUnsafe = function() {
    client.exists('Celiac Unsafe', function(err, reply) {
        if (reply) return;
        client.sadd(['Celiac Unsafe',
            'abyssinian hard (wheat triticum durum)',
            'atta flour',
            'barley grass',
            'barley hordeum vulgare',
            'barley malt',
            'barley malt extract',
            'beer',
            'bleached flour',
            'bran',
            'bread flour',
            'brewer\'s yeast',
            'brown flour',
            'bulgur wheat',
            'bulgur nuts',
            'cereal binding',
            'chilton',
            'club wheat (triticum aestivum subspecies compactum)',
            'common wheat (triticum aestivum)',
            'cookie crumbs',
            'cookie dough',
            'cookie dough pieces',
            'couscous',
            'criped rice',
            'dinkle (spelt)',
            'disodium wheatgermamido peg-2 sulfosuccinate',
            'durum wheat (triticum durum)',
            'edible coatings',
            'edible films',
            'edible starch',
            'einkorn (triticum monococcum)',
            'emmer (triticum dicoccon) ',
            'enriched bleached flour',
            'enriched bleached wheat flour',
            'enriched flour',
            'farik',
            'farina ',
            'farina graham ',
            'farro',
            'filler',
            'freekeh',
            'frikeh',
            'fu',
            'germ ',
            'graham flour',
            'granary flour',
            'groats',
            'hard wheat',
            'heeng',
            'hing',
            'hordeum vulgare extract',
            'hydroxypropyltrimonium hydrolyzed wheat protein',
            'kamut',
            'kecap manis',
            'ketjap manis',
            'kluski pasta',
            'maida',
            'malt',
            'malted barley flour',
            'malted milk',
            'malt extract',
            'malt syrup',
            'malt flavoring',
            'malt vinegar ',
            'macha wheat (triticum aestivum) ',
            'matza',
            'matzah',
            'matzo',
            'matzo semolina',
            'meripro 711',
            'mir',
            'nishasta',
            'oriental wheat (triticum turanicum)',
            'orzo pasta',
            'pearl barley',
            'persian wheat (triticum carthlicum)',
            'perungayam',
            'poulard wheat (triticum turgidum)',
            'polish wheat (triticum polonicum)',
            'rice malt',
            'roux',
            'rusk',
            'rye',
            'seitan',
            'semolina',
            'semolina triticum',
            'shot wheat (triticum aestivum)',
            'small spelt',
            'spirits (specific types)',
            'spelt (triticum spelta)',
            'sprouted barley',
            'sprouted wheat',
            'stearyldimoniumhydroxypropyl hydrolyzed wheat protein',
            'strong flour',
            'suet in packets',
            'tabbouleh',
            'tabouli',
            'teriyaki sauce',
            'timopheevi wheat (triticum timopheevii)',
            'triticale x triticosecale',
            'triticum vulgare (wheat) flour lipids',
            'triticum vulgare (wheat) germ extract',
            'triticum vulgare (wheat) germ oil',
            'udon',
            'unbleached flour',
            'vavilovi wheat (triticum aestivum)',
            'vital wheat gluten',
            'wheat, abyssinian hard triticum durum',
            'wheat amino acids',
            'wheat bran extract',
            'wheat',
            'bulgur',
            'wheat durum ctriticum',
            'wheat germ extract',
            'wheat germ glycerides',
            'wheat germ oil',
            'wheat germamidopropyldimonium hydroxypropyl hydrolyzed wheat protein',
            'wheat grass',
            'wheat nuts',
            'wheat protein',
            'wheat triticum aestivum',
            'wheat triticum monococcum',
            'wheat (triticum vulgare) bran extract',
            'whole-meal flour',
            'wild einkorn (triticum boeotictim)',
            'wild emmer (triticum dicoccoides)'
        ], function (err, reply) {
            if (err) console.log("Error in populating Celiac Unsafe");
        });
    });
};

exports.addCeliacUnfriendly = function() {
    client.exists('Celiac Unfriendly', function(err, reply) {
        if (reply) return;
        client.sadd(['Celiac Unfriendly',
            'protein',
            'artificial color',
            'baking powder',
            'clarifying agents',
            'coloring',
            'dry roasted nuts',
            'emulsifiers',
            'enzymes',
            'fat replacer',
            'gravy cubes',
            'ground spices4',
            'hydrolyzed wheat gluten',
            'hydrolyzed wheat protein',
            'hydrolyzed wheat protein pg-propyl silanetriol',
            'hydrolyzed wheat starch',
            'hydrogenated starch hydrolysate',
            'hydroxypropylated starch',
            'miso',
            'non-dairy creamer',
            'pregelatinized starch',
            'protein hydrolysates',
            'seafood analogs',
            'seasonings',
            'sirimi',
            'soba noodles',
            'soy sauce',
            'soy sauce solids',
            'sphingolipids',
            'stabilizers',
            'starch',
            'stock cubes',
            'suet',
            'tocopherols',
            'vegetable broth',
            'vegetable gum',
            'vegetable protein',
            'vegetable starch',
            'vitamins'
        ], function (err, reply) {
            if (err) console.log("Error in populating Celiac Unfriendly");
        });
    });
};

exports.printMembers = function() {
    console.log("Celiac Unsafe: ");
    client.smembers('Celiac Unsafe', function(err, reply) {
        console.log(reply);
    });

    console.log("Celiac Unfriendly: ");
    client.smembers('Celiac Unfriendly', function(err, reply) {
        console.log(reply);
    });
};
