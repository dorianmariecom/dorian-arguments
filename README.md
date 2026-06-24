# `dorian-arguments`

Small command-line argument parser used by the Dorian tools.

## Install

```bash
gem install dorian-arguments
```

Also included in the aggregate gem:

```bash
gem install dorian
```

## Usage

```bash
arguments -h
```

Run `arguments -h` for generated option details and `arguments -v` for the installed version.

## Notes

- Use `Dorian::Arguments.parse` to split positional arguments, existing file paths, and typed options into one struct.

## Examples

### Parse options in Ruby

```ruby
require "dorian/arguments"

parsed = Dorian::Arguments.parse(count: :integer, verbose: :boolean)
parsed.arguments
parsed.options.count
parsed.files
```
