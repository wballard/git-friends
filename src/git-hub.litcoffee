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

    async = require 'async'
    fs = require 'fs'
    path = require 'path'
    mkdirp = require 'mkdirp'
    require 'colors'
    {docopt} = require 'docopt'
    {exec} = require 'child_process'
    options = docopt doc
    options['<directory>'] = path.normalize(options['<directory>'] or process.cwd())



    waterfall = []

The waterfall is a pipeline with the options object as the context end to
end.

    waterfall.push (callback) ->
      callback undefined, options

    require('./pipelines/authentication.litcoffee') waterfall, options
    if options.organization
      require('./pipelines/organization_repositories.litcoffee') waterfall, options
    if options.user
      require('./pipelines/user_repositories.litcoffee') waterfall, options


Now, with repo list in hand, push a bunch of tasks to clone.

    waterfall.push (options, callback) ->
      repo_waterfall = []
      repo_waterfall.push (callback) ->
        mkdirp options['<directory>'], callback
      repo_waterfall.push (dir, callback) ->
        callback()
      options.repositories.forEach (repo) ->
        repo_waterfall.push (callback) ->
          console.error repo.name.blue
          repo_in_dir = path.join(options['<directory>'], repo.name)
          if fs.existsSync repo_in_dir
            exec "git --work-tree=#{repo_in_dir} --git-dir=#{repo_in_dir}/.git pull --all", callback
          else
            exec "git clone --recursive #{repo.ssh_url} #{repo_in_dir}", callback
        repo_waterfall.push (stdout, stderr, callback) ->
          process.stdout.write stdout
          process.stderr.write stderr
          callback()
      async.waterfall repo_waterfall, callback

    async.waterfall waterfall
