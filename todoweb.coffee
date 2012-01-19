fs		= require 'fs'
connect	= require 'connect'
jade	= require 'jade'

model = require './model'

template = jade.compile (fs.readFileSync 'template.jade', 'utf8'), {filename : 'template.jade'}

router = connect.router (app) ->
	app.post '/login', (req, res, next) ->
		if not req.body.username and req.body.password
			res.writeHead 500
			res.end()
			return
		fs.readFile 'users.json', 'utf8', (err, cnt) ->
			throw err if err
			users = JSON.parse cnt
			user = users.filter (u) ->
				u.username is req.body.username and u.password is req.body.password
			if user and user.length is 1
				user = user[0]
				req.session.username = user.username
			res.writeHead 302, { Location : '/'}
			res.end()
	app.get '/logout', (req, res, next) ->
		req.session.username = null
		res.writeHead 302, { Location : '/'}
		res.end()
	app.get '/', (req, res, next) ->
		page = template {req : req, todos : model.findAll()}
		res.writeHead 200, {'Content-Type' : 'text/html; charset=UTF-8'}
		res.end page
	app.post '/new', (req, res, next) ->
		if req.session.username
			model.newTodo req.session.username, req.body.todo
		res.writeHead 302, { Location : '/'}
		res.end()
	app.get '/workOn/:id', (req, res, next) ->
		if req.session.username
			model.workOn req.session.username, parseInt(req.params.id, 10)
		res.writeHead 302, { Location : '/'}
		res.end()
	app.get '/leave/:id', (req, res, next) ->
		if req.session.username
			model.leave req.session.username, parseInt(req.params.id, 10)
		res.writeHead 302, { Location : '/'}
		res.end()
	app.get '/end/:id', (req, res, next) ->
		if req.session.username
			model.end req.session.username, parseInt(req.params.id, 10)
		res.writeHead 302, { Location : '/'}
		res.end()
	app.post '/edit', (req, res, next) ->
		if req.session.username
			model.edit parseInt(req.body.id, 10), req.body.todo
		res.writeHead 302, { Location : '/'}
		res.end()
	app.get '/reopen/:id', (req, res, next) ->
		if req.session.username
			model.reopen parseInt(req.params.id, 10)
		res.writeHead 302, { Location : '/' }
		res.end()

server = connect connect.responseTime(),
				 connect.logger(),
				 connect.bodyParser(),
				 connect.cookieParser(),
				 connect.session({secret : 'pssstt'}),
				 connect.static("#{__dirname}/static"),
				 connect.staticCache(),
				 router,
				 connect.errorHandler({showStack : yes, dump : yes})

server.listen 3000
