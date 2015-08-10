Command line to interact with GitHub. This uses the github API
and as such will need to prompt you for username and password.

    doc = """
    Usage:
      git-hub [options] pull organization <owner> [<directory>]
      git-hub [options] pull user <owner> [<directory>]
      git-hub [options] ls pr organization <owner> [<directory>]
      git-hub [options] ls pr user <owner> [<directory>]

    Options:
      -h --help                show this help message and exit
      --version                show version and exit
      --anonymous              no username and password given, be the proles

    Working with GitHub, with a lot of repositories can be a bunch of hunting
    around. These commands give you a quick way to push and pull a bunch
    of related repositories.

      pull       This will clone or pull as needed to get you all caught up
      ls pr      See all the open pull requests.
    """

    Promise = require 'bluebird'
    fs = require 'fs'
    path = require 'path'
    mkdirp = require 'mkdirp'
    require 'colors'
    {docopt} = require 'docopt'

    options = docopt doc
    options['<directory>'] = path.normalize(options['<directory>'] or process.cwd())

    authentication = Promise.promisify require './pipelines/authentication.litcoffee'
    repositories = Promise.promisify require './pipelines/repositories.litcoffee'
    mkdirp = Promise.promisify mkdirp

    mkdirp(options['<directory>'])
      .then -> options
      .then(authentication)
      .then(repositories)
      .then ->
        console.log "#{options.repositories.length} repositories found".blue
        options.repositories
      .each (repo) ->
        if options.pull
          return require('./actions/pull_or_clone.litcoffee') options, repo
        if options.ls and options.pr
          return require('./actions/ls_pr.litcoffee') options, repo
