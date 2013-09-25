# 
# Postgress query helpers
#

"use strict"

ObjectID = require('mongodb').ObjectID

# 
# Get SQL Query Rows Without ObjectID
#
# @param from - 
# @param oid - 
#
# @return {String} sql query
#
_getSqlQueryForRowsWithoutOID = (from, oid) ->
  sql = [
    "SELECT f.#{from.colId} FROM #{from.table} AS f"
    "LEFT JOIN #{oid.table} AS o"
    "ON o.#{oid.colType}='#{from.type}'"
    "AND o.#{oid.colId}=f.#{from.colId}"
    "WHERE o.#{oid.colOid} IS NULL"
  ].join(' ') + ';'

  sql

#
# Get SQL Query For Insert Of ObjectIDs
#
# @param oid - 
# @param insert - 
#
# @return {String} sql query
#
_getSqlQueryForInsertOID = (oid, insert) ->
  sql = [
    "INSERT INTO #{oid.table} (#{oid.colType}, #{oid.colId}, #{oid.colOid})"
    "VALUES (#{insert.join('),(')})"
  ].join ' '

  sql

#
# Insert ObjectIDs for specific table
#
# @param client - 
# @param insert - 
# @param oid - 
# @param cb - 
#
insertOidsForTable = (client, insert, oid, cb) ->
  return cb null, 0 if insert.length is 0

  sql = _getSqlQueryForInsertOID oid, insert

  client.query sql, (err, result) ->
    console.error err if err
    cb null, insert.length

#
# Insert Missing ObjectIDs for all rows in all tables
#
# @param client -
# @param from -
# @param oid - 
# @param cb -
# @parma i - 
#
insertOIDsForTables = (client, from, oid, cb, i) ->
  i = i or 0
  
  if i is from.length
    cb null, i if typeof cb is 'function'
    return

  insert = []
  count = 0
  query = client.query _getSqlQueryForRowsWithoutOID from[i], oid

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
      console.log "#{count} OIDs inserted for table #{from[i].table}" if rowCount > 0
      insertOIDsForTables client, from, oid, cb, ++i

module.exports =
  insertOIDsForTables: insertOIDsForTables
  insertOidsForTable: insertOidsForTable

