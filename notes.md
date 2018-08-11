The application should show
* upcoming departures at North and South stations
* the train destinations
* the train departure times
* the track numbers
* the boarding status (e.g. 'Boarding', 'All Aboard', 'Delayed')

API to interface with is here: https://www.mbta.com/developers/v3-api

Initial thoughts
Implement frontend with phoenix
backend will be an elixir worker that polls for an initial state and then uses stream api for updates
Cache the results from the inital poll so that even when api end point vanishes we still can provide partial or stale information
Would be cool to have something similar to the flip dot display a quick googling turned up https://github.com/jayKayEss/Flapper Will make a pass back to make it look pretty given there is time.
Should organize trains into groups by the stations
deploy to vm via nix
host at ts.rldn.net
Configurable stations
Unit testing
Mocking of API
Max requests limiting
Admin page for info and config of key
Nixpkg for vm
Edoc
convert time to users local time or account for it with moment
color cordinate flip dots

ChatWeb.Endpoint.broadcast("room:lobby", "shout", Map.put_new(%{"name" => "matthew", "message" => "final"}, :id, 600))

curl -X GET "https://api-v3.mbta.com/stops" -H  "accept: application/vnd.api+json" > stops
curl -X GET "https://api-v3.mbta.com/stops/place-sstat?include=child_stops" -H  "accept: application/vnd.api+json"
curl -X GET "https://api-v3.mbta.com/stops/place-north?include=child_stops" -H  "accept: application/vnd.api+json"

curl -sN -H "accept: text/event-stream" -H "x-api-key: " "https://api-v3.mbta.com/predictions/?filter\\[route\\]=CR-Worcester&filter\\[stop\\]=place-sstat&stop_sequence=1"
curl -sN -H "accept: text/event-stream" -H "x-api-key: " "https://api-v3.mbta.com/predictions/?filter\\[stop\\]=place-sstat%2Cplace-north&stop_sequence=1"

curl -sN -H "accept: text/event-stream" "https://api-v3.mbta.com/schedules?include=stop%2Croute%2Cprediction%2Ctrip&filter%5Bdate%5D=2018-08-08&filter%5Bstop%5D=place-sstat%2Cplace-north" -H  "accept: application/vnd.api+json" | json_pp  > schedule2.json

curl -sN -H "accept: text/event-stream" -H "x-api-key: " "https://api-v3.mbta.com/schedules?include=stop%2Croute%2Cprediction%2Ctrip&filter%5Bstop%5D=place-sstat%2Cplace-north&stop_sequence=1"

clock roll over at 3am to account for


schedule needed for initial grab then updates from prediction

only show trains that have pickuptype 0 because all other values wouldnt show up on sign

use https://github.com/mbta/server_sent_event_stage

verified library worked by hitting http://demo.howopensource.com/sse/stocks.php url

406 error not documented in swagger
api-key possible as variable not just header
header support not in server_sent_event_stage

need to convert json to data structure

TerminusStationWeb.Endpoint.broadcast("route:lobby", "update", %{body: "this seems to work"})

no need for db as we can store the state in the gen stage and will be regenned on failure



known issues
api key being left around
innefficent parsing of data from mbta
mnesia seems to be using disc copies even though I told it not to
display library could be nicer
flip is slow when doing an initial render given the amount of flipping it needs to do
needs tests

looked into storing all info locally and just in state. it was/is too hard to filter and tie all the data together
instead going to have to store it all in mnesia

i need to store in db
schedule+prediction
route
stop
trip
vehicle

timestamp is messed up
after spending way to much time on this all times are being stored as a utc time and then converted back to eastern

something to cleanup database over time
delete all things older than now

move api key to  config option
commit it all
unit tests
some comments
nix vm
readme.md
