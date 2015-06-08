Command line to interact with GitHub. This uses the github API
and as such will need to prompt you for username and password.

    doc = """
    Usage:
      git-hub [options] pull organization <organization> [<directory>]
      git-hub [options] pull user <user> [<directory>]

    Options:
      -h --help                show this help message and exit
      --version                show version and exit
      --anonymous              no username and password given, be the proles

    Working with GitHub, with a lot of repositories can be a bunch of hunting
    around. These commands give you a quick way to push and pull a bunch
    of related repositories.

      pull       This will clone or pull as needed to get you all caught up
    """

    Promise = require 'bluebird'
    fs = require 'fs'
    path = require 'path'
    mkdirp = require 'mkdirp'
    require 'colors'
    {docopt} = require 'docopt'
    {exec} = require 'child_process'
    options = docopt doc
    options['<directory>'] = path.normalize(options['<directory>'] or process.cwd())

    authentication = Promise.promisify require './pipelines/authentication.litcoffee'
    action = Promise.promisify require './pipelines/repositories.litcoffee'
    mkdirp = Promise.promisify mkdirp

    mkdirp(options['<directory>'])
      .then -> options
      .then(authentication)
      .then(action)
      .then ->
        console.log "#{options.repositories.length} repositories found".green
        options.repositories
      .each (repo) ->
        repo_in_dir = path.resolve(path.join(options['<directory>'], repo.name))
        console.error repo.name.blue, "in", repo_in_dir.blue
        if fs.existsSync repo_in_dir
          fetcher = Promise.promisify (callback) ->
            exec "git --work-tree=#{repo_in_dir} --git-dir=#{repo_in_dir}/.git pull --all", (err, stdout, stderr) ->
              process.stdout.write stdout
              process.stderr.write stderr
              callback()
        else
          fetcher = Promise.promisify (callback) ->
            exec "git clone --recursive #{repo.ssh_url} #{repo_in_dir}", (err, stdout, stderr) ->
              process.stdout.write stdout
              process.stderr.write stderr
              callback()
        fetcher()
