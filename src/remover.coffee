fs = require 'fs-plus'
path = require 'path'
cache = require './cache'

exports.removeMinidump = (record, callback) ->
  # Remove from cache
  cache.remove record.id

  # Remove from disc
  fs.unlink record.path, (err) ->
    callback err
