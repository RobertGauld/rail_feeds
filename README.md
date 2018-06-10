[![Gem Version](https://badge.fury.io/rb/rail_feeds.png)](http://badge.fury.io/rb/rail_feeds)

Master branch:
[![Build Status](https://secure.travis-ci.org/robertgauld/rail_feeds.png?branch=master)](http://travis-ci.org/robertgauld/rail_feeds)
[![Coveralls Status](https://coveralls.io/repos/robertgauld/rail_feeds/badge.png?branch=master)](https://coveralls.io/r/robertgauld/rail_feeds)
[![Code Climate](https://codeclimate.com/github/robertgauld/rail_feeds.png?branch=master)](https://codeclimate.com/github/robertgauld/rail_feeds)

Staging branch:
[![Build Status](https://secure.travis-ci.org/robertgauld/rail_feeds.png?branch=staging)](http://travis-ci.org/robertgauld/rail_feeds)
[![Coveralls Status](https://coveralls.io/repos/robertgauld/rail_feeds/badge.png?branch=master)](https://coveralls.io/r/robertgauld/rail_feeds)


## Build State
This project uses continuous integration to help ensure that a quality product is delivered.
Travis CI monitors two branches (versions) of the code - Master (which is what gets released)
and Staging (which is what is currently being developed ready for moving to master).


## Ruby Versions
This gem supports the following versions of ruby, it may work on other versions but is not tested against them so don't rely on it.

  * 2.2.0 - 2.2.9
  * 2.3.0 - 2.3.6
  * 2.4.0 - 2.4.3
  * 2.5.0 - 2.5.1


## Rail Feeds

Make use of the various open data rails feeds in the UK.
For more details of what feeds are available visit [The Open Rail Data Wiki](https://wiki.openraildata.com).

## Installation

Add to your Gemfile and run the `bundle` command to install it.

```ruby
gem 'rail_feeds', '~> 2.0'
```



## Documentation & Versioning

Documentation can be found on [rubydoc.info](http://rubydoc.info/github/robertgauld/rail_feeds/master/frames)
Some guides can be found in the [doc folder of the repo](https://github.com/robertgauld/rail_feeds/tree/master/doc).

We follow the [Semantic Versioning](http://semver.org/) concept.


## Feed Support

| Source        | Module                  | Module Alias | Support |
| ------------- | ----------------------- | ------------ | ------- |
| Network Rail  | RailFeeds::NetworkRail  | NetRailFeeds |  |
| National Rail | RailFeeds::NationalRail | NatRailFeeds | None yet - any volunteers? |
