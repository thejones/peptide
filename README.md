# Peptide

Get your application _Jacked_

Elixir/Phoenix environment variable loading. A bit different than just loading from a `.env` file.

### The why

If you just need to load from a `dotenv` file use Envy/other. I have a use case where `on application start` I need to fetch current `env` variables from a service. This is done so that a few things can stay in sync. Similar in nature to AWS SSM-PARAM service or secrets-manager.

This lib is central to me being able to port some applications away from Node.js® as I need environment parity between the two applications :swimmer:

### The installation

Add peptide to your dependencies in `mix.exs`.

```elixir
def deps do
  [
    {:peptide, "~> 1.1.1"},
  ]
end
```

## The design decisions

Peptide will overwrite, or try to overwrite, anything that was previously set. This allows, based on `Mix.env` or manually changing config, to be able to connect to different sources. Locally I can change the `.env` and connect to `dev`, `stg`, `prod`, etc. This is only possible if you have access to these machines so your milage will vary. This is designed for my use-case.

## The usage

On Application start you can use one or both of the loaders

```elixir
defmodule PeptideApplication do
  use Application

  def start(_type, _args) do

    # load from http endpoint
    peptide.http_config("http://your_env_service")

    # load from local config, will overwrite above for total control
    peptide.config()


    # Existing code
  end
end
```

This will look for `.env` if using `peptide.config`

You can also specify which files to load manually using `peptide.load` which accepts a list of files to attempt to load.

```elixir
peptide.load([".env"])
```

`peptide.http_config` will parse & set the values or return `{:error, reason}`

## The expected formats

For `.env` use the form of `NAME=VALUE`.
For example:

```dosini
DB_HOST=localhost
DB_USER=root
DB_PASS=s1mpl3
```

For the `http_config` to work it needs to match a certain format. The current release expects output in the following format. This may change to a `json spec` in the future or at a `1.0` release.

```js
// full http response
data: {
  key: "value";
}
```

## The shoutouts

### The name

Inspired by the amino acid building blocks that are peptides. Maybe a bit shady but your body and/or application needs to look good. [peptides](http://chemicallyanabolic.com/peptides/)

### The code

This started as a fork of [envy](https://github.com/BlakeWilliams/envy) from Blake Williams. I have never met Blake Williams but at one point Blake was an employee of Thoughtbot and a friend of mine works at Thoughtbot currently. So, I like to imagine that based on that Blake and I are friends too..
