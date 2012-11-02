#RADeli

Live demo at:  

`http://radeli.jit.su`

**RADeli** is a tool to generate a simple website where you serve a random article to each visitor.  
The concept is to delete the articles from the database every X amout of months/days using MongoDB's TTL collections.
To turn on this feature run the following command:

`db.articles.ensureIndex({"TTL": 1}, {expireAfterSeconds: X})`

**Modify X accordingly**

Requires mongodb, express, socket.io, postmark

It was a weekend hack :) so if you find bugs, have feature requests or just want to make it better feel free to
contact me at yamil.asusta@upr.edu

Enjoy :)