
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
