DEV_IMAGE := "nightly-2021-02-25-dev"

# List available commands
default:
  @just --list --unsorted

test file="dev":
    act -b --insecure-secrets --env-file .env -W tests/{{file}}.yml

graph file="dev":
    act -W tests/{{file}}.yml -g

clean:
  rm -rf polkadot workflow _actions
