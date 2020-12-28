fs = require 'fs-plus'
path = require 'path'
cache = require './cache'

exports.removeMinidump = (dumpFilePath, callback) ->
  # Remove from cache
  cache.remove record.id

  # Remove from disc
  fs.unlink dumpFilePath, (err) ->
    callback err
