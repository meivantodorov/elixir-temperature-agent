# Temperature Embedded Agent written in Elixir

## Description
The project provides REST API for getting the current temperature from `DS18B20` sensore. The sensore should be set already.
For the momnet it works with only one connected sensore.

## OS
Linux

## Installation

`mix deps.get`

## Run

`iex -S mix`


## Make release

### create `rel` folder and the config file:
`mix release.init`

### create prod release:
`MIX_ENV=prod mix release`

### More details:
https://hackernoon.com/mastering-elixir-releases-with-distillery-a-pretty-complete-guide-497546f298bc


## Run tests
`mix test`


## API calls

```
curl 'your_ip_address:8800/get_temperature'

```
