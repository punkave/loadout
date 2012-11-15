# The P'unk Avenue Loadout

## Set up your Mac to develop the [P'unk Avenue](http://punkave.com) way

Here at P'unk Avenue, we develop web applications with modern frameworks like [Express](http://expressjs.com/) for [node.js](http://nodejs.org/) and [Symfony](http://symfony.com) for [PHP](http://php.net). Those frameworks demand a complete set of tools, including many optional components that are missing from a plain vanilla Mac.

Over time, we've developed a process for setting up new Macs so that our developers can be as productive as possible. And recently we've open-sourced our process so that others can benefit. 

Our office is full of gamers who never leave a spawn point without a triple armload of in-game weaponry, so we've affectionately named our process "the P'unk Avenue Loadout," or "the Loadout" for short.

## What you get with the Loadout

Here's a partial list of what you get:

* [PHP](http://php.net) with all the trimmings (LDAP, LibXML, Mongo, APC, GD and more)
* [node.js](http://nodejs.org)
* [npm](http://npmjs.org)
* [MySQL](http://mysql.com)
* [MongoDB](http://mongodb.org)
* [Redis](http://redis.io)
* [NetPBM](http://netpbm.sourceforge.net/)
* [Apache](http://httpd.apache.org/), configured to host many dev sites painlessly

Even more important, everything is installed via [MacPorts](http://www.macports.org/), so that you can update your packages at any time and install more optional components as needed. You're not locked into a MAMP-like set of precompiled binaries that leave you in the lurch if they are missing one critical feature. 

In a nutshell, you get the same flexibility on your Mac that you have on the Linux servers you are very probably deploying your web apps to.

## Loadout 101: How to set up your Mac for development

Yes, I know you're excited to run that `loadout.bash` script. But we're not quite ready yet. First you need to install the prerequisites and adjust your configuration a little bit. Then we move on to `loadout.bash`:

1\. **Shut off MAMP, XAMPP, Web Sharing,** and any other optional packages you have already set up that would conflict with what we're trying to do. You shouldn't have two copies of Apache listening on port 80 or two copies of MySQL Server, for instance.

2\. **Install [XCode](http://developer.apple.com/xcode)**. If you think you already have XCode but have trouble with the steps that follow, you probably have a half-assed XCode install; just install the latest XCode.

XCode is free from Apple. You can install XCode from the Mac App store (for Lion) or the Apple developer site (Snow Leopard).

3\. **Install the XCode command line tools.** Once XCode is downloaded and installed, launch the XCode application and go to Preferences. Select "downloads" and download the "Command line tools" from "components."

4\. **Configure the XCode command line tools.** Once the command line tools are installed, run this command in the terminal to make sure the command line tools are pointing at the right XCode directory. This may not be necessary with every version of XCode, but it doesn't hurt:

    sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer

5\. **Install [MacPorts](http://www.macports.org/).** MacPorts provides pretty much every open source software package you would find on a Linux system and allows you to selectively compile those you want. 

6\. **Adjust your PATH environment variable.** Put `/opt/local/bin`, `/opt/local/sbin`, and `/opt/local/apache2/bin` early in your PATH so they beat the generic Mac versions of things. This is very important.

You can do that by editing the `.profile` file in your home directory (note the leading dot!) to read as follows (it's OK to add this line last if you already have a `.profile`):

    export PATH=/opt/local/bin:/opt/local/sbin:/opt/local/apache2/bin:$PATH

(MacPorts may do part of this for you, but it will probably skip `/opt/local/apache2/bin`, which is important.)

If you use sublimetext, an easy way to edit or create this file is to use the `subl` command at the terminal prompt:

    cd ~
    subl .profile

Now **close your terminal window and open a new one**. Otherwise you still won't have the right PATH for the commands that follow.

7\. **When you have plenty of time to wait, run loadout.bash**. Here's how to do it at the terminal prompt. You will be prompted for your computer's administrator password:

    git clone https://github.com/punkave/loadout.git
    cd loadout
    sudo bash loadout.bash

Don't do this on a bad Internet connection, and make sure your Mac is plugged in. It'll take a long while due to the need to compile software from source. You may be prompted once or twice; you can accept the defaults for any question.

8\. **Verify success.** Open a **NEW** terminal window. Then try this command:

    which php

Which should output:

    /opt/local/bin/php

9\. **Configure Apache.** Edit your `/opt/local/apache2/conf/httpd.conf` file and add the following at the end, replacing YOURUSERNAME with your own username on this Mac:

    <VirtualHost *:80>
    NameVirtualHost *:80
    VirtualDocumentRoot /Users/YOURUSERNAME/Sites/%1/web
    </VirtualHost>

This configures Apache to automatically offer any subdirectories of your "Sites" folder as websites, without the need to configure them individually. Only the first part of the domain name is considered, which is handy if you have a DNS server in your office that allows you to easily assign a domain name to each of your coworkers' machines.

If you aren't sure what your username is, use this command to find out:

    whoami

Next, look for the `User` setting in `httpd.conf` and change that username from `apache` to your username as well. The setting should look like this:

    User YOURUSERNAME

This ensures that Apache (and PHP) run with the same permissions as your personal account. This is recommended for development purposes to avoid permissions hassles when you want to modify files that have been touched by the website. (On production Linux servers we also configure Apache to run as the same user we run command line tasks with, because they share the same set of concerns and the server is usually a VPS or dedicated server whose only job is to run a particular website.)

Finally, locate the `<Directory />` block and adjust it to be more generous with permissions so that we can test dynamic PHP-powered websites that use rewrite rules and the like, such as typical Symfony projects:

    <Directory />
        # PHP is the preferred index for a folder
        DirectoryIndex index.php index.html
        # Necessary for mod_rewrite to work
        Options FollowSymLinks
        # Generous permissions for .htaccess
        AllowOverride All
        Order allow,deny
        Allow from all
        # Necessary for VirtualDocumentRoot to work
        UseCanonicalName off
    </Directory>

10\. **Configure PHP**. Copy the provided `php.ini` file to `/opt/local/etc/php5/php.ini` or read it over and consider our choices. Make sure you edit the `date.timezone` setting.

11\. **Restart Apache**.

    sudo apachectl restart

## Developing with Loadout

You followed the Loadout process. Great. Now what?

For starters, you can create as many websites as you wish in the `Sites` subdirectory of your home directory. Let's make a test site with a PHP-powered homepage:

    mkdir -p Sites
    cd Sites
    mkdir testsite
    cd testsite
    mkdir web
    cd web
    echo "Hi there." > index.php

Now edit your `/etc/hosts` file, adding a new line at the end like this:

    127.0.0.1 testsite

Finally, visit `testsite` with your web browser:

    http://testsite/

Notice that **we didn't have to edit our Apache configuration to add a site.** That's because our standard Apache configuration automatically lights up all subdirectories of `Sites` as new websites. All we have to do is tell the computer that the name `testsite` points to itself via the magic IP address `127.0.0.1`.

"Why do I have to put my files in a `web` subdirectory?" Because most modern frameworks expect that most of their code will not be in the "document root" where Apache can see it. Instead there is typically a subdirectory where the web-accessible files go. If that's greek to you, just remember to put your webpages and other assets in `web`.

## Working with MySQL

MySQL is all set up as well. You can connect to it at `localhost` with the username `root` and the password `root`. 

## Working with MongoDB

MongoDB is up and running and accepting connections from your own computer. And PHP is compiled with full support for talking to it. Try the `mongo` command line utility.

## Working with node.js

The `node` command is available. Also the `npm` command for installing packages in your node projects. Since Apache is listening on port 80, you'll want to listen on an alternate port for development purposes.

If you need to deploy node apps to VPSes or dedicated servers, consider using [Stagecoach](http://github.com/punkave/stagecoach). [Heroku](http://heroku.com) is also a popular choice for Node app deployment.

## Future directions for the Loadout

Right now the P'unk Avenue Loadout still requires a fair number of manual steps. We look forward to automating more of them. And of course we look forward to your pull requests as well.

## Contact

The Loadout was developed at [P'unk Avenue](http://punkave.com), a design-and-build web firm in South Philly. `tom@punkave.com` is a good point of contact. Better yet, [open issues on github](http://github.com/punkave/loadout). Better-better yet, submit pull requests.
