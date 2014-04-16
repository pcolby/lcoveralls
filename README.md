# Lcoveralls

Lcoveralls is a simple (Ruby) script for reporting code coverage results from
[LCOV](http://ltp.sourceforge.net/coverage/lcov.php) to [Coveralls](https://coveralls.io/).
Instead of invoking `gcov` directly, as some alternative projects do (quite successfully),
Loveralls depends on the tracefiles that LCOV generates from g++ / gcov's output.

<diagram to go here>

The benefit of using LCOV's tracefiles is two-fold:

1. LCOV's inclusion / exclusion logic is well proven, and time tested - no need
   to reinvent that wheel; and
2. If you are already using LCOV to generate HTML output (as I usually do), then
   you only need to define inclusions / exclusions once, instead of having to
   define that information twice (and in two very different formats).

Of course, the disadvantage to depending on LCOV, is the additional dependency -
not an issue for me, but I guess it could be for someone.

## Installation

@todo

## Usage

1. Build your project with gcov support.
2. Execute your test(s).
3. Execute `lcov` to generate tracefiles (ake *.info files).
4. Execute `lcoveralls` to submit the coverage report(s) to Coveralls.

For example:
```
g++ -fprofile-arcs -ftest-coverage -O0 -o test <source files>
./test
lcov --capture ... && lcov --remove ...
lcoveralls
```

Be sure to run `lcoveralls --help` for options.

### Travis CI
@todo

## License
Apache License 2.0