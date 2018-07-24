# Network Rail - SMART 

The SMART data is a periodically updated list of mappings between train describer berths
and locations, allowing for TD events to be translated into arrival/departure from location
events.
See <https://wiki.openraildata.com/index.php/Reference_Data#SMART:_Berth_Stepping_Data>
for many more details.

The SMART module allows for two types of data to be fetched:

* Step data - This is the data contained in the SMART file and lists the allowable
steps between berths. You'll get back an array of all the steps.
* Berth data - Given the previously fetched step data you'll get back an hash in a hash
of the berths and how they link to other berths. The keys to the outer hash is the signalling
area of the TD berth and the key to the inner hash is the berth ID. Fir each berth you can
get an array of the steps in both the up and down direction as well as a list of berth IDs
reachable in each direction.

```ruby
# Download the SMART data and get the data from it
RailFeeds::NetworkRail::Credentials.configure(
  username: 'YOUR USERNAME HERE',
  password: 'YOUR PASSWORD HERE'
)
temp_file = RailFeeds::NetworkRail::SMART.fetch
step_data = RailFeeds::NetworkRail::SMART.load_file(temp_file)

# Get the SMART data from a previously saved file
step_data = RailFeeds::NetworkRail::SMART.load_file('PATH TO FILE.json.gz')

# Get data from a previously saved and extracted file
step_data = RailFeeds::NetworkRail::SMART.load_file('PATH TO FILE.json')

# Get data by fetching it from the web
RailFeeds::NetworkRail::Credentials.configure(
  username: 'YOUR USERNAME HERE',
  password: 'YOUR PASSWORD HERE'
)
step_data = RailFeeds::NetworkRail::SMART.fetch_data

# Get the baerth data
berth_data = RailFeeds::NetworkRail::SMART.build_berths(step_data)
```
