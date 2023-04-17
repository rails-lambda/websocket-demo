
## Questions/Followups

[ ] We we really need unique `DockerTag` properties? Maybe we can remove that?
[ ] Within the `WSPolicy` call out how this needs the `RailsLambda` name and `RailsLambdaRole`.
[ ] If you make your own Role, use that name instead!
[ ] Does any of the ActionCable uses ActiveJob for background processing?
[ ] Do we need `channel_prefix` in any way? DynamoDB optimization maybe?
[ ] Where does `Sec-WebSocket-Protocol: actioncable-v1-json` come in?
[ ] Will this work? `ActionCable.server.remote_connections.where(current_user: User.find(1)).disconnect`
[ ] Make standalone API Gateway URLs work besides assuming /cable.
[ ] How will [PeriodicTimers](https://api.rubyonrails.org/v6.1.3/classes/ActionCable/Channel/PeriodicTimers/ClassMethods.html) work? Likely EventBridge schedules.
[x] Should `connection_class` be custom vs. `ActionCable::Connection::Base`?
[ ] Should we set `worker_pool_size` from default 4 to something else?
[ ] Create gem. Dev & Runtime Deps.

## Next Up?

- Connection
  - Unwind `subscribe_to_internal_channel`.
- Subscriptions
- Channels

```json
{"command":"subscribe","identifier":"{\"channel\":\"Turbo::StreamsChannel\",\"signed_stream_name\":\"IloybGtPaTh2YkdGdFlua3RkM012VW05dmJTOHgi--38562feb9cd334e9de85098412c02e4693fc606663ce97cd6a56c7e3162821a1\"}"}
```

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









## Guide Notes

[ ] Add lambda_cable gem to your production group.
[ ] Install LambdaPunch
[ ] Adding CloudFront Distribution

### Adding CloudFront Distribution

You will need the the API Gateway's Physical ID that was created in your CloudFormation stack. You can navigate to that stack, click the "Resources" tab and find the `WSApi` Logical ID matching the name in your `template.yaml` file. The Physical ID should look something like `3iku9itbbb`. This along with the AWS Region where you stack is deployed will be used for the origin domain.

From the CloudFront Distribution created in the Custom Domain Names

- Click "Origins" tab
- Click "Create origin" button
- Origin domain: Ex: 3iku9itbbb.execute-api.us-east-1.amazonaws.com (⚠️ Use proper region)
- Protocol: HTTPS only
  Minimum origin SSL protocol: TLSv1
- Origin path: cable
- Add Custom Header: X-Forwarded-Host myapp.example.com

Now add a new behavior using this origin.

- Click "Behaviors" tab
- Click "Create behavior" 
- Path pattern: 
- Origin (From previous step)
- Viewer protocol policy: HTTPS only
- Allowed HTTP Methods: GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE
- 🔘 Cache policy and origin request policy (recommended)
  - Cache policy: Caching Disabled
  - Origin request policy: WebSockets

https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-working-with.websockets.html

From CloudFront main screen:

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

Add something about these configs.

```ruby
config.action_cable.disable_request_forgery_protection = true
config.action_cable.allowed_request_origins = [
  /execute-api.us-east-1.amazonaws.com/,
  'https://lamby-ws.custominktech.com'
]
```
