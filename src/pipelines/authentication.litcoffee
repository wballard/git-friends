Stages of a waterfall pipeline to get login information.

    prompt = require 'prompt'
    require 'colors'

    prompt.start()
    prompt.message = ''
    prompt.delimiter = ''


    module.exports = (waterfall, options) ->
      waterfall.push (options, callback) ->
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
          prompt.get schema, callback
        else
          callback undefined, {}

      waterfall.push (input, callback) ->
        options.username = input.username
        options.password = input.password
        callback undefined, options
