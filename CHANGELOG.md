Changelog
=========

## 0.5.0.beta1 / 2011-08-01

Socky was rewritten from scratch. From this version it's Rack application and is based on
open protocol, and have a lot of new features. Some of them:

- Rack app - you can run both Socky and your web-application in the same process!
- New, standarized communication protocol(it will be easy to implement Socky in other languages)
- New user authentication process - much faster and more secure
- Allow users to dynamicly subscribe/unsubscribe from channels
- New events system - easier to learn and much more powerfull

And many more - please check [Socky website](http://socky.org) for more or check specific Socky elements at [Github](http://github.com/socky).

## 0.4.3 / 2010-10-30

- new features:
  - new, simpler syntax
- bugfixes:
  - none

## 0.4.2 / 2010-10-29

- new features:
  - change config_path and config from constant to method
- bugfixes:
  - none

## 0.4.1 / 2010-10-28

- new features:
  - none
- bugfixes:
  - require by 'socky-client' to stop interfering with socky-ruby-server
  - return 'true' after successful sending message

## 0.4.0 / 2010-10-28

- new features:
  - split project to 3 parts - socky-client-ruby, socky-client-rails and socky-js
  - release as gem
- bugfixes:
  - none