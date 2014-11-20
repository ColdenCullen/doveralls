## doveralls

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
| `p`, `path`  | The path of the repo.                                             |
| `t`, `token` | The Coveralls token for the repo, required when running locally.  |
| `travis-pro` | Specify this if you are using Travis pro.                         |

#### Using with Travis-CI

Add this to your script sections.
```yml
install:
  # ...install dub
  - dub fetch doveralls

script:
  - dub test -b unittest-cov
  - dub run doveralls
  # or when using Travis Pro
  - dub run doveralls -- -travis-pro
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
