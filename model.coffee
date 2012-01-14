fs = require 'fs'

todofile = 'todos.json'

todos = JSON.parse fs.readFileSync todofile, 'utf8'

persist = () ->
	fs.writeFileSync todofile, (JSON.stringify todos, null, 4), 'utf8'

exports.findAll = () ->
	todos.map (todo) ->
		todo.epochFormatted = require('formatdate').strftime('%F %T', new Date(todo.epoch))
		return todo

sort = () ->
    todos.sort (a, b) ->
        stati =
            todo : 1
            working : 1
            done : 0
        d = stati[b.stato] - stati[a.stato]
        if not d
            return b.epoch - a.epoch
        else
            return d
sort()

nextId = () ->
	id = 0
	for todo in todos
		id = todo.id if todo.id > id
	return (id + 1)

class Nota
	constructor : (@autore, @testo) ->

class Todo
	constructor : (@autore, @descr) ->
		@id = nextId()
		@in_carico = null
		@stato = 'todo'
		@note = []
		@epoch = new Date().getTime()

exports.newTodo = (autore, descr) ->
	todos.push new Todo(autore, descr)
	sort()
	persist()

on_todo_by_id = (id, callback) ->
	for todo in todos
		if todo.id is id
			callback(todos, todo)
			return

exports.workOn = (user, id) ->
	on_todo_by_id id, (todos, todo) ->
		todo.in_carico = user
		todo.epoch = new Date().getTime()
		todo.stato = 'working'
		sort()
		persist()

exports.leave = (user, id) ->
	on_todo_by_id id, (todos, todo) ->
		if todo.stato is 'working' and todo.in_carico is user
			todo.in_carico = null
			todo.epoch = new Date().getTime()
			todo.stato = 'todo'
			sort()
			persist()

exports.end = (user, id) ->
	on_todo_by_id id, (todos, todo) ->
		if todo.stato is 'working' and todo.in_carico is user
			todo.epoch = new Date().getTime()
			todo.stato = 'done'
			sort()
			persist()

exports.edit = (id, descr) ->
    on_todo_by_id id, (todos, todo) ->
        todo.descr = descr
        todo.epoch = new Date().getTime()
        sort()
        persist()

exports.reopen = (id) ->
	on_todo_by_id id, (todos, todo) ->
		todo.stato = 'todo'
		todo.epoch = new Date().getTime()
		sort()
		persist()
