# Logging

By default events are logged to STDOUT.

To replace the logger in use:
``` ruby
RailFeeds::Logging.logger = YOUR NEW LOGGER HERE
```

To access the logger in use, for example to change the log level:
``` ruby
RailFeeds::Logging.logger ...
```
