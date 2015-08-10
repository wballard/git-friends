List all the PRs for a repo, and deal with pagination.

    request = require 'request'
    Promise = require 'bluebird'

    module.exports = fetchPRs = (options, repo) ->
      new Promise (resolve, reject) ->
        target = options['<owner>']
        repo.page = repo.page or 1
        if options.username and options.password
          args =
            url: "https://#{options.username}:#{options.password}@api.github.com/repos/#{target}/#{repo.name}/pulls?per_page=100&page=#{repo.page}"
            headers:
              'User-Agent': 'git-friends cli'
        else
          args =
            url: "https://api.github.com/repos/#{target}/#{repo.name}/pulls?per_page=100&page=#{repo.page}"
            headers:
              'User-Agent': 'git-friends cli'
        request args, (err, response, body) ->
          if response.headers['x-ratelimit-remaining'] is '0'
            console.error "Whoops -- hit the rate limit".red
            console.error response.headers
            process.exit 1

          new_prs = JSON.parse body

          if new_prs.length
            new_prs.forEach (pr) ->
              console.log "#{repo.name.blue} <#{pr.user.login.green}>"
              console.log "\t#{pr.title}"
              console.log "\t#{pr.url}"
            repo.page += 1
            fetchPRs options, repo
          else
            resolve repo
