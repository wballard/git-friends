For a repository, pull it or clone it by shelling.

    Promise = require 'bluebird'
    fs = require 'fs'
    path = require 'path'
    mkdirp = require 'mkdirp'
    {exec} = require 'child_process'

    module.exports = (options, repo) ->
      new Promise (resolve, reject) ->
        repo_in_dir = path.resolve(path.join(options['<directory>'], repo.name))
        fs.exists repo_in_dir, (exists) ->
          if exists
            console.log "#{'updating'.magenta} #{repo.name.blue} in #{repo_in_dir.blue}"
            action = "git --work-tree=#{repo_in_dir} --git-dir=#{repo_in_dir}/.git fetch --all"
          else
            console.log "#{'cloning'.magenta} #{repo.name.blue} in #{repo_in_dir.blue}"
            if options['--anonymous']
              action = "git clone --recursive #{repo.clone_url} #{repo_in_dir}"
            else
              action = "git clone --recursive #{repo.ssh_url} #{repo_in_dir}"
          resolve action
      .then (action) ->
        new Promise (resolve, reject) ->
          exec action, (err, stdout, stderr) ->
            if err
              reject err
            else
              process.stdout.write stdout
              process.stderr.write stderr
              resolve repo
