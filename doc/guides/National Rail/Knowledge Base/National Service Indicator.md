# National Rail - National Service Indicator

The national service indicator provides information on the current service
provided by each TOC.

```ruby
# Download the file and then get the data from it
RailFeeds::NationalRail::Credentials.configure(
  username: 'YOUR USERNAME HERE',
  password: 'YOUR PASSWORD HERE'
)
RailFeeds::NationalRail::KnowledgeBase::NationalServiceIndicator.download('file name')
data = RailFeeds::NationalRail::KnowledgeBase::NationalServiceIndicator.load_file('file name')

# Get data by fetching it from the web
RailFeeds::NationalRail::Credentials.configure(
  username: 'YOUR USERNAME HERE',
  password: 'YOUR PASSWORD HERE'
)
data = RailFeeds::NationalRail::KnowledgeBase::NationalServiceIndicator.fetch_data
```
