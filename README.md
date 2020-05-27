# islands_interface
Front end application for the islands game from book [Functional Web Development with Elixir, OTP, and Phoenix](https://pragprog.com/book/lhelph/functional-web-development-with-elixir-otp-and-phoenix)

* **[Erlang](https://www.erlang.org) instead of Elixir**
* **[N2O](https://github.com/synrc/n2o) + [Nitro](https://github.com/synrc/nitro) instead of Phoenix**

## Setup

Download [Islands Engine](https://github.com/ixmrm01/islands_engine)

Download Islands Interface

```
$ cd islands_interface
$ mkdir _checkouts
$ cd _checkouts
$ ln -s /Users/martin/Documents/islands_engine islands_engine
```

## Build

```
$ cd islands_interface
$ rebar3 shell
```

## Test

http://localhost:8001/app/index.htm

## Learn more

* [Erlang Coding Standards & Guidelines](https://github.com/inaka/erlang_guidelines)
* [Writing Beautiful Code](http://www.gar1t.com/blog/writing-beautiful-code-erlang-factory.html)
* [Adopting Erlang](https://adoptingerlang.org/)
* [Checkout Dependencies](https://adoptingerlang.org/docs/development/dependencies/)
* [Erlang build tool](https://github.com/erlang/rebar3)
* [Erlang Formatter for Rebar3](https://github.com/AdRoll/rebar3_format)
