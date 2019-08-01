Changelog for zsh-auto-notify
=============================

0.5.1
-----
* Improved handling of MacOS notifications via #16 (Thanks @dmitmel!)

0.5.0
-----
* Support changing notification title and body using AUTO_NOTIFY_TITLE and AUTO_NOTIFY_BODY

0.4.0
-----
* Add `AUTO_NOTIFY_EXPIRE_TIME` configuration option
* Improvements to notification formatting
* Exit code is now displayed in notifications
* Notifications on linux now show as critical if long command exits with non-zero exit code

0.3.0
-----
* Add support for environments where standard history is disabled. Fixed in #10

0.2.0
-----
* Initial stable release
