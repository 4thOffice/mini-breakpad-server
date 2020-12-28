bodyParser = require 'body-parser'
methodOverride = require('method-override')
path = require 'path'
express = require 'express'
reader = require './reader'
saver = require './saver'
remover = require './remover'
Database = require './database'
WebHook = require './webhook'

app = express()
webhook = new WebHook

db = new Database
db.on 'load', ->
  port = process.env.MINI_BREAKPAD_SERVER_PORT ? 80
  app.listen port
  console.log "Listening on port #{port}"

app.set 'views', path.resolve(__dirname, '..', 'views')
app.set 'view engine', 'pug'
app.use bodyParser.json()

app.use express.static(path.join(__dirname, '..', 'public'))
app.use bodyParser.urlencoded({ extended: true })
app.use methodOverride()
app.use (err, req, res, next) ->
  res.send 500, "Bad things happened:<br/> #{err.message}"

app.post '/webhook', (req, res, next) ->
  webhook.onRequest req

  console.log 'webhook requested', req.body.repository.full_name
  res.end()

app.post '/post', (req, res, next) ->
  saver.saveRequest req, db, (err, filename) ->
    return next err if err?

    console.log 'saved', filename
    res.send path.basename(filename)
    res.end()

root =
  if process.env.MINI_BREAKPAD_SERVER_ROOT?
    "#{process.env.MINI_BREAKPAD_SERVER_ROOT}/"
  else
    ''

app.get '/delete-dump/:dumpId', (req, res, next) ->
  if req.query.key != process.env.API_KEY then () ->
    console.log 'wrong key in query. Is', req.query.key, ' but should be:', process.env.API_KEY
    res.send 401, "Wrong authorization"
    res.end()
    return

  console.log 'will delete: ', req.params.dumpId
  db.restoreRecord req.params.dumpId, (err, record) ->
    db.deleteRecord req.params.dumpId, (err) ->
      remover.removeMinidump record, (err) ->
        res.redirect "/#{root}"

app.get "/#{root}", (req, res, next) ->
  res.render 'index', title: 'Crash Reports', records: db.getAllRecords()

app.get "/#{root}view/:id", (req, res, next) ->
  db.restoreRecord req.params.id, (err, record) ->
    return next err if err?

    reader.getStackTraceFromRecord record, (err, report) ->
      return next err if err?
      fields = record.fields
      res.render 'view', { title: 'Crash Report: ' + req.params.id, report, fields }
