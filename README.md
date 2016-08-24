# Vagrant PHP Development box

This project implements vagrant box with PHP development environment. The more specific intent was Symfony development environment, but it can be used for other PHP projects as well. Additionaly, some extra services were added (MySQL, Redis, MongoDB, ElasticSearch, RabbitMQ, SMTP...)

## Vagrant

### Shared folders

By default, there are 3 shared folders configured in vagrant

| Host folder | Guest folder            | Share type  | Read only | Intent                                           |
|------------:|:------------------------|-------------|-----------|--------------------------------------------------|
| ./ansible   | /ansible                | Virtual box | Yes       | Ansible files                                    |
| ./assets    | /project_assets         | Virtual box | No        | Project assets that do not belong to source code |
| ./source    | /opt/dev-project/source | Samba / NFS | No        | Project source code                              |

### Notice on Samba / NFS share

Source folder is linked via Samba (on Windows) and NFS (on Mac / Linux) systems. Please make sure you have everything installed / configured on your system to enable these to run.

## Ansible

Ansible is being used to setup the system. There is however no need for your host to have Ansible installed. Scripts will install Ansible in the virutal box, and Ansible will run from there.

### About Playbook files

Currently, there are two playbooks implemented for ansible
- **playbook-always** that runs each time virtual machine is started
- **playbook-once** that runs only first-time virtual machine is started

### Configuring playbooks

If you want to configure a playbook, copy files you want to alter to either **assets** or **source** folder. No need to alter original files.

#### Ansible packages

Ansible packages included in this are in format of **{category}/{package}/{type}**, where type is one of the following:
- *package* - Contains actual installation actions for the package (but do not include this in your playbook)
- *install* - Includes *package* type. This way, if *package* is included multiple times, it gets executed only once, saving time
- *action* - Includes *install* and contains tasks to help automate some processes. These tasks will be documented in each file
- *setup* - Includes *action* and runs some of the tasks from *action* in the playbook. Most of these can be configured trough playbook variables

For use within playbook, only include *install* or *setup* package types.

#### Configuration variable files

Playbooks rely on a variable configuration files as well. Order of loading this files is as follows

| File                      | Order   |
|---------------------------|---------|
| php-config.yml            | Level 1 |
| sql-config.yml            | Level 1 |
| message-queue-config.yml  | Level 1 |
| project-config.yml        | Level 1 |
| default-playbook-vars.yml | Level 2 |
| {playbook-name}-vars.yml  | Level 3 |

Files marked as same order level should be treated as loaded in undecided order. Higher level, the later the file gets loaded, and overrides anything previously loaded.

*Note:* Templated variables get parsed at time of use, so you can define something like var1 being "{{ var2 }}-x" and then var2 as "y", and one more var2 as "a", and when var1 gets parsed for use it will resolve into "a-x".

While these configuration files are located in *ansible/dist* folder, they will get searched in other folders, and latest copy found will be used.

Folders being searched for configuraiton files are:

| Folder         | Folder description                          |
|---------------:|:--------------------------------------------|
| ./ansible/dist | Ansible distribution (default) config files |
| ./assets       | Project assets                              |
| ./source       | Project source files                        |

##### {playbook-name}.yml

Modify this file to include or exclude packages you want to install. Comment out, uncomment, or switch from *setup* to *install* if needed. Not all packages have *setup* implemented, so switching from *install* to *setup* type is not recommended

##### default-playbook-vars.yml

Modify this file to change most of the configuration for setup tasks. By default, most of the options are already present, even if just commented out. For extra detail on options, you will have to do some backtracking trough packages.

##### {playbook-name}-vars.yml

Variables here will be loaded with specified playbook, and will override any previously set in default-playbook-vars.yml

##### Other configuration files

Other configuration files are also added to reduce amout of config options per file, and make it easier to manage.

## Packages

### Projects

There are currently 3 project packages. Just by them selfs, they will prepare the virutal machine for development. No additional packages need to be included in playbook file for basic setup of desired project type.

| Project package            |  Type     | Extends project package   | Description                                    |
|:--------------------------:|:---------:|:-------------------------:|------------------------------------------------|
| project/base/setup         | Basic     |                           | Sets up basic directory structure for projects |
| project/nginx_php/install  | Nginx PHP | project/base/setup        | Sets up Nginx and PHP (root in source/web)     |
| project/composer/setup     | Composer  | project/nginx_php/install | Configures Nginx and PHP and install Composer  |
| project/symfony/setup      | Symfony   | project/composer/setup    | Configures Nginx and PHP for Symfony           |

### Php packages

Php packages are in form of "**package/php-{name}/install**" or "**package/php-{name}/setup**". Packages that have *setup* in the name have configuration options in playbook. They are either state options (enabled/disabled), and configuration options.

For PHP interpreters (CLI, FPM, CGI), these options will configure their respective php.ini files.

For PHP modules, these options will configure {module_name}.ini file, and all options will be prefixed by module name. So for example to edit *xdebug* option called *xdebug.cli_color* specify option *cli_color*.

Options are specified as a list of dictionaries (python talk), with "option" and "value" dictionary keys. Omitting "value" key will delete the value from the ini. Note that this, in turn, does not remove the configuration, but actually sets it to a default value.

By default, for all module packages with setup there are entries in playbook-default-vars for all config options that were available at the moment of creating this project. Options have their default values set, but also commented out. This will, in turn, remove these settings from ini files, and PHP will be parsing them with their default values.

At the end, all enabled modules are once more processed (or their ini files) writing ALL options and their settings to ini files (so unset values are going to be written with their default values).

Since by default all PHP packages are included, but it is recommended that you turn off those that you don't need. If there are any other packages you leave to be installed, that need these modules, packages will install them their self, so no need to worry (for example composer, symfony, symfony project, PHPMyAdmin).

### MySQL packages

MySQL server and client packages are provided. The server can be configured trough playbook, setting users and databases. See the example in default **default-playbook-vars.yml**.

PhpMyAdmin is also provided. It will automatically setup YAWS as a web server to host itself, and all PHP modules required and recommended for PhpMyAdmin to work. PhpMyAdmin also installs MySQL server if it is no previously selected.

### Redis packages

Redis tools and server packages are provided. At the moment they are only install packages. No setup packages available.

Redis commander package is also available to give you GUI interface for Redis instance.

### MongoDB packages

MongoDB tools and server packages are provided. At the moment they are only install packages. No setup packages available.

### RabbitMQ packages

RabbitMQ packages are provided.

RabbitMQ-management package is also available to give you GUI interface for RabbitMQ instance.

### Smtp

For your mail related development needs, you can install MailDev, that will in turn setup SMTP server to listen on a standard port (25). All emails received by this SMTP are kept there, not forwarded, and you have GUI interface to view them.

You can install Ssmtp as a substitute for Sendmail command.

Also, Php-ssmtp is provided that will setup PHP to use Ssmtp to forward all "**mail()**" function sent emails to localhost on port 25.

### Logs

For log viewing, RTail is available. If setup, all packages that register logs to view, RTail will be parsing them, and you will have GUI to view those logs "real" time, individually. Note that RTail can take up a bit of memory. If needed, disable this package.

### Default packages installed

| Category          | Package                             | Description                | Configurable |
|-------------------|-------------------------------------|----------------------------|--------------|
| PHP interpreters  |                                     |                            |              |
|                   | package/php/install                 | Base PHP package           |              |
|                   | package/php-cgi/setup               | PHP CGI                    | Yes          |
|                   | package/php-fpm/setup               | PHP FPM                    | Yes          |
| PHP packages      |                                     |                            |              |
|                   | package/php-bcmath/setup            | PHP bcmath extension       | Yes          |
|                   | package/php-bz2/setup               | PHP bz2 extension          | Yes          |
|                   | package/php-ctype/setup             | PHP Ctype extension        | Yes          |
|                   | package/php-curl/setup              | PHP Curl extension         | Yes          |
|                   | package/php-dom/setup               | PHP DOM extension          | Yes          |
|                   | package/php-gd/setup                | PHP GD extension           | Yes          |
|                   | package/php-gettext/setup           | PHP gettext extension      | Yes          |
|                   | package/php-gmp/setup               | PHP GMP extension          | Yes          |
|                   | package/php-iconv/setup             | PHP iconv extension        | Yes          |
|                   | package/php-imagick/setup           | PHP ImageMagick extension  | Yes          |
|                   | package/php-imap/setup              | PHP Imap extension         | Yes          |
|                   | package/php-intl/setup              | PHP Intl extension         | Yes          |
|                   | package/php-json/setup              | PHP Json extension         | Yes          |
|                   | package/php-ldap/setup              | PHP Ldap                   | Yes          |
|                   | package/php-mbstring/setup          | PHP mbstring extension     | Yes          |
|                   | package/php-mcrypt/setup            | PHP mcrypt extension       | Yes          |
|                   | package/php-mysqli/setup            | PHP MySQLi extension       | Yes          |
|                   | package/php-mysqlnd/setup           | PHP MySQLnd extension      | Yes          |
|                   | package/php-odbc/setup              | PHP ODBC extension         | Yes          |
|                   | package/php-opcache/setup           | PHP opcache extension      | Yes          |
|                   | package/php-pdo-mysql/setup         | PHP pdo extension          | Yes          |
|                   | package/php-pgsql/setup             | PHP pgsql extension        | Yes          |
|                   | package/php-posix/setup             | PHP posix extension        | Yes          |
|                   | package/php-recode/setup            | PHP recode extension       | Yes          |
|                   | package/php-simplexml/setup         | PHP simplexml extension    | Yes          |
|                   | package/php-soap/setup              | PHP soap extension         | Yes          |
|                   | package/php-sqlite3/setup           | PHP sqlite3 extension      | Yes          |
|                   | package/php-ssh2/setup              | PHP ssh2 extension         | Yes          |
|                   | package/php-sybase/setup            | PHP sybase extension       | Yes          |
|                   | package/php-tokenizer/setup         | PHP tokenizer extension    | Yes          |
|                   | package/php-wddx/setup              | PHP wddx extension         | Yes          |
|                   | package/php-xdebug/setup            | PHP xdebug extension       | Yes          |
|                   | package/php-xml/setup               | PHP xml extension          | Yes          |
|                   | package/php-xmlreader/setup         | PHP xmlreader extension    | Yes          |
|                   | package/php-xmlrpc/setup            | PHP xmlrpc extension       | Yes          |
|                   | package/php-xmlwriter/setup         | PHP xmlwriter extension    | Yes          |
|                   | package/php-xsl/setup               | PHP xsl extension          | Yes          |
|                   | package/php-zip/setup               | PHP zip extension          | Yes          |
| PHP extras        |                                     |                            |              |
|                   | package/php-tcpdf/install           | PHP TCPDF library          |              |
|                   | package/php-phpseclib/install       | PHP speclib library        |              |
| Version control   |                                     |                            |              |
|                   | package/git/install                 | Git                        |              |
|                   | package/subversion/install          | Subversion                 |              |
|                   | package/bazaar/install              | Bazaar                     |              |
|                   | package/mercurial/install           | Mercurial                  |              |
| PHP project tools |                                     |                            |              |
|                   | package/composer/install            | Composer.phar              |              |
| Projects          |                                     |                            |              |
|                   | project/base/setup                  | Basic project              | Yes          |
|                   | project/nginx_php/install           | Nginx PHP project          |              |
|                   | project/composer/setup              | Composer Nginx Php project | Yes          |
|                   | project/symfony/install             | Symfony Nginx Php project  |              |
| Smtp              |                                     |                            |              |
|                   | package/maildev/install             | Mail Dev SMTP Server       |              |
|                   | package/ssmtp/install               | SSMTP (sendmail replace)   |              |
|                   | package/php-ssmtp/install           | PHP SSMTP                  |              |
| MySql             |                                     |                            |              |
|                   | package/mysql-common/install        | MySQL common files         |              |
|                   | package/mysql-client/install        | MySQL client               |              |
|                   | package/mysql-server/setup          | MySQL server               | Yes          |
|                   | package/phpmyadmin/install          | MySQL GUI                  |              |
| MSSql             |                                     |                            |              |
|                   | package/freetds/setup               | FreeTDS                    | Yes          |
| Redis             |                                     |                            |              |
|                   | package/redis-tools/install         | Redis Tools                |              |
|                   | package/redis-server/install        | Redis Server               |              |
|                   | package/redis-commander/install     | Redis GUI                  |              |
| Logging           |                                     |                            |              |
|                   | package/rtail/install               | rtail server               |              |
|                   | logging/rtail/install               | setup rtail to get logs    |              |
| ElasticSearch     |                                     |                            |              |
|                   | package/elasticsearch/install       | ElasticSearch server       |              |
| RabbitMQ          |                                     |                            |              |
|                   | package/rabbitmq/setup              | Rabbit MQ server           | Yes          |
|                   | package/rabbitmq-management/install | Rabbit MQ GUI              |              |
| MongoDB           |                                     |                            |              |
|                   | package/mongodb/install             | MongoDB Server and tools   |              |

## Web GUI

For certain services web based GUIs are availabe

| Service  | Default Service port | Web GUI tool        | Web Gui port | Package to in install for GUI       |
|---------:|:---------------------|--------------------:|:-------------|-------------------------------------|
| SSH      | 22                   | Shell in a box      | 10022        | project/base/{"install" or "setup"} |
| SMTP     | 25                   | MailDev             | 10025        | project/maildev/install             |
| MySQL    | 3306                 | PhpMyAdmin          | 13306        | project/phpmyadmin/install          |
| RabbitMQ | 5672                 | RabbitMQ management | 15672        | project/rabbitmq-management/install |
| Redis    | 6379                 | Redis Commander     | 16379        | project/redis-commander/install     |

Additionaly there are non standard services web based GUIs

| Service      | Description                                                                      | Web GUI port |
|--------------|----------------------------------------------------------------------------------|--------------|
| rtail server | Web based live log viewer. Some of the packages will register viewble log files. | 8888         |

## Login details

Where possible, login details have been omitted. Where not here are some of default login details being setup (you can change this in config files).

| Username    | Password    | Intent                                                                   |
|------------:|:------------|--------------------------------------------------------------------------|
| admin       | pass        | Administrator, has all privileges possible                               |
| reader      | reader      | Reader. For databases, can only read data                                |
| application | application | Application access. Has full read/write privileges on it's own databases |

