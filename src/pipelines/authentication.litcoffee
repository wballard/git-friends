Stages of a pipeline to get login information.

    prompt = require 'prompt'
    require 'colors'


    module.exports = (options, callback) ->
      prompt.start()
      prompt.message = ''
      prompt.delimiter = ''
      if not options['--anonymous']
        schema = properties:
          username:
            message: 'Your GitHub username'.magenta + ':'.bold
            default: process.env.USER
            required: true
          password:
            message: 'Your GitHub password'.magenta + ':'.bold
            required: true
            hidden: true
        prompt.get schema, (err, input) ->
          options.username = input.username
          options.password = input.password
          callback undefined, options
      else
        callback undefined, options
