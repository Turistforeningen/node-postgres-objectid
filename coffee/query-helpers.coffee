# 
# Postgress query helpers
#

"use strict"

ObjectID = require('mongodb').ObjectID

getRowsWithoutOID = (from, oid) ->
  sql = [
    "SELECT f.#{from.colId} FROM #{from.table} AS f"
    "LEFT JOIN #{oid.table} AS o ON o.#{oid.colType}='#{from.type}' AND o.#{oid.colId}=f.#{from.colId}"
    "WHERE o.#{oid.colOid} IS NULL"
  ].join(' ') + ';'

  sql

#
# Insert ObjectIDs for specific table
#
insertOidsForTable = (client, insert, oid, cb) ->
  return cb null, 0 if insert.length is 0

  sql = [
    "INSERT INTO #{oid.table} (#{oid.colType}, #{oid.colId}, #{oid.colOid})"
    "VALUES (#{insert.join('),(')})"
  ].join ' '

  client.query sql, (err, result) ->
    console.error err if err
    cb null, insert.length

#
# Make ObjectIDs for all tables
#
makeOidForTables = (client, from, oid, cb, i) ->
  i = i or 0
  
  return cb null, i if i is from.length

  console.log "\nMaking ObjectIDs for table #{from[i].table}"

  insert = []
  count = 0
  query = client.query getRowsWithoutOID from[i], oid

  query.on 'row', (row) ->
    insert.push "'#{from[i].type}', #{row[from[i].colId]}, '#{new ObjectID()}'"
    return if insert.length isnt 500

    insertOidsForTable client, insert, oid, (err, rowCount) ->
      console.error err if err

    count += insert.length
    insert = []
    
    console.log "#{count} OIDs inserted for table #{from[i].table}"

    return

  query.on 'error', (err) ->
    console.error err

  query.on 'end', (result) ->
    count += insert.length
    insertOidsForTable client, insert, oid, (err, rowCount) ->
      console.log "#{count} OIDs inserted for table #{from[i].table}"
      makeOidForTables client, from, oid, cb, ++i

module.exports =
  getRowsWithoutOID: getRowsWithoutOID
  makeOidForTables: makeOidForTables

