require 'formula'

def postgres_installed?
  `which pg_config`.length > 0
end

class Php < Formula
  homepage 'http://php.net'
  url 'http://www.php.net/distributions/php-5.5.11.tar.bz2'
  sha256 '60e14c255f2a461a7a26639b84a2fc448cc2f91c8dead0e9fd00cd8ba27a2e96'
  version '5.5.11'

  head 'https://github.com/php/php-src.git', :branch => 'PHP-5.5'

  skip_clean ['bin', 'sbin']

  depends_on 'gettext'
  depends_on 'freetype'
  depends_on 'libpng'
  depends_on 'jpeg'
  depends_on 'mcrypt'
  depends_on 'freetds' if build.include? 'with-mssql'
  depends_on 'gmp' if build.include? 'with-gmp'
  depends_on 'icu4c' if build.include? 'with-intl'
  depends_on 'imap-uw' if build.include? 'with-imap'
  depends_on 'libevent' if build.include? 'with-fpm'
  depends_on 'unixodbc' if build.include? 'with-unixodbc'
  depends_on 'curl' if build.include? 'with-homebrew-curl'
  depends_on 'openssl' if build.include? 'with-homebrew-openssl'
  depends_on 'libxslt' if build.include? 'with-homebrew-libxslt'

  if build.include? 'with-pgsql'
    depends_on 'postgresql' => :recommended unless postgres_installed?
  end

  if build.include? 'with-cgi' and build.include? 'with-fpm'
    raise 'Cannot specify both CGI and FPM builds.'
  end

  def options
    [
      ['--with-apxs=/usr/sbin/apxs', 'Specify the location of the apxs script (to build for Apache different than the system one)'],
      ['--without-apache', 'Build without shared Apache 2.0 Handler module'],
      ['--without-pear', 'Build without PEAR'],
      ['--with-cgi', 'Build only the CGI SAPI executable (implies --without-apache)'],
      ['--with-fpm', 'Build only the FPM SAPI executable (implies --without-apache)'],
      ['--with-pgsql', 'Include PostgreSQL support'],
      ['--with-mssql', 'Include MSSQL-DB support'],
      ['--with-unixodbc', 'Include ODBC support via `unixodbc\''],
      ['--with-iodbc', 'Include ODBC support via `iODBC\''],
      ['--with-intl', 'Include internationalization support'],
      ['--with-imap', 'Include IMAP extension'],
      ['--with-gmp', 'Include GMP support'],
      ['--with-homebrew-curl', 'Build against brewed CURL'],
      ['--with-homebrew-openssl', 'Build against brewed OpenSSL'],
      ['--with-homebrew-libxslt', 'Build against brewed LibXSLT'],
   ]
  end

  def patches
    []
  end

  def install
    args = [
      "--prefix=#{prefix}",
      '--disable-debug',
      "--with-config-file-path=#{etc}",
      "--with-config-file-scan-dir=#{etc}/php.ini.d",
      '--with-iconv-dir=/usr',
      '--enable-dba',
      '--enable-zend-signals',
      '--enable-dtrace',
      '--enable-opcache',
      '--with-ndbm=/usr',
      '--enable-exif',
      '--enable-soap',
      '--enable-wddx',
      '--enable-ftp',
      '--enable-sockets',
      '--enable-zip',
      '--enable-pcntl',
      '--enable-shmop',
      '--enable-sysvsem',
      '--enable-sysvshm',
      '--enable-sysvmsg',
      '--enable-mbstring',
      '--enable-mbregex',
      '--enable-bcmath',
      '--enable-calendar',
      '--with-zlib=/usr',
      '--with-bz2=/usr',
      '--with-ldap',
      '--with-ldap-sasl=/usr',
      '--with-xmlrpc',
      '--with-kerberos=/usr',
      '--with-libxml-dir=/usr',
      '--with-gd',
      '--enable-gd-native-ttf',
      "--with-freetype-dir=#{Formula.factory('freetype').opt_prefix}",
      "--with-mcrypt=#{Formula.factory('mcrypt').opt_prefix}",
      "--with-jpeg-dir=#{Formula.factory('jpeg').opt_prefix}",
      "--with-png-dir=#{Formula.factory('libpng').opt_prefix}",
      "--with-gettext=#{Formula.factory('gettext').opt_prefix}",
      '--with-snmp=/usr',
      '--with-tidy',
      '--with-mhash',
      '--with-mysql-sock=/tmp/mysql.sock',
      '--with-mysqli=mysqlnd',
      '--with-mysql=mysqlnd',
      '--with-pdo-mysql=mysqlnd',
      '--with-libedit',
      "--mandir=#{man}",
    ]

    if build.include? 'with-homebrew-curl'
      args << "--with-curl=#{Formula.factory('curl').opt_prefix}"
    else
      args << '--with-curl'
    end

    if build.include? 'with-homebrew-openssl'
      args << "--with-openssl=#{Formula.factory('openssl').opt_prefix}"
    else
      args << '--with-openssl=/usr'
    end

    if build.include? 'with-homebrew-libxslt'
      args << "--with-xsl=#{Formula.factory('libxslt').opt_prefix}"
    else
      args << '--with-xsl=/usr'
    end

    args << '--without-apache' if build.include?('without-apache') || build.include?('with-cgi') || build.include?('with-fpm')

    if build.include? 'with-fpm'
      args << '--enable-fpm'
      (var+'log').mkpath
      touch var+'log/php-fpm.log'
      (prefix+'org.php-fpm.plist').write php_fpm_startup_plist
      (prefix+'org.php-fpm.plist').chmod 0644
    elsif build.include? 'with-cgi'
      args << '--enable-cgi'
    end

    unless args.include? '--without-apache'
      args << "--with-apxs2=#{apxs}"
      args << "--libexecdir=#{libexec}"
    end

    if build.include? 'with-gmp'
      args << '--with-gmp'
    end

    if build.include? 'with-imap'
      args << "--with-imap=#{Formula.factory('imap-uw').opt_prefix}"
      args << '--with-imap-ssl=/usr'
    end

    if build.include? 'with-intl'
      args << '--enable-intl'
      args << "--with-icu-dir=#{Formula.factory('icu4c').opt_prefix}"
    end

    if build.include? 'with-mssql'
      args << "--with-mssql=#{Formula.factory('freetds').opt_prefix}"
      args << "--with-pdo-dblib=#{Formula.factory('freetds').opt_prefix}"
    end

    if build.include? 'with-pgsql'
      if Formula.factory('postgresql').installed?
        args << "--with-pgsql=#{Formula.factory('postgresql').opt_prefix}"
        args << "--with-pdo-pgsql=#{Formula.factory('postgresql').opt_prefix}"
      else
        args << "--with-pgsql=#{`pg_config --includedir`}"
        args << "--with-pdo-pgsql=#{`which pg_config`}"
      end
    end

    if build.include? 'with-iodbc'
      args << '--with-iodbc'
    elsif build.include? 'with-unixodbc'
      args << "--with-unixODBC=#{Formula.factory('unixodbc').prefix}"
      args << "--with-pdo-odbc=unixODBC,#{Formula.factory('unixodbc').prefix}"
    end

    args << '--without-pear' if build.include? 'without-pear'

    system './buildconf' if build.head?
    system './configure', *args

    unless args.include? '--without-apache'
      inreplace 'Makefile',
        /INSTALL_IT = \$\(mkinstalldirs\) '\$\(INSTALL_ROOT\).*?' && \$\(mkinstalldirs\) '\$\(INSTALL_ROOT\).*?' && .*?\/apxs -S LIBEXECDIR='\$\(INSTALL_ROOT\).*?' -S SYSCONFDIR='\$\(INSTALL_ROOT\).*?' -i -a -n php5 libs\/libphp5.so/,
        "INSTALL_IT = $(mkinstalldirs) '#{libexec}/apache2' && $(mkinstalldirs) '$(INSTALL_ROOT)/private/etc/apache2' && #{apxs} -S LIBEXECDIR='#{libexec}/apache2' -S SYSCONFDIR='$(INSTALL_ROOT)/private/etc/apache2' -i -n php5 libs/libphp5.so"
    end

    if build.include? 'with-intl'
      inreplace 'Makefile' do |s|
        s.change_make_var! 'EXTRA_LIBS', "\\1 -lstdc++"
      end
    end

    system 'make'
    ENV.deparallelize # parallel install fails on some systems
    system 'make install'

    etc.install './php.ini-production' => 'php.ini' unless File.exists? etc+'php.ini'
    chmod_R 0755, lib+'php'
    system bin+'pear', 'config-set', 'php_ini', etc+'php.ini'

    if build.include?('--with-fpm') and not File.exists? etc+'php-fpm.conf'
      etc.install 'sapi/fpm/php-fpm.conf'
      inreplace etc+'php-fpm.conf' do |s|
        s.sub!(/^;?daemonize\s*=.+$/, 'daemonize = no')
        s.sub!(/^;?pm\.start_servers\s*=.+$/, 'pm.start_servers = 20')
        s.sub!(/^;?pm\.min_spare_servers\s*=.+$/, 'pm.min_spare_servers = 5')
        s.sub!(/^;?pm\.max_spare_servers\s*=.+$/, 'pm.max_spare_servers = 35')
      end
    end
  end

  def caveats; <<-EOS
To enable PHP in Apache add the following to httpd.conf and restart Apache:
    LoadModule php5_module /usr/local/opt/php/libexec/apache2/libphp5.so

    <IfModule php5_module>
        AddType application/x-httpd-php .php
        AddType application/x-httpd-php-source .phps

        <IfModule dir_module>
            DirectoryIndex index.html index.php
        </IfModule>
    </IfModule>

The php.ini file can be found in:
    #{etc}/php.ini

Additional php.ini files are loaded from:
    #{etc}/php.ini.d

If you have installed the formula with --with-fpm, to launch php-fpm on startup:
    * If this is your first install:
        mkdir -p ~/Library/LaunchAgents
        cp #{prefix}/org.php-fpm.plist ~/Library/LaunchAgents/
        launchctl load -w ~/Library/LaunchAgents/org.php-fpm.plist

    * If this is an upgrade and you already have the org.php-fpm.plist loaded:
        launchctl unload -w ~/Library/LaunchAgents/org.php-fpm.plist
        cp #{prefix}/org.php-fpm.plist ~/Library/LaunchAgents/
        launchctl load -w ~/Library/LaunchAgents/org.php-fpm.plist

You may also need to edit the plist to use the correct "UserName".
   EOS
  end

  def test
    if build.include?('with-fpm')
      system "#{sbin}/php-fpm -y #{etc}/php-fpm.conf -t"
    end
  end

  def php_fpm_startup_plist; <<-EOPLIST.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>Label</key>
      <string>org.php-fpm</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{sbin}/php-fpm</string>
        <string>--fpm-config</string>
        <string>#{etc}/php-fpm.conf</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>UserName</key>
      <string>#{`whoami`.chomp}</string>
      <key>WorkingDirectory</key>
      <string>#{var}</string>
      <key>StandardErrorPath</key>
      <string>#{prefix}/var/log/php-fpm.log</string>
    </dict>
    </plist>
    EOPLIST
  end

  def apxs
    ARGV.value('with-apxs') || '/usr/sbin/apxs'
  end
end
