[![Gem Version](https://badge.fury.io/rb/rail_feeds.png)](http://badge.fury.io/rb/rail_feeds)
[![Build Status](https://secure.travis-ci.org/robertgauld/rail_feeds.png?branch=master)](http://travis-ci.org/robertgauld/rail_feeds)
[![Coveralls Status](https://coveralls.io/repos/robertgauld/rail_feeds/badge.png?branch=master)](https://coveralls.io/r/robertgauld/rail_feeds)
[![Code Climate](https://codeclimate.com/github/robertgauld/rail_feeds.png?branch=master)](https://codeclimate.com/github/robertgauld/rail_feeds)


## Ruby Versions
This gem supports the following versions of ruby, it may work on other versions but is not tested against them so don't rely on it.

  * ruby:
    * 2.4.4 - 2.4.6
    * 2.5.0 - 2.5.5
    * 2.6.0 - 2.6.3
  * jruby:
    * 9.2.0.0 - 9.2.6.0


## Rail Feeds

Make use of the various open data rails feeds in the UK.
For more details of what feeds are available visit [The Open Rail Data Wiki](https://wiki.openraildata.com).

## Installation

Add to your Gemfile and run the `bundle` command to install it.

```ruby
gem 'rail_feeds', '~> 0.1'
```



## Documentation & Versioning

Documentation can be found on [rubydoc.info](http://rubydoc.info/github/robertgauld/rail_feeds/master/frames)
Some guides can be found in the [doc folder of the repo](https://github.com/robertgauld/rail_feeds/tree/master/doc/guides).

We follow the [Semantic Versioning](http://semver.org/) concept.


## Feed Support

### Sources

| Source        | Module                  | Module Alias | Support         |
| ------------- | ----------------------- | ------------ | --------------- |
| Network Rail  | RailFeeds::NetworkRail  | NetRailFeeds | Being developed |
| National Rail | RailFeeds::NationalRail | NatRailFeeds |                 |

### Feeds

| Source        | Client | Feed                                 | Status                               |
| ------------- | ------ | ------------------------------------ | ------------------------------------ |
| Network Rail  | stomp  | Real Time Public Performance Measure | Todo                                 |
| Network Rail  | stomp  | Temporary Speed Restriction          | Todo                                 |
| Network Rail  | stomp  | Train Describer                      | Todo                                 |
| Network Rail  | stomp  | Train Movements                      | Todo                                 |
| Network Rail  | stomp  | Very Short Term Planning             | Todo                                 |
| Network Rail  | http   | Schedule                             | Can download, fetch, parse and dump. |
| Network Rail  | http   | CORPUS (location data)               | Can download, fetch and parse.       |
| Network Rail  | http   | SMART (berth stepping data)          | Can download, fetch and parse.       |
| Network Rail  | http   | Train Planning Data                  | Todo                                 |
| Network Rail  | http   | Train Planning Network Model         | Todo                                 |
| National Rail | stomp  | Darwin Push Port                     |                                      |
| National Rail | stomp  | Darwin Timetable Feed                |                                      |
| National Rail | stomp  | Knowledgebase                        |                                      |
| National Rail | http   | Knowledgebase                        | Can download, fetch and parse NSI.   |
| National Rail | soap   | Darwin Webservice                    |                                      |
| National Rail | rest   | Historical Service Performance       |                                      |
