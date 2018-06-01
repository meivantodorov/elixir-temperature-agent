# Temperature Embedded Agent written in Elixir

## Description
The project provides REST API for getting the current temperature from `DS18B20` sensore. The sensore should be set already.
Retrieve all data from the connected sensores

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


## Examples

### Request

```
curl 'your_ip_address:8800/get_temperature'

```

### Response

```
{"response":{"status":"ok","sensores":[{"timestamp":1527852670715,"status":"ok","sensore_resp":24.4,"sensore_id":"28-000005e06ac0"}],"resp_msg":"ok"}}
```
