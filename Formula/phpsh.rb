require 'formula'

class Phpsh < Formula
  homepage 'http://www.phpsh.org/'
  url 'https://github.com/facebook/phpsh.git'
  version '1.3'

  depends_on 'python'

  def install
    system 'python', 'setup.py', 'install', "--prefix=#{prefix}"
    man1.install ['src/doc/phpsh.1']
    system 'rm', '-rf', "#{prefix}/man"
    bin.install ['src/phpsh']
  end

  def patches
    DATA
  end
end

__END__
diff --git a/src/__init__.py b/src/__init__.py
index 31b3474..3d1d874 100644
--- a/src/__init__.py
+++ b/src/__init__.py
@@ -758,7 +758,7 @@ Type 'e' to open emacs or 'V' to open vim to %s: %s" %
                 ret_code = self.p.poll()
                 if debug:
                     print "ret_code: " + str(ret_code)
-                if ret_code != None:
+                if ret_code != None and ret_code != 0:
                     if debug:
                         print "NOOOOO"
                     print "subprocess died with return code: " + repr(ret_code)
