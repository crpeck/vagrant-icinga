# vagrant-bare

A bare vagrant machine set up to be provisioned with puppet.

## Use

Edit puppet/manifests/site.pp to describe the system state that you want after running `vagrant up`.

Modules are expected to be kept in puppet/modules, which is customarily managed by [librarian-puppet](https://github.com/rodjek/librarian-puppet).

### pre-puppet.sh
This is a shell script that runs BEFORE puppet provision runs, by default it installs librarian-puppet in the VM and runs it.
It will only run once per 'vagrant up'

### post-puppet.sh
This is a shell script that runs AFTER puppet provision runs, by default it does nothing.
It will only run once per 'vagrant up'

### librarian-puppet

Edit the file `puppet/Puppetfile` to list modules that you need available to your manifest file.
The modules can be pulled from the puppet forge, or from git repositories.

### Custom/local modules

librarian-puppet won't interfere with any modules that you manually add to the modules directory,
but will overwrite any changes you've made to managed modules.  librarian-puppet only does things
when manually called.
