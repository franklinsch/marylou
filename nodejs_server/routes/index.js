var express = require('express');
var router = express.Router();

/* GET New User page. */
router.get('/testjson', function(req, res) {
  fs = require('fs')
  fs.readFile('/home/ubuntu/marylou/website/public/examples/example.json', 'utf8', function (err,data) {
    if (err) {
      return console.log(err);
    }
      res.send(data);
  });
});

/* GET Userlist page. */
router.get('/getcountries', function(req, res) {
    var db = req.db;
    var collection = db.get('countries');
    var countries = [];
    collection.find({},{},function(e,docs){
	for (var i = 0; i < docs.length; i++) {
          if (docs[i].country != null) {
	    countries.push(docs[i].country);
          }
	}
        res.json(countries);
    });
});


/* GET Country List json */
router.get('/countrylist', function(req, res) {
  res.header("Access-Control-Allow-Origin", "http://localhost");
  res.header("Access-Control-Allow-Methods", "GET, POST");
  // The above 2 lines are required for Cross Domain Communication(Allowing the methods that come as Cross           
  // Domain Request
  db.countries.find('', function(err, users) {
    if( err || !users) console.log("No users found");
      else 
    {
      res.writeHead(200, {'Content-Type': 'application/json'}); // Sending data via json
    	str='[';
    	users.forEach( function(user) {
    	  str = str + '{ "name" : "' + user.country + '"},' +'\n';
	});
	str = str.trim();
	str = str.substring(0,str.length-1);
	str = str + ']';
	res.end( str);
        // Prepared the jSon Array here
	}
  });
});

/* POST  */
router.post('/getcities', function(req, res) {
    var ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress;
    console.log('\n\nClient IP:', ip);

    var country = req.body.country;
    var field1  = req.body.field1;

    console.log("Parameters:\n" +
                "\ncountry:\t" + country +
                "\nfield1:\t\t" + field1);

    // Setup spawn
    var spawn = require('child_process').spawn;
    
    // Start and Finish Java process
    console.log("Starting Java process");
    var javae = spawn('/usr/bin/java', ['-ea', '-cp', '/home/ubuntu/marylou/bloomberg_request/bin:/home/ubuntu/marylou/bloomberg_request/org.json-20120521.jar', 'bloomberg_request.Main', country, field1]);
    console.log("Finishing Java process");

    // Send the data from the command back to the requester
    javae.stdout.on('data', function(data) {
      res.write(data);
    });
    
    // On no more data, close the response, completing the command.
    javae.on('close', function(code) {
      res.end();
    });
});

module.exports = router;
