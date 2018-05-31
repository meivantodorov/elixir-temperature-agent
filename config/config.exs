# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

use Mix.Config

config :maru, API.Temperature,
  http: [port: 8800, ip: {0,0,0,0}]
