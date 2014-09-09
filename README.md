
# dSync

Synchronise easily your local git repository between all your devices.

> **NOTE:**
> 
> - This Makefile was build and use on Debian shell.
> - Don't forget to configure variable on top of the file.
> - Hidden file `.dsynctime` was create into directory destination
> - Pull / Push command use file `.dsynctime` for no erase local file.

#### <i class="icon-pencil"></i> Variables need to be configured
```
sshUser         := user
sshKey          := /home/user/.ssh/id_dsa
sshRemote       := domain.tld
PathRemoteBase  := /where/you/want
```
----------

## How to use

#### <i class="icon-download"></i> Clone
Clone permit to clone repository and create file `.dsynctime` at same time. 
*The following command will be create persistent folder `/github/pierozi/dsync`*
```
make clone/github/pierozi/dsync repo=https://github.com/Pierozi/dsync.git 
```
----------

#### <i class="icon-upload"></i> Push
Push permit to rsync local directory to remote server. 
```
make push/github/pierozi/dsync
```
----------

#### <i class="icon-refresh"></i> Pull
Pull permit to rsync remote directory to local. 
```
make pull/github/pierozi/dsync
```
----------

#### <i class="icon-info"></i> Ignore path or file with .dsyncignore
Make a file into your root project sync and touch file named `.dsyncignore`
the syntax are similar to an `.gitignore`
it's useful for ignore some heavy files you don't want push to your server...

*this example build an dsyncignore file for ignore Packer & Vagrant resources*
```
echo -e "*.box\n*-vbox\n.vagrant\npacker_cache" > namespace/myProject/.dsyncignore
make push/namespace/myProject
```
----------
