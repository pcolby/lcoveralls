# Lcoveralls
[![Dependency Status](http://img.shields.io/gemnasium/pcolby/lcoveralls.svg)](https://gemnasium.com/pcolby/lcoveralls)
[![Gem Version](http://img.shields.io/gem/v/lcoveralls.svg)](https://rubygems.org/gems/lcoveralls)
[![Github Release](http://img.shields.io/github/release/pcolby/lcoveralls.svg)](https://github.com/pcolby/lcoveralls/releases/latest)
[![Apache License](http://img.shields.io/badge/license-APACHE2-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0.html)

Lcoveralls is a simple (Ruby) script for reporting code coverage results from
[LCOV](http://ltp.sourceforge.net/coverage/lcov.php) to [Coveralls](https://coveralls.io/).
Instead of invoking `gcov` directly, as some alternative projects do (quite successfully),
Lcoveralls depends on the tracefiles that LCOV generates from g++ / gcov's output.

![Lcoveralls Data Flow](
https://raw.githubusercontent.com/pcolby/lcoveralls/master/doc/diagrams/data-flow.png
"Data flow from source code, through gcc, lcov, and lcoveralls to coveralls.io")

The benefit of using LCOV's tracefiles (aka *.info files) is two-fold:

1. LCOV's inclusion / exclusion logic is well proven, and time tested - no need
   to reinvent that wheel; and
2. If you are already using LCOV to generate HTML output (as I usually do), then
   you only need to define inclusions / exclusions once, instead of having to
   define that information twice (and in two very different formats).

Of course, the disadvantage to depending on LCOV, is the additional dependency -
not an issue for me, but I guess it could be for someone.

## Installation

```
gem install lcoveralls
```

## Usage

1. Build your project with gcov support.
2. Execute your test(s).
3. Execute `lcov` to generate tracefiles (aka *.info files).
4. Execute `lcoveralls` to submit the coverage report(s) to Coveralls.

For example:
```
g++ -fprofile-arcs -ftest-coverage -O0 -o test <source files>
./test
lcov --capture ... && lcov --remove ...
lcoveralls [--token <coveralls repo token>]
```

The token is not necessary when using Travis CI. Run `lcoveralls --help` for
more options.

### Travis CI

To use Lcoveralls within Travis CI, simply install the gem, and then once all of
your tests have passed (including any necessary `lcov` invocations), invoke 
lcoveralls.

For example:

```
install:
  - sudo apt-get install lcov rubygems
  - gem install lcoveralls

...

after_success:
  - lcoveralls
```

Note, if you are using Travis Pro, you should let Lcoveralls know via the
`--service` option, for example:

```
after_success:
  - lcoverals --service travis-pro
```

Some real-word Travis CI examples:

Project | .travis.yml
--------|------------
[libqtaws](https://github.com/pcolby/libqtaws) | [.travis.yml](https://github.com/pcolby/libqtaws/blob/master/.travis.yml)
[pcp-pmda-cpp](https://github.com/pcolby/pcp-pmda-cpp) | [.travis.yml](https://github.com/pcolby/pcp-pmda-cpp/blob/master/.travis.yml)

## License
Apache License 2.0
