"use strict"

pg = require 'pg'
helpers = require './query-helpers'
config = require './config'
ObjectID = require('mongodb').ObjectID

pg.connect config.conString, (err, client) ->
  return console.err err if err

  helpers.insertOIDsForTables client, config.from, config.oid, (err, data) ->
    return console.log err if err
    
    # Handle incoming notifications
    client.on 'notification', (msg) ->
      # Since we have an older version of Postgres we just do a complete search
      # for rows without ObjectIDs. This can be tweaked for newer version of
      # Postgres which support payload on notifications.
      helpers.insertOIDsForTables client, config.from, config.oid

    # Listen for notifications
    client.query 'LISTEN objectid_watch'
    console.log 'Listening for objectid_watch notifications...'

