Capture all the repositories for an organization. Unfortunately, this
is a different call than capturing everything for a *user*.

    request = require 'request'

    module.exports = (waterfall, options) ->
      waterfall.push (options, callback) ->
          args =
            url: "https://api.github.com/orgs/#{options['<organization>']}/repos?per_page=500"
            headers:
              'User-Agent': 'git-friends cli'
          if options.username and options.password
            args.input =
              user: options.username
              pass: options.password
              sendImmediately: false
          request args, callback
      waterfall.push (response, body, callback) ->
        options.repositories = JSON.parse(body)
        callback undefined, options
