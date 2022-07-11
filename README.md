# SRTOOL Github Action

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd">
<td style="text-align: left;"><p><img src="https://github.com/chevdor/srtool-actions/actions/workflows/cumulus.yml/badge.svg?branch=master" alt="badge" /></p></td>
<td style="text-align: left;"><p><img src="https://github.com/chevdor/srtool-actions/actions/workflows/polkadot.yml/badge.svg?branch=master" alt="badge" /></p></td>
</tr>
</tbody>
</table>

## Introduction

[srtool](https://github.com/chevdor/srtool) is a docker image that allows building Substrate WASM Runtimes in a deterministic manner. It ensures that all `srtool` users (and tooling), using the same/latest tag, will produce 100% exactly the same runtime. It enables further trustless verifications.

![srtool gh action 512px](resources/logo/srtool-gh-action_512px.png)

This repository contains a custom [Github Action](https://docs.github.com/en/actions) that will help you integrate `srtool` in your Github CI.

Gitlab users are not left behind and can use the 2 first options mentioned below.

## Srtool helpers

There are now several ways to use `srtool` in your project:

-   using `srtool` [via alias](https://github.com/chevdor/srtool#user-content-using-an-alias): powerful but very verbose and prone to errors. This is for developers. This option is being deprecated and not recommended.

-   using the [srtool-cli](https://github.com/chevdor/srtool-cli): much easier to use and removes a whole bunch of potential user’s mistakes. This is for developers.

-   using the [srtool-app](https://github.com/chevdor/srtool-app): the easiest option of all thanks to its GUI. This is good for non-developers.

-   using the Github actions from [this repo](https://github.com/chevdor/srtool-actions). This is for your automatic CI.

## Requirements

In order to use this Github Action, you will need a Github repository with your Substrate based project. You can learn how to get started with a first Github workflow [here](https://docs.github.com/en/actions/quickstart).

Before you setup your new workflow, you should gather the following information:

-   name of your chain: ie. polkadot

-   runtime package: ie. runtime-polkadot

-   location of your runtime: ie. runtime/polkadot

If your project uses standard values (such as your runtime package being named `xyz-runtime` if your chain is `xyz`), you will be able to skip many of the inputs. If you have a different setup, you can override the defaults to make it work for you.

## Sample workflows

Make sure you store the yml files shown below in your repository under `.github/workflows`.

## basic

**basic.yml**

    name: Srtool build

    on: push

    jobs:
      srtool:
        runs-on: ubuntu-latest
        strategy:
          matrix:
            chain: ["statemine", "westmint"]
        steps:
          - uses: actions/checkout@v3
          - name: Srtool build
            id: srtool_build
            uses: chevdor/srtool-actions@v0.5.0
            with:
              chain: ${{ matrix.chain }}
              runtime_dir: polkadot-parachains/${{ matrix.chain }}-runtime
          - name: Summary
            run: |
              echo '${{ steps.srtool_build.outputs.json }}' | jq . > ${{ matrix.chain }}-srtool-digest.json
              cat ${{ matrix.chain }}-srtool-digest.json
              echo "Runtime location: ${{ steps.srtool_build.outputs.wasm }}"

## Report

    name: Srtool build

    on: push

    jobs:
      srtool:
        runs-on: ubuntu-latest
        strategy:
          matrix:
            chain: ["westend"]
        steps:
          - uses: actions/checkout@v3
          - name: Srtool build
            id: srtool_build
            uses: chevdor/srtool-actions@v0.5.0
            with:
              chain: ${{ matrix.chain }}
          - name: Summary
            run: |
              echo Summary:
              echo - version: ${{ steps.srtool_build.outputs.version }}
              echo - info: ${{ steps.srtool_build.outputs.info }}
              echo - prop: ${{ steps.srtool_build.outputs.proposal_hash }}
              echo - json: ${{ steps.srtool_build.outputs.json }}

## Artifacts

    name: Srtool build

    on: push

    jobs:
      srtool:
        runs-on: ubuntu-latest
        strategy:
          matrix:
            chain: ["statemine", "westmint"]
        steps:
          - uses: actions/checkout@v3
          - name: Srtool build
            id: srtool_build
            uses: chevdor/srtool-actions@v0.5.0
            with:
              chain: ${{ matrix.chain }}
              runtime_dir: polkadot-parachains/${{ matrix.chain }}-runtime
          - name: Summary
            run: |
              echo '${{ steps.srtool_build.outputs.json }}' | jq . > ${{ matrix.chain }}-srtool-digest.json
              cat ${{ matrix.chain }}-srtool-digest.json
              echo "Runtime location: ${{ steps.srtool_build.outputs.wasm }}"
          - name: Archive Runtime
            uses: actions/upload-artifact@v2
            with:
              name: ${{ matrix.chain }}-runtime-${{ github.sha }}
              path: |
                ${{ steps.srtool_build.outputs.wasm }}
                ${{ matrix.chain }}-srtool-digest.json

## Environmental variables and BUILD\_OPTS

    name: Srtool build

    on: push

    jobs:
      srtool:
        runs-on: ubuntu-latest
        strategy:
          matrix:
            chain: ["statemine", "westmint"]
        steps:
          - uses: actions/checkout@v3
          - name: Srtool build
            id: srtool_build
            uses: chevdor/srtool-actions@v0.5.0
            env:
              # optional: will be passed to docker srtool run cmd
              BUILD_OPTS: "--features on-chain-release-build"
            with:
              chain: ${{ matrix.chain }}
              runtime_dir: polkadot-parachains/${{ matrix.chain }}-runtime
          - name: Summary
            run: |
              echo '${{ steps.srtool_build.outputs.json }}' | jq . > ${{ matrix.chain }}-srtool-digest.json
              cat ${{ matrix.chain }}-srtool-digest.json
              echo "Runtime location: ${{ steps.srtool_build.outputs.wasm }}"

## Environmental variables and parachain overrides

    name: Srtool build

    on: push

    jobs:
      srtool:
        runs-on: ubuntu-latest
        strategy:
          matrix:
            chain: ["statemine", "westmint"]
        steps:
          - uses: actions/checkout@v3
          - name: Srtool build
            id: srtool_build
            uses: chevdor/srtool-actions@v0.5.0
            env:
              # optional: will override the parachain pallet ID and authorize_upgrade call ID,
              #           which will result in a different parachain_authorize_upgrade_hash
              # the hex values must be quoted
              PARACHAIN_PALLET_ID: "0x1e"
              AUTHORIZE_UPGRADE_PREFIX: "0x02"
            with:
              chain: ${{ matrix.chain }}
              runtime_dir: polkadot-parachains/${{ matrix.chain }}-runtime
          - name: Summary
            run: |
              echo '${{ steps.srtool_build.outputs.json }}' | jq . > ${{ matrix.chain }}-srtool-digest.json
              cat ${{ matrix.chain }}-srtool-digest.json
              echo "Runtime location: ${{ steps.srtool_build.outputs.wasm }}"

## Parachain overrides

Similar to [subwasm](https://github.com/chevdor/subwasm), the parachain pallet ID and the `authorize_upgrade` call ID can be overriden by `PARACHAIN_PALLET_ID` and `AUTHORIZE_UPGRADE_PREFIX` environmental variables, respectively. It will affect the generated proposal hash `parachain_authorize_upgrade_hash`.

If unset, the two envs will have the following default values:

-   `PARACHAIN_PALLET_ID`: `0x01`

-   `AUTHORIZE_UPGRADE_PREFIX`: `0x03`

## Contributing

This project is using `asciidoc` for its documentation. You should **not** edit any mardown file (`.md`) as your changes would be dismissed.

Instead you should be editing the `.adoc` file and the markdown files will be generated. If you create a PR and do not have any of the required tooling, feel free to only edit the `.adoc.` files and I will generate the new `.md`.

## Dev notes

### Tooling: `act`

Due to a [bug in act](https://github.com/nektos/act/issues/655), the defaults defined in the action are not applied. That means **must** pass all the inputs while testing with `act`.

You can test locally using [act](https://github.com/nektos/act):

    act -W tests

To make it easier, you can also use `just`:

    just test <test_name>

For instance:

    # Run the default dev workflow: tests/dev.yml
    just test

    # Run the ipfs test workflow
    just test ipfs
