"use strict"

pg = require 'pg'
assert = require 'assert'
helpers = require './../coffee/query-helpers.coffee'
config = require './../coffee/config.coffee'

client = null

before (done) ->
  pg.connect config.conString, (err, c) ->
    throw err if err
    client = c
    done()

beforeEach (done) ->
  client.query 'TRUNCATE calendar, calendar_entry;', (err) ->
    throw err if err
    sql = "
      INSERT INTO calendar (id, name, owner) VALUES
        (1, 'Work', 'Steve Jobs'),
        (2, 'Work', 'Bill Gates');

      INSERT INTO calendar_entry (id, calendar, title, day) VALUES
        (1, 1, 'Unveil the iPhone', '2007-06-29'),
        (2, 1, 'New iMac', '2007-08-07'),
        (3, 1, 'Launch Mac OS X 10.5', '2007-10-27'),
        (4, 1, 'Launch iPhone 3G', '2008-07-11'),
        (5, 2, 'Ralease Windows Vista', '2007-01-30');
    "
    client.query sql, (err) ->
      throw err if err
      done()

describe 'query-helpers', ->
  describe '#insertOIDsForTables()', ->
    it 'should insert ObjectIDs for all rows without ObjectIDs', (done) ->
      helpers.insertOIDsForTables client, config.from, config.oid, (err, data) ->
        throw err if err
        
        sql = "
          SELECT oe.oid AS entry_oid, oc.oid AS cal_oid
          FROM calendar_entry AS e
          LEFT JOIN objectid AS oe ON oe.type='E' AND oe.id=e.id
          LEFT JOIN objectid AS oc ON oc.type='C' AND oc.id=e.calendar
        "

        client.query sql, (err, result) ->
          cache = []
          assert.equal result.rows.length, 5
          for row in result.rows
            assert.equal typeof row.entry_oid, 'string'
            assert not (row.entry_oid in cache)
            assert.equal typeof row.cal_oid, 'string'
            cache.push row.entry_oid

          done()

