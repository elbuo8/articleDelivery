require 'coffee-script'
mongo = require 'mongodb' 
#db = new mongo.Db('test', new mongo.Server('localhost', 27017, {auto_reconnect:true}));
express = require 'express'
app = express()
http = require 'http'
server = http.createServer(app)
sio = require 'socket.io'
io = sio.listen(server)
postmark = (require 'postmark') 'KEY'
sanitize = (require 'validator').sanitize


db = null
mongo.Db.connect('URI', (error, database) ->
	db = database if !error
	db.authenticate('USER','PWD', (error) -> 
		)
	)

#app.use(express.bodyParser())
app.use(express.static(__dirname + '/public'))

io.sockets.on 'connection', (socket) ->
	socket.on 'getArticle', ->
		db.collection 'articles', (error, collection) ->
			total = 0
			collection.count({}, (error, count) ->
				collection.find().limit(-1).skip(Math.floor(Math.random()*count)).toArray (error, article) ->
					if !error
						socket.emit 'sendArticle', article[0]
					return
			) 

	socket.on 'reportArticle', (parse) ->
		db.collection 'articles', (error, collection) ->
			collection.update({"_id": new mongo.ObjectID(parse._id)}, {$inc:{"reports":1}}, (error, article) ->
				return
			) if !error
		db.collection 'articles', (error, collection) ->
			collection.findOne({"_id": new mongo.ObjectID(parse._id)}, (error, article) ->
				if article.reports >= 5
					postmark.send({
						"From" :"yamil.asusta@upr.edu",
						"To" : article.email,
						"Subject" : "Article Deleted",
						"TextBody" : "Hello " + article.submitter + ",\nWe regret to inform you that your article " + article.title + " was deleted from our DB by our visitors.\n\nRegards"
					}) if article.email?
					collection.remove({"_id": new mongo.ObjectID(parse._id)})
			) if !error
	
	socket.on 'addArticle', (data) ->
		
		if (data.title != sanitize(data.title).xss() or data.submitter != sanitize(data.submitter).xss() or data.twitterhandle != sanitize(data.twitterhandle).xss()) 
			socket.emit('submissionResult', {result : false}) 
		else 
			db.collection 'articles', (error, collection) ->
				collection.insert(data, {safe:true}, (error, result) ->
					socket.emit('submissionResult', {result : true}) if !error	 
					) if !error
		
		
			
server.listen(1337)
console.log 'Running on port 1337'
