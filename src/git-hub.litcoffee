Command line to interact with GitHub. This uses the github API
and as such will need to prompt you for username and password.

    doc = """
    Usage:
      git-hub [options] pull organization <organization> [<directory>]

    Options:
      -h --help                show this help message and exit
      --version                show version and exit
      --anonymous              no username and password given, be the proles

    Working with GitHub, with a lot of repositories can be a bunch of hunting
    around. These commands give you a quick way to push and pull a bunch
    of related repositories.

    The basic idea is that each <organization_or_user> is together in a
    directory.

      pull       This will clone or pull as needed to get you all caught up
    """

    async = require 'async'
    fs = require 'fs'
    path = require 'path'
    request = require 'request'
    prompt = require 'prompt'
    mkdirp = require 'mkdirp'
    require 'colors'
    {docopt} = require 'docopt'
    {exec} = require 'child_process'
    options = docopt doc
    options['<directory>'] = path.normalize(options['<directory>'] or process.cwd())

    prompt.start()
    prompt.message = ''
    prompt.delimiter = ''


    waterfall = []
    if not options['--anonymous']
      waterfall.push(
        (callback) ->
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
      )
    else
      waterfall.push(
        (callback) -> callback undefined, undefined
      )
    waterfall.push(
      (input, callback) ->
        args =
          url: "https://api.github.com/orgs/#{options['<organization>']}/repos?per_page=500"
          headers:
            'User-Agent': 'git-friends cli'
        if input
          args.input =
            user: input.username
            pass: input.password
            sendImmediately: false
        request args, callback
    )

Now, with repo list in hand, push a bunch of tasks to clone.

    waterfall.push(
      (response, body, callback) ->
        repo_waterfall = []
        repo_waterfall.push(
          (callback) ->
            mkdirp options['<directory>'], callback
        )
        repo_waterfall.push(
          (dir, callback) -> callback()
        )
        JSON.parse(body).forEach (repo) ->
          repo_waterfall.push(
            (callback) ->
              console.log repo.name.blue
              repo_in_dir = path.join(options['<directory>'], repo.name)
              if fs.existsSync repo_in_dir
                exec "git --work-tree=#{repo_in_dir} --git-dir=#{repo_in_dir}/.git fetch --all", callback
              else
                exec "git clone --recursive #{repo.ssh_url} #{repo_in_dir}", callback
          )
          repo_waterfall.push(
            (stdout, stderr, callback) ->
              process.stdout.write stdout
              process.stderr.write stderr
              callback()
          )
        async.waterfall repo_waterfall, callback
    )

    async.waterfall waterfall
