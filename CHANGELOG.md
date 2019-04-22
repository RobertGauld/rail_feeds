## Version 0.0.3

  * ...

## Version 0.0.2

  * Add support for:
    * rubies 2.4.4 - 2.6.2
    * jrubyies 9.2.0.0 - 9.2.6.0
  * Sort API consistency - when passing credentials use positional not keywork arguments, except:
    * Initializing a new HTTP or Stomp client
    * Initializing a new NetworkRail Schedule Fetcher
  * Add National rail - Knowledge base - National service indicator via HTTP.
  * Fix issue 1: OpenURI returns a StringIO not TempFile when size is under 10KB.
  * Fix "undefined method `parse_cif_file'" when loading Network Rail schedule data.

## Version 0.0.1

 * Initial release.
