
## Features

- [ ] Add username to chat window messages.
- [ ] Show total connected users in some top area.
  - [ ] https://www.youtube.com/watch?v=OcWdFSg11T8
- [ ] Admin to see all logged in users.
- [ ] Allow someone to enter their own/any name.
- [ ] Maybe hook into social auth to lock this down a bit?
- [ ] Admin for global Server#open_connections_statistics or whatever?

## Questions/Followups

- [ ] Set SECRET_KEY_BASE in SSM.
- [ ] Should Server::Base#worker_pool be custom?
- [ ] Does any of the ActionCable uses ActiveJob for background processing?
- [x] Will this work? `ActionCable.server.remote_connections.where(current_user: User.find(1)).disconnect`
  - [x] We would have to find a way to get the API GW connection_id from a user?
  - [x] Hook this up to logout. https://stackoverflow.com/questions/40495351/how-to-close-connection-in-action-cable 
- [ ] Make standalone API Gateway URLs work besides assuming /cable.
- [ ] Should we set `worker_pool_size` from default 4 to something else?
- [ ] How does a "server" subscribe to an internal channel so it can disconnect folks?
- [ ] Test `ActionCable::Connection::Authorization::UnauthorizedError` does a clean close.
- [ ] What if there are no identifiers? Like no current user? Does AC even support such a thing? Patterns?
- [x] Dig into logout. Do unsubscribes work? Is $disconnect called? Many times? 
- [x] Make sure `restore_from` calls `connect` if respond to. Nope, see docs.
- [x] Wire up `disconnect` for Channel.
- [ ] Make sure deploys do disconnects. How? Then document it.
- [ ] How is JavaScript only loaded when LambdaCable is used?
- [ ] Hook up all `ActiveSupport::Notifications` to CloudWatch Embedded Metrics?

## DynamoDB Table Design

- Should we put everything into a single table?
- Do some sort of DynamoDB stream for Connection -> Delete -> Subscriptions cleanup.

## Next Up?

- [ ] Connection
  - [ ] Negative state callbacks when instantiating them again?
  - [x] Unwind `subscribe_to_internal_channel`.
- [ ] Server
- [ ] Subscriptions
  - [ ] Negative state callbacks when instantiating them again in `SubscriptionsCollection`?
  - [ ] Why do subscriptions retry after 1s? Can we wait for a bit longer?
- [ ] Channels
- [ ] Channel::PeriodicTimers (maybe use CloudWatch)
  - [ ] https://api.rubyonrails.org/v6.1.3/classes/ActionCable/Channel/PeriodicTimers/ClassMethods.html

## PubSub Adapter

```log
[LambdaCable] [DEBUG] LambdaCable::Handler#handle route_key: "connect" connection_id: "GKSQXe6loAMCKNQ="
Started GET "/cable" for 130.176.137.83 at 2023-06-07 18:20:27 +0000
[LambdaCable] [DEBUG] [NOP] LambdaCable::Server::Connections#setup_heartbeat_timer
[LambdaCable] [DEBUG] LambdaCable::Connection::SubscriptionsCollection#initialize
Started GET "/cable" [WebSocket] for 130.176.137.83 at 2023-06-07 18:20:28 +0000
Successfully upgraded to WebSocket (REQUEST_METHOD: GET, HTTP_CONNECTION: , HTTP_UPGRADE: )
[LambdaCable] [DEBUG] LambdaPunch.handling...
[LambdaCable] [DEBUG] [NOP] LambdaCable::Connection::InternalChannel#subscribe_to_internal_channel internal_channel: "action_cable/Z2lkOi8vd2Vic29ja2V0LWRlbW8vVXNlci9NaXR0aWUrUmVpY2hlcnQ"
[LambdaCable] [DEBUG] LambdaCable::Connection::WebSocket#transmit connection_id: GKSQXe6loAMCKNQ= data: "{\"type\":\"welcome\",\"connection_id\":\"GKSQXe6loAMCKNQ=\"}"
[LambdaCable] [DEBUG] [NOP] LambdaCable::Connection::MessageBuffer#process!
[LambdaCable] [DEBUG] [NOP] LambdaCable::Server::Connections#add_connection
[LambdaCable] [DEBUG] LambdaCable::Server::ConnectionsDb#open connection_id: GKSQXe6loAMCKNQ=, connection_identifier: Z2lkOi8vd2Vic29ja2V0LWRlbW8vVXNlci9NaXR0aWUrUmVpY2hlcnQ

[LambdaCable] [DEBUG] LambdaCable::Handler#handle route_key: "default" connection_id: "GKSQXe6loAMCKNQ="
[LambdaCable] [DEBUG] LambdaCable::Server::ConnectionsDb#update connection_id: GKSQXe6loAMCKNQ=
[LambdaCable] [DEBUG] LambdaCable::Connection::SubscriptionsCollection#initialize
[LambdaCable] [DEBUG] LambdaCable::Connection::WebSocket#alive? connection_id: GKSQXe6loAMCKNQ=
[LambdaCable] [DEBUG] LambdaCable::Connection::SubscriptionsCollection#[]= identifier: {"channel":"Turbo::StreamsChannel","signed_stream_name":"IloybGtPaTh2ZDJWaWMyOWphMlYwTFdSbGJXOHZVbTl2YlM4eCI=--904534f77fef880cf98202f7620bff7028bc80642052fa350c0e67054adf530e"}
[LambdaCable] [DEBUG] LambdaCable::Connection::SubscriptionsDb#put identifier: {"channel":"Turbo::StreamsChannel","signed_stream_name":"IloybGtPaTh2ZDJWaWMyOWphMlYwTFdSbGJXOHZVbTl2YlM4eCI=--904534f77fef880cf98202f7620bff7028bc80642052fa350c0e67054adf530e"}
[LambdaCable] [DEBUG] LambdaCable::Connection::StreamEventLoop#post
[LambdaCable] [DEBUG] LambdaPunch.handling...
[LambdaCable] [DEBUG] SubscriptionAdapter#initialize
[LambdaCable] [DEBUG] SubscriptionAdapter#subscribe to "Z2lkOi8vd2Vic29ja2V0LWRlbW8vUm9vbS8x" with message_callback #<Proc:0x0000ffff57606fb0 /workspaces/websocket-demo/vendor/bundle/ruby/3.2.0/gems/actioncable-7.0.4.2/lib/action_cable/channel/streams.rb:149 (lambda)> and success_callback #<Proc:0x0000ffff575ffd28 /workspaces/websocket-demo/vendor/bundle/ruby/3.2.0/gems/actioncable-7.0.4.2/lib/action_cable/channel/streams.rb:88 (lambda)>
Turbo::StreamsChannel is transmitting the subscription confirmation
[LambdaCable] [DEBUG] LambdaCable::Connection::WebSocket#transmit connection_id: GKSQXe6loAMCKNQ= data: "{\"identifier\":\"{\\\"channel\\\":\\\"Turbo::StreamsChannel\\\",\\\"signed_stream_name\\\":\\\"IloybGtPaTh2ZDJWaWMyOWphMlYwTFdSbGJXOHZVbTl2YlM4eCI=--904534f77fef880cf98202f7620bff7028bc80642052fa350c0e67054adf530e\\\"}\",\"type\":\"confirm_subscription\"}"
Turbo::StreamsChannel is streaming from Z2lkOi8vd2Vic29ja2V0LWRlbW8vUm9vbS8x
[LambdaCable] [DEBUG] LambdaCable::Server::ConnectionsDb#update connection_id: GKSQXe6loAMCKNQ=
```

Use these?

```ruby
ActiveSupport::CurrentAttributes.reset_all
LambdaCable::Current.connection_id = connection_id
```

```ruby
signed_stream_name = "IloybGtPaTh2ZDJWaWMyOWphMlYwTFdSbGJXOHZVbTl2YlM4eCI=--904534f77fef880cf98202f7620bff7028bc80642052fa350c0e67054adf530e"
Turbo::StreamsChannel.verified_stream_name(signed_stream_name)
=> "Z2lkOi8vd2Vic29ja2V0LWRlbW8vUm9vbS8x"

GlobalID::Locator.locate "Z2lkOi8vd2Vic29ja2V0LWRlbW8vUm9vbS8x"
=> #<Room:0x0000ffffa284d3a0 id: 1, name: "Lambda", created_at: Tue, 06 Jun 2023 22:24:05.638893000 UTC +00:00, updated_at: Tue, 06 Jun 2
```

## Internal Channel & Disconnects

```ruby
name = "Micah O'Reilly"
ActionCable.server.remote_connections.where(current_user: User.find(name)).disconnect

[ActionCable] Broadcasting to action_cable/Z2lkOi8vd2Vic29ja2V0LWRlbW8vVXNlci9DbGludCtTY2hyb2VkZXI: {:type=>"disconnect"}
[LambdaCable] [DEBUG] SubscriptionAdapter#initialize
[LambdaCable] [DEBUG] SubscriptionAdapter#broadcast to "action_cable/Z2lkOi8vd2Vic29ja2V0LWRlbW8vVXNlci9DbGludCtTY2hyb2VkZXI" with payload "{\"type\":\"disconnect\"}"
```


[LambdaCable] [DEBUG] SubscriptionAdapter#subscribe to "Z2lkOi8vd2Vic29ja2V0LWRlbW8vUm9vbS8x" with message_callback #<Proc:0x0000ffff70ada6b8 /workspaces/websocket-demo/vendor/bundle/ruby/3.2.0/gems/actioncable-7.0.4.2/lib/action_cable/channel/streams.rb:149 (lambda)> and success_callback #<Proc:0x0000ffff70ad9740 /workspaces/websocket-demo/vendor/bundle/ruby/3.2.0/gems/actioncable-7.0.4.2/lib/action_cable/channel/streams.rb:88 (lambda)>

[LambdaCable] [DEBUG] SubscriptionAdapter#broadcast to "Z2lkOi8vd2Vic29ja2V0LWRlbW8vUm9vbS8x" 






------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

* Talk about no Server#connections...
* Talk about how pings are sent. 60s from client side.
* Channel instances are NO LONGER "long-lived". Talk about what this means. Like ivar usage (see @room & speak examples). Pros/cons.
* Within the `WSPolicy` call out how this needs the `RailsLambda` name and `RailsLambdaRole`.
* If you make your own Role, use that name instead!

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

## Installs

```shell
./bin/rails importmap:install
./bin/rails turbo:install
./bin/rails stimulus:install
```

## Data Model & Scaffold

```shell
rails g scaffold room name:string
rails g model message room:references content:text
rails db:create
rails db:migrate
```

## Development WebSockets w/Redis

Are these temporary?

```ruby
group :development, :test do
  gem "puma"
end

group :development do
  gem "redis"
  gem "hotwire-livereload"
end
```

* Swap `webrick` for `puma` in `development, test` groups.
* Add Hotwire LiveReload: https://github.com/kirillplatonov/hotwire-livereload
* Add `redis` to `development` group and service to the devcontainer.
* Change cable.yml to redis v. async adapter.

## Configure Host

* TODO: Refactor to ENV vars?
* TODO: Can this be in LambyCable?

```ruby
config.action_cable.url = 'wss://911769d0hb.execute-api.us-east-1.amazonaws.com/cable'
config.action_cable.allowed_request_origins = [ /zcmyp26ogmtmmqjym24vb35pju0rmysm.lambda-url.us-east-1.on.aws/ ]
```

* Call out Lambda Function URLs but you can use CloudFront to map to a single domain.

Maybe needed. I did have to add this to the application.rb for easy session name.

```ruby
config.session_store :cookie_store, expire_after: 1.day, key: '_session'
```

## Testing Connection Timeout

```shell
wscat --connect wss://websockets-live.lamby.cloud/cable \
      --origin "https://websockets-live.lamby.cloud" \
      --header "Sec-WebSocket-Protocol:actioncable-v1-json" \
      --protocol "13"

wscat --connect wss://websockets.lamby.cloud/cable \
      --origin "https://websockets.lamby.cloud" \
      --header "Sec-WebSocket-Protocol:actioncable-v1-json" \
      --protocol "13"

{"command":"subscribe","identifier":"{\"channel\":\"Turbo::StreamsChannel\",\"signed_stream_name\":\"IloybGtPaTh2YkdGdFlua3RkM012VW05dmJTOHgi--38562feb9cd334e9de85098412c02e4693fc606663ce97cd6a56c7e3162821a1\"}"}
```

```ruby
require 'aws-sdk-apigatewaymanagementapi'
endpoint = "https://1o3hfab3i4.execute-api.us-east-1.amazonaws.com/cable"
client = Aws::ApiGatewayManagementApi::Client.new region: 'us-east-1', endpoint: endpoint

connection_id = "EkkiVe-TIAMCFjg="

client.get_connection connection_id: connection_id
client.post_to_connection data: JSON.dump({type: 'ping'}), connection_id: connection_id
```


## Guide Notes

[ ] Add lambda_cable gem to your production group.
[ ] Install LambdaPunch
[ ] Adding CloudFront Distribution
[ ] Talk about arch of the `restore_from` method and how `connect` is one time. Ex: Make current_user a lazy read vs setting a property. This does work with `identified_by`.

```ruby
identified_by :current_user
def connect
  reject_unauthorized_connection unless session_user
  self.current_user = session_user
end
# vs...
identified_by :current_user
def connect
  reject_unauthorized_connection unless current_user
end
def current_user
  @current_user ||= session_user
end
```

### Architecture Reports

What does Serverless Event-Driven WebSockets even mean?

- There is no internal "server" channel to send server-side messages to each "running" server. For example, say you want to disconnect a User for some reason. For a K8s pod, they would all be subscribed to an internal channel so they can talk to each other. In this situation, the servers hold state. However, for Lambda, API Gateway holds our state. So there is no need for an internal channel. Instead we send the disconnect message to API Gateway. 

No server-side state! Connection#event_loop which is based on the Server#event_loop work is not handled by LambdaPunch after the request/response loop is finished. So just like the ActionCable servers where the main thread is not blocked, we do work in the background. But no long-term state is maintained after the request is finished. We also tell ActionCable to use a worker_pool size of 1 since there is no need for this cleverness.

- No need for server restarts or shutdown events.
- Worker pools are always empty after each request thanks to LambdaPunch.
- No such thing as asking an individual server for its statistics. It holds nothing.
- No WebSocket message callbacks, simply just wait for an invoke event.

> WRT ActionCable::Channel
> 
> This may be seconds, minutes, hours, or even days. That means you have to take special care
> not to do anything silly in a channel that would balloon its memory footprint or whatever...
> 
> The upside... you can use instance variables to keep reference to objects that future 
> subscriber requests can interact with using `subscribed` hooks.

```ruby
class ChatChannel < ApplicationCable::Channel
  def subscribed
    @room = Chat::Room[params[:room_number]]
  end

  def speak(data)
    @room.speak data, user: current_user
  end
end
```

When you do not have a constant CONNECTION, you must store state somewhere else. We use DynamoDB for this. Specifically, call out the session for identified by.

Since there are no "servers" there are no collection of instances holding on "connections" for clients. This means that `ActionCable::Server::Connections` module is mostly moot along with its `#connections` and add/remove connection methods. There is only one server holding on to all connections and that is API Gateway. We decided not to synthesize this behavior in LambdaCable. There is no give me all connections for API Gateway in whole (like `#remote_connections`) or per workload. Only the work at hand for any given event-based transaction. 

- Make some diagram having 3 servers, each having 20, 30, and 15 connections, to one API Gateway.
- Expand or illustrate how disconnecting a user would look like.
- No server shutdown work to do. No connections to close.
- No need for "internal" channels.

### Adding CloudFront Distribution

Assuming you used our [cookiecutter project](https://lamby.cloud/docs/quick-start), you will need both the WebSocket API Gateway's Physical ID and the HTTP Function URL for your Lambda that was created in your CloudFormation stack. For API Gateway, navigate to that stack, click the "Resources" tab and find the `WSApi` Logical ID matching the name in your `template.yaml` file. The Physical ID should look something like `3iku9itbbb`. Steps to get your Function URL will be included in later steps.

First, we are going to need to create a new origin request policy [specifically for WebSockets](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-working-with.websockets.html). From CloudFront **main** screen:

- Click "Policies" in left panel
- Click "Origin request" tab
- Click "Create origin request policy" button
- Name: WebSockets
- Headers: Include the following headers (Add Custom)
  - Sec-WebSocket-Key
  - Sec-WebSocket-Version
  - Sec-WebSocket-Protocol
  - Sec-WebSocket-Accept
  - Sec-WebSocket-Extensions
- Query strings: None
- Cookies: All

Now follow the guides on our [Simple CloudFront Distribution](https://lamby.cloud/docs/custom-domain#simple-cloudfront-distribution) page and create a new distribution that will route traffic to your Function URL. Remember to create the Route53 entry during this step too. Once completed, here are the steps to create the origin for your `/cable` WebSockets path to use API Gateway. Reminder, this is where you will need your the Physical ID of your `WSApi` for the origin domain.

- Click "Origins" tab
- Click "Create origin" button
- Origin domain: Ex: 3iku9itbbb.execute-api.us-east-1.amazonaws.com (⚠️ Use proper region. No wss://)
- Protocol: HTTPS only
  Minimum origin SSL protocol: TLSv1 (⚠️ v1.2 will NOT work)
- Origin path: (none)
- Add Custom Header: X-Forwarded-Host myapp.example.com
- Name: apigw (up to you)

Now, we can create teh `/cable` behavior to use this new origin.

- Click "Behaviors" tab
- Click "Create behavior" 
- Path pattern: /cable
- Origin (from previous step, ex: apigw)
- Viewer protocol policy: HTTPS only
- Allowed HTTP Methods: GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE
- 🔘 Cache policy and origin request policy (recommended)
  - Cache policy: Caching Disabled
  - Origin request policy: WebSockets

Add something about these configs.

```ruby
config.action_cable.disable_request_forgery_protection = true
config.action_cable.allowed_request_origins = [
  /execute-api.us-east-1.amazonaws.com/,
  'https://websockets.lamby.cloud'
]
```
