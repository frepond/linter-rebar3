# linter-rebar3

A bare minimun erlang linter based on rebar3.

This linter plugin for [Linter][linter] provides an interface to rebar3.
It will be used with files that have the "source.erlang" syntax
(ie. `*.erl`). It's based on linter-elixirc.

## Installation

Plugin requires Linter package and it should install it by itself.
If it did not, please follow Linter instructions [here][linter].

### Method 1: In console

```ShellSession
$ apm install linter-rebar3
```

### Method 2: In Atom

1.  Edit > Preferences (Ctrl+,)
2.  Install > Search "linter-rebar3" > Install

## Settings

Plugin should work with default settings. If not:

1.  Edit > Preferences (Ctrl+,)

2.  Packages > Search "linter-rebar3" > Settings

3.  Rebar3 path - use `which rebar3` to find path. ie.
    `/usr/local/bin/rebar3`

## Usage

If you open folder with rebar3 project (`rebar.config` exists in project's root
folder), linter will use `rebar3 compile` to include all dependencies.

Note that this **only** works with rebar3 projects. It should work without
problems either with single "apps" or "rels" structure.  


[linter]: https://github.com/AtomLinter/Linter "Linter"
