"use strict"

pg = require 'pg'
helpers = require './query-helpers'
config = require './config'
ObjectID = require('mongodb').ObjectID

pg.connect config.conString, (err, client) ->
  return console.err err if err

  #client.on 'notification', (msg) ->
  #console.log(msg)
  
  #query = client.query("LISTEN watchers")


  helpers.makeOidForTables client, config.from, config.oid, (err, data) ->
    console.log err, data
    client.end ->
      console.log 'client.end'

