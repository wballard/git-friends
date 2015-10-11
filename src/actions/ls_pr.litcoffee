List all the PRs for a repo, and deal with pagination.

    request = require 'request'
    Promise = require 'bluebird'

    module.exports = fetchPRs = (options, repo) ->
      new Promise (resolve, reject) ->
        target = options['<owner>']
        repo.page = repo.page or 1
        args =
          url: "#{options.apiUrl}/repos/#{target}/#{repo.name}/pulls?per_page=100&page=#{repo.page}"
          headers:
            'User-Agent': 'git-friends cli'
        request args, (err, response, body) ->
          if response.headers['x-ratelimit-remaining'] is '0'
            console.error "Whoops -- hit the rate limit".red
            console.error response.headers
            process.exit 1

          new_prs = JSON.parse body

          new_prs.forEach (pr) ->
            console.log "#{repo.name.blue} <#{pr.user.login.green}>"
            console.log "  #{pr.title}"
            console.log "  #{pr.url}"
            console.log ""
            
          if new_prs.length is 100
            repo.page += 1
            fetchPRs options, repo
          else
            resolve repo
