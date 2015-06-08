Capture all the repositories for a user.

    request = require 'request'

    module.exports = (options, callback) ->
      if options.username and options.password
        args =
          url: "https://#{options.username}:#{options.password}@api.github.com/users/#{options['<user>']}/repos?type=all&per_page=100&page=#{options.page}"
          headers:
            'User-Agent': 'git-friends cli'
      else
        args =
          url: "https://api.github.com/users/#{options['<user>']}/repos?type=all&per_page=100&page=#{options.page}"
          headers:
            'User-Agent': 'git-friends cli'
      request args, (err, response, body) ->
        options.repositories = JSON.parse(body)
        callback undefined, options
