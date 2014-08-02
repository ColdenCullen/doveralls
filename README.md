## doveralls

Upload D code coverage results to [coveralls.io](https://coveralls.io/).

### Usage

To use this, it is recommended that you run `dub test --coverage` (currently only present in `HEAD`)
to generate coverage information.

| Argument     | Description                                                       |
|--------------|-------------------------------------------------------------------|
| `p`, `path`  | The path of the repo.                                             |
| `t`, `token` | The Coveralls token for the repo. Specifiy when not using Travis. |
| `j`, `job`   | The Travis job for the commit.                                    |
| `travis-pro` | [Requires `j`, `job`] Specify this if you are using Travis pro.      |

#### Using with Travis-CI

```
dub run doveralls -- -p `pwd` -j $TRAVIS_JOB_ID [-travis-pro]
```
#### Using doveralls locally

```
dub run doveralls -- -p `pwd` -t MY_TOKEN
```
