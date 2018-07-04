# Network Rail CORPUS (Codes for Operations, Retail & Planning – a Unified Solution)

The CORPUS data is a list of indentification information for locations around the network.
See <https://wiki.openraildata.com/index.php/Reference_Data#CORPUS:_Location_Reference_Data>
for many more details.

You'll get an array of a data struct with the following attributes:

* tiploc - TIPLOC code (e.g. "ERGNCHP")
* stanox - STANOX code (e.g. 78370)
* crs - 3 letter location code (e.g. "ECP")
* uic - UIC code (e.g. 3750)
* nlc - NLC code (e.g. "37500")
* nlc_description - Description of the NLC (e.g. "ENERGLYN & CHURCHILL PARK")
* nlc_short_description - 16 character version (e.g. "ENERGLYN & C PK")

```ruby
# Get data from a previously saved file
data = RailFeeds::NetworkRail::CORPUS.load_file('PATH TO FILE.json.gz')

# Get data from a previously saved and extracted file
data = RailFeeds::NetworkRail::CORPUS.load_file('PATH TO FILE.json')

# Get data by fetching it from the web
RailFeeds::NetworkRail::Credentials.configure(
  username: 'YOUR USERNAME HERE',
  password: 'YOUR PASSWORD HERE'
)
data = RailFeeds::NetworkRail::CORPUS.fetch_data
```
