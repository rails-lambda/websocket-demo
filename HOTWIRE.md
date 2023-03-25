
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

* Swap webrick for puma. 
* Add Hotwire LiveReload: https://github.com/kirillplatonov/hotwire-livereload
* Add redis service to the devcontainer.
* Change cable.yml to redis v. async adapter.

