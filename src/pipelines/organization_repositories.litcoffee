Capture all the repositories for an organization. Unfortunately, this
is a different call than capturing everything for a *user*.

This iterates per page up to the 100 limit -- get *all* the repos by going page
to page until there is nothing left.

    request = require 'request'

    module.exports = fetchRepositories = (options, callback) ->
      options.page = options.page or 1
      args =
        url: "https://api.github.com/orgs/#{options['<organization>']}/repos?per_page=100&page=#{options.page}"
        headers:
          'User-Agent': 'git-friends cli'
      if options.username and options.password
        args.input =
          user: options.username
          pass: options.password
          sendImmediately: false
      request args, (err, response, body) ->
        if response.headers['x-ratelimit-remaining'] is '0'
          console.error "Whoops -- hit the rate limit".red
          console.error response.headers
          process.exit 1

        if not options.repositories
          options.repositories = []

        new_repos = JSON.parse body

If we got any repos -- assume a next page and move on, but when no more come
then we are finished.

        if new_repos.length
          console.log "#{new_repos.length} repositories found on page #{options.page}".blue
          for repo in new_repos
            options.repositories.push repo
          options.page += 1
          fetchRepositories options, callback
        else
          console.log response.headers
          callback undefined, options
