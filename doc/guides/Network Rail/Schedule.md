# Network Rail Schedule

The schedule files from Network Rail contain:

  * Details of the TIPLOCs referenced by trains.
    These are places on the railway for timing purposes.
  * Associations between various trains (e.g. splitting and joining).
  * Train schedules, including details about the train and it's journey.

Every Friday a full extract is performed, you should use this to seed your data and then
apply the following update extracts to keep it current. The CIF format files are generally
available from about 0100 the morning after (so Saturday for the full extract) whereas the
JSON format files take longer to prepare are generally available from 0600.

You can get various amounts of data at a time, you get to pick between:
  * Just freight traffic
  * A specific TOC (you'll need their [TOC code](https://wiki.openraildata.com/index.php/TOC_Codes))
  * Everything (about 40MB download 400MB extracted file for a full extract)?


## Fetching files

The RailFeeds::NetworkRail::Schedule::Fetcher class can be used to fetch these files
from Network Rail, you'll need to be registered for their data feeds and have
subscribed to the schedule you're interested in.

``` ruby
# 1. Require the gem and configure your credentials.
require 'rail_feeds'

RailFeeds::NetworkRail::Credentials.configure(
  username: 'YOUR USERNAME HERE',
  password: 'YOUR PASSWORD HERE'
)

# 2. Fetch some files
fetcher = RailFeeds::NetworkRail::Schedule::Fetcher.new

fetcher.fetch_all_full(:cif) do |full_file|
  ...
end

fetcher.fetch_all_update('fri', :cif) do |update_file|
  ...
end
# Each of the file variables will contain a TempFile which can be used to read
# the CIF data (or passed to the parser to make use of). The files will be deleted
# at the end of the block.
```


## Parsing CIF files

The RailFeeds::NetworkRail::Schedule::Parser class can be used to
parse the previously fetched files. You can parse several files
sequentially in one method call. The parser works by calling a
user provided proc (specific to each event), whenever it meets
the relevant data in the file. Currently only importing CIF files
is supported.

  * on_header(parser, header) - For each header (the first record in a file)
  * on_trailer(parser) - For each trailer (the last record in a file)
  * on_comment(parser, comment) - For each comment line encountered
  * on_tiploc_insert(parser, instruction) - Add a new TIPLOC
  * on_tiploc_amend(parser, instruction) - Amend an existing TIPLOC
  * on_tiploc_delete(parser, instruction) - Delete an existing TIPLOC
  * on_association_new(parser, instruction) - Add a new association
  * on_association_revise(parser, instruction) - Revise an existing association
  * on_association_delete(parser, instruction) - Delete an existing association
  * on_train_new(parser, instruction) - Add a new train schedule
  * on_train_revise(parser, instruction) - Revise an existing train schedule
  * on_train_delete(parser, instruction) - Delete an existing train schedule

``` ruby
# 3. Parse the fetched files
parser = RailFeeds::NetworkRail::Schedule::Parser.new(
  YOUR PROCS HERE
  e.g. on_header: my_header_proc
)
fetcher.fetch_all_full(:cif) do |full_file|
  parser.parse_cif full_file
end
# Your proc(s) can stop the parsing at anytime by calling parser.stop_parsing

# 4. Print all the header information:
header_proc = proc do |parser, header|
  puts header
  parser.stop_parsing
end
parser = RailFeeds::NetworkRail::Schedule::Parser.new(
  on_header: header_proc
)
fetcher.fetch_all_full(:cif) do |full_file|
  parser.parse_cif_file full_file
end
fetcher.fetch_all_update(:cif) do |update_file|
  parser.parse_cif_file update_file
end
```


## Just getting the data
The RailFeeds::NetworkRail::Schedule::Data class can be used to avoid
directly using the parser and fetcher should you wish. You'll end up
with the abillity to get arrays of headers, tiplocs, associations and
trains at the expense of everything being loaded into RAM as once.

``` ruby
data = RailFeeds::NetworkRail::Schedule::Data.new
data.fetch_data
# Uses the fetcher to get the relevant full and/or update files to
load the most up to date full schedule.
```
