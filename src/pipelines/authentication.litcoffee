Stages of a pipeline to get login information.

    prompt = require 'prompt'
    require 'colors'


    module.exports = (options, callback) ->
      prompt.start()
      prompt.message = ''
      prompt.delimiter = ''
      if process.env.GITHUB_USER && process.env.GITHUB_PASSWORD
        options.username = process.env.GITHUB_USER
        options.password = process.env.GITHUB_PASSWORD
        options.apiUrl = "https://#{options.username}:#{options.password}@api.github.com"
        return callback undefined, options

      if not options['--anonymous']
        schema = properties:
          username:
            message: 'Your GitHub username'.magenta + ':'.bold
            default: process.env.USER
            required: true
          password:
            message: 'Your GitHub password or token'.magenta + ':'.bold
            default: process.env.PASSWORD
            required: true
            hidden: true
        prompt.get schema, (err, input) ->
          options.username = input.username
          options.password = input.password
          options.apiUrl = "https://#{options.username}:#{options.password}@api.github.com"
          callback undefined, options
      else
        callback undefined, options
