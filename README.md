# motd-forge

Generate a randomized login banner (MOTD) for your servers: a title (rendered
big via `figlet` if it's installed, plain text otherwise), current uptime,
disk and memory usage, and a random quote.

## Installation

    $ gem install motd_forge

Or from source:

    $ bundle install
    $ rake install

## Usage

    $ motd-forge
    $ motd-forge --name mybox
    $ motd-forge --quote-file ~/.motd-quotes.txt
    $ motd-forge --no-quote

Run `motd-forge --help` for the full list of options.

### Config file

Settings can also live in `~/.motd-forge.yml` (or a path passed via `--config`):

    title: mybox
    quote_file: ~/.motd-quotes.txt

CLI flags take precedence over the config file.

### Wiring it into a login banner

Add a call to `motd-forge` from `/etc/profile.d/motd-forge.sh` (or your
shell's rc file) so it prints on every SSH login:

    #!/bin/sh
    motd-forge

## Development

    $ bundle install
    $ rake spec        # run the test suite
    $ bin/console       # interactive prompt

## License

MIT
