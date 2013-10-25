
# Homebrew-PHP55

PHP 5.5 formulae micro-repo

## Purpose

This repo came natural after the [PHP 5.4](https://github.com/tzvetkoff/homebrew-php54) one.

For the moment, the repository does not contain any PHP extensions - they can be easily installed with `phpize` and then manually added to `php.ini` or `/usr/local/etc/php.ini.d/EXTENSION_NAME.ini`.

The only formulae included are `php` and `phpsh`.

## Installation

Open your favorite terminal and type:

``` bash
brew tap tzvetkoff/php55
brew install php
```

## Configuration

If you install PHP with no options, it will install the CLI, CGI and Apache 2.0 handlers by default (and it will tie it to system's apache)

Available installation options:

| Option                       | Description                                                                                 |
| ---------------------------- | ------------------------------------------------------------------------------------------- |
| `--with-apxs=/usr/sbin/apxs` | Specify the location of the apxs script (to build for Apache different than the system one) |
| `--with-cgi`                 | Build only the CGI SAPI executable (implies --without-apache)                               |
| `--with-fpm`                 | Build only the FPM SAPI executable (implies --without-apache)                               |
| `--without-apache`           | Build without shared Apache 2.0 Handler module                                              |
| `--with-gmp`                 | Include GMP support                                                                         |
| `--with-imap`                | Include IMAP extension                                                                      |
| `--with-intl`                | Include internationalization support                                                        |
| `--with-mssql`               | Include MSSQL-DB support                                                                    |
| `--with-pgsql`               | Include PostgreSQL support                                                                  |
| `--with-unixodbc`            | Include ODBC support via `unixodbc'                                                         |
| `--with-iodbc`               | Include ODBC support via `iODBC'                                                            |

To enable PHP in Apache add the following to httpd.conf and restart Apache:

``` apache
LoadModule php5_module /usr/local/Cellar/php/<PHP_VERSION_HERE>/libexec/apache2/libphp5.so

<IfModule php5_module>
    AddType application/x-httpd-php .php
    AddType application/x-httpd-php-source .phps

    <IfModule dir_module>
        DirectoryIndex index.html index.php
    </IfModule>
</IfModule>
```

The php.ini file can be found in `/usr/local/etc/php.ini`

Additional php.ini files are loaded from `/usr/local/etc/php.ini.d`

If you have installed the formula with `--with-fpm`, to launch `php-fpm` on startup:

* If this is your first install:
  ``` bash
  mkdir -p ~/Library/LaunchAgents
  cp /usr/local/Cellar/php/<PHP_VERSION_HERE>/org.php-fpm.plist ~/Library/LaunchAgents/
  launchctl load -w ~/Library/LaunchAgents/org.php-fpm.plist
  ```

* If this is an upgrade and you already have the org.php-fpm.plist loaded:
  ``` bash
  launchctl unload -w ~/Library/LaunchAgents/org.php-fpm.plist
  cp /usr/local/Cellar/php/<PHP_VERSION_HERE>/org.php-fpm.plist ~/Library/LaunchAgents/
  launchctl load -w ~/Library/LaunchAgents/org.php-fpm.plist
  ```

You may also need to edit the plist to use the correct "UserName".
