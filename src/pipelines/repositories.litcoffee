Capture all the repositories for an organization. Unfortunately, this
is a different call than capturing everything for a *user*.

This iterates per page up to the 100 limit -- get *all* the repos by going page
to page until there is nothing left.

    request = require 'request'

    module.exports = fetchRepositories = (options, callback) ->
      if options.organization
        part = 'orgs'
      else
        part = 'users'
      target = options['<owner>']
      options.page = options.page or 1
      if options.username and options.password
        args =
          url: "https://#{options.username}:#{options.password}@api.github.com/#{part}/#{target}/repos?type=all&per_page=100&page=#{options.page}"
          headers:
            'User-Agent': 'git-friends cli'
      else
        args =
          url: "https://api.github.com/#{part}/#{target}/repos?type=all&per_page=100&page=#{options.page}"
          headers:
            'User-Agent': 'git-friends cli'
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
          for repo in new_repos
            options.repositories.push repo
          options.page += 1
          fetchRepositories options, callback
        else
          callback undefined, options
