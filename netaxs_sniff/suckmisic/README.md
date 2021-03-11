# Suckmisic

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Setup

For server setup:

  * Install PostgreSQL
  * Configure database connection under `config/dev.exs` or `config/prod.exs`
  * Run `mix ecto.create` to create database
  * Run `mix ecto.migrate` to setup tables
  * Store batches under `storage/batch`

## Rest API Calls

```
ROUTE
/node/spawn
  Request
    JSON:
    {
      "node" : <node id>
    }
  Response
    STATUS: 200
    JSON:
    {
      "status": "ok",
      "node": <node id>,
      "isics": <string>[]
    }
    ---
    STATUS: 200
    JSON:
    {
      "status": "exists",
      "node": <node id>,
      "error": "existing id"
    }
    ---
    STATUS: 200
    JSON:
    {
      "status": "no_work",
      "node": <node id>,
      "error": "no work to be done"
    }
    ---
    STATUS: 200
    JSON:
    {
      "status": "internal",
      "node": <node id>,
      "error": "internal error occured"
    }

-------

ROUTE
/node/terminate
  Request
    JSON:
    {
      "node" : <node id>
    }
  Response
    STATUS: 200
    JSON:
    {
      "status": "ok",
      "node": <node id>
    }
    ---
    STATUS: 200
    JSON:
    {
      "status": "not_exists",
      "node": <node id>,
      "error": "id doesn't exist"
    }
    ---
    STATUS: 200
    JSON:
    {
      "status": "internal",
      "node": <node id>,
      "error": "internal error occured"
    }

-------

ROUTE
/node/exists
Request
    JSON:
    {
      "node" : <node id>
    }
  Response
    STATUS: 200
    JSON:
    {
      "status": "ok",
      "node": <node id>,
      "response": <boolean>
    }

-------

ROUTE
/node/isic/accept
Request
    JSON:
    {
      "node" : <node id>,
      "uco" : <string>,
      "isic" : <string>,
      "description" : <string>
    }
  Response
    STATUS: 200
    JSON:
    {
      "status": "ok",
      "node": <node id>
    }
    ---
    STATUS: 200
    JSON:
    {
      "status": "lost",
      "node": <node id>,
      "error": "isic result was lost"
    }
    ---
    STATUS: 200
    JSON:
    {
      "status": "unknown_isic",
      "node": <node id>,
      "error": "unknown isic"
    }
    ---
    STATUS: 200
    JSON:
    {
      "status": "unknown_node",
      "node": <node id>,
      "error": "unknown node"
    }

-------

ROUTE
/node/isic/reject
Request
    JSON:
    {
      "node" : <node id>,
      "isic" : <string>
    }
  Response
    STATUS: 200
    JSON:
    {
      "status": "ok",
      "node": <node id>
    }
    ---
    STATUS: 200
    JSON:
    {
      "status": "unknown_isic",
      "node": <node id>,
      "error": "unknown isic"
    }
    ---
    STATUS: 200
    JSON:
    {
      "status": "unknown_node",
      "node": <node id>,
      "error": "unknown node"
    }
```

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
