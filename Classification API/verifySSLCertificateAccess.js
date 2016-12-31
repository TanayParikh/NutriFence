var fs = require('fs');

var options = {
  key: fs.readFileSync('/etc/letsencrypt/live/node.nutrifence.com/privkey.pem', 'utf-8'),
  cert: fs.readFileSync('/etc/letsencrypt/live/node.nutrifence.com/cert.pem', 'utf-8'),
};

console.log("=== KEY ===")
console.log(options.key);
console.log("=== CERT ===")
console.log(options.cert);
