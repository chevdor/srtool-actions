# List available commands
default:
  @just --list --unsorted

test file="dev":
  act -b --insecure-secrets --env-file .env -W tests/{{file}}.yml

graph file="dev":
  act -W tests/{{file}}.yml -g

clean:
  rm -rf polkadot workflow _actions

# Generate the readme as .md
md:
  #!/usr/bin/env bash
  asciidoctor -b docbook -a leveloffset=+1 -o - README_src.adoc | pandoc   --markdown-headings=atx --wrap=preserve -t markdown_strict -f docbook - > README.md

tag:
  #!/usr/bin/env bash
  latest=$(git tag | sort -Vr | head -n1)
  version=$(echo $latest |sed -E 's/v//g')
  bumped=$(semver-cli $version --increment minor)
  echo "Tagging v$bumped ..."
  git tag "v$bumped"
  git tag | sort -Vr | head -n10

tag_push:
  #!/usr/bin/env bash
  latest=$(git tag | sort -Vr | head -n1)
  git push origin $latest
