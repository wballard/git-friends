List all the issues for a repo, and deal with pagination.

    request = require 'request'
    Promise = require 'bluebird'
    size = require 'window-size'
    wrap = require 'word-wrap'

    module.exports = fetchIssues = (options, repo) ->
      new Promise (resolve, reject) ->
        target = options['<owner>']
        repo.page = repo.page or 1
        args =
          url: "#{options.apiUrl}/repos/#{target}/#{repo.name}/issues?per_page=100&page=#{repo.page}"
          headers:
            'User-Agent': 'git-friends cli'
        request args, (err, response, body) ->
          if response.headers['x-ratelimit-remaining'] is '0'
            console.error "Whoops -- hit the rate limit".red
            console.error response.headers
            process.exit 1

          issues = JSON.parse body

          issues.forEach (issue) ->
            console.log "#{repo.name.blue} <#{issue.user.login.green}>"
            console.log "  #{issue.title}"
            console.log "  #{issue.url}"
            console.log wrap "#{issue.body}", {indent: '  ', width: size.width-2 }
            console.log ""
            
          if issues.length is 100
            repo.page += 1
            fetchIssues options, repo
          else
            resolve repo
