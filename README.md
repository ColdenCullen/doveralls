## doveralls [![Build Status](https://img.shields.io/travis/ColdenCullen/doveralls.svg?style=flat)](https://travis-ci.org/ColdenCullen/doveralls)

Upload D code coverage results to [coveralls.io](https://coveralls.io/).

### Installation

The best way to install doveralls is by fetching it through [dub](http://code.dlang.org).
```
dub fetch doveralls
```

### Usage

To generate coverage information, it is recommended that you run `dub test -b unittest-cov`.

| Argument     | Description                                                       |
|--------------|-------------------------------------------------------------------|
| `d`, `dump`  | Dump the json report to stdout instead of uploading it.           |
| `p`, `path`  | The path of the repo.                                             |
| `t`, `token` | The Coveralls token for the repo, required when running locally.  |
| `travis-pro` | Specify this if you are using Travis pro.                         |

#### Using with Travis-CI

Add this to your script sections.
```yml
install:
  # Install doveralls from the latest github release
  - wget -q -O - "http://bit.ly/Doveralls" | bash
  # Or, if you know what version you want, like v1.1.2, you can simply use this instead:
  - wget -O doveralls "https://github.com/ColdenCullen/doveralls/releases/download/v1.1.5/doveralls_linux_travis"
  - chmod +x doveralls

script:
  - dub test -b unittest-cov
  - ./doveralls
  # or when using Travis Pro
  - ./doveralls -travis-pro
```
#### Using doveralls locally

When running locally you have to pass the repo_token.

```sh
dub test -b unittest-cov
# as command line argument
dub run doveralls -- -t uMKQTqJOiFK3EVELOqxcsduGgMNgHagLF
# as environment variable
COVERALLS_REPO_TOKEN=uMKQTqJOiFK3EVELOqxcsduGgMNgHagLF dub run doveralls
```

It is also possible to specify a different endpoint by setting the
`COVERALLS_ENDPOINT` environment variable.

```sh
COVERALLS_ENDPOINT=http://localhost:8080 dub run coveralls
```
