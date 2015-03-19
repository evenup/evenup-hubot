What is it?
===========

A puppet module that installs and manages a [hubot](http://hubot.github.com) bot.

There are two methods of configuring hubot, setting the available parameters (useful for trying it out/simple configs) and storing your config and scripts in git.  Instructions below as well on migrating from parameter config to repo configuration.

Configuring via puppet
----------------------

This method is great for giving hubot a try to figure out what it's all about and maintaining a simple configuration.  If you want to be able to run hubot with only the shell adapter, no configuration is required other than including this class and then running /opt/hubot/hubot/bin/hubot (that's a lot of hubots) and interact with him on the shell.

To move hubot to something a bit more useful you will want to configure an adapter for it to connect to some form of chat.  This will require setting the `adapter` parameter and will likely require you to also set some environment variables via the `env_export` parameter.  You may also need to add some npm dependencies for your adapter via the `dependencies` parameter.

At this point you should be on your way!

Custom scripts can be installed via the hubot::script definition as well.

Simple config with the hipchat adapter:

    class { 'hubot':
      adapter       => 'hipchat',
      build_deps    => [ 'libxml2-devel', 'gcc-c++' ],
      env_export    => { 'HUBOT_LOG_LEVEL'        => 'DEBUG',
                         'HUBOT_HIPCHAT_ROOMS'    => 'xmpp_room1@conf.hipchat.com,xmpp_room2@conf.hipchat.com',
                         'HUBOT_HIPCHAT_JID'      => 'hubot_jid@chat.hipchat.com',
                         'HUBOT_HIPCHAT_PASSWORD' => 'hubot_pass'
                        },
      dependencies  => { "hubot" => ">= 2.6.0 < 3.0.0", "hubot-scripts" => ">= 2.5.0 < 3.0.0", "hubot-hipchat" => "~2.5.1-5" },
    }


Configuring via git
-------------------

This method is more customizable since you can configure hubot by editing the actual configuration files.  When using this method a few additional dependencies are required, a class git which needs to ensure the git binary is available and puppetlabs/vcsrepo.  Both dependencies (as tested) are documented in the Modulefile, but commented out as they are optional.  The git dependency should be very flexible, the vcsrepo dependency likely is harder to replace with another module.

To configure hubot from a git repo, simply set the `git_source` parameter.  If your git repo is accessible via SSH you may also need to set the `ssh_privateykey` or `ssh_privatekey_file` to configure the id_rsa file for the hubot user.  By default the `auto_accept_host_key` parameter is set to true which will disable `StrictHostKeyChecking` for the hubot user - this may not be ideal in your environment.  If disabled and syncing via SSH, you will need to ensure the git host key is trusted by some other means.

Getting up and running:

    class { 'hubot':
      git_source          => 'git@git.mycompany.com:hubot',
      ssh_privatekey_file => 'puppet:///data/ssh/hubot_id_rsa',
     }

Build dependencies
------------------

Frequently NPM modules require additional packages in order to compile the module.  In this case you can include any additional dependencies with the `build_deps` parameter.


Migrating from parameters to git
--------------------------------

This assumes basic knowledge of git and an understanding of why you are doing this.  All paths are based on the module defaults.

    puppet agent --disable
    cd /opt/hubot/hubot
    git init
    git add .
    git remote add origin <git_source>
    git push origin master
    --- Update your puppet config to specify this new git_source and any SSH parameters needed
    puppet agent --enable

Puppet will now keep hubot up to date based on this git repo and restart the service whenever it is updated.


Known Issues:
-------------
Only tested on CentOS 6, but should be pretty agnostic.  Feedback/PRs appreciated!


License:
--------

Released under the Apache 2.0 licence


Contribute:
-----------
* Fork it
* Create a topic branch
* Improve/fix (with spec tests)
* Push new topic branch
* Submit a PR
