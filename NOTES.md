## Questions/Followups

- We we really need unique `DockerTag` properties? Maybe we can remove that?
- Within the `WSPolicy` call out how this needs the `RailsLambda` name and `RailsLambdaRole`.
  - If you make your own Role, use that name instead!

## Implementation Notes

Configuration:
- Should `connection_class` be custom vs. `ActionCable::Connection::Base`?
- Should we set `worker_pool_size` from default 4 to something else?

Connection & Channel:
- app/channels/application_cable/connection.rb
- class Connection < ActionCable::Connection::Base
- app/channels/application_cable/channel.rb
- class Channel < ActionCable::Channel::Base

SubscriptionAdapter:
- Should we also prepend ChannelPrefix? YES!

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

## Basic LambdaCable

```ruby
gem "aws-sdk-apigatewaymanagementapi"
gem "aws-sdk-dynamodb"
```
