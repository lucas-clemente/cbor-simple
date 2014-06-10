# CBOR Simple

```ruby
gem 'cbor-simple'
```

A basic but extensible implementation of [CBOR (RFC7049)](http://tools.ietf.org/html/rfc7049) in plain ruby.

Use just like `JSON` or `YAML`:

```ruby
CBOR.dump(42)           # => "\x18\x2a"
CBOR.load("\x18\x2a")   # => 42
```

You can add custom tags like this:

```ruby
CBOR.register_tag 0 do |raw|
  Time.iso8601(raw)
end
```

And add classes for dumping:

```ruby
CBOR.register_class Time, 0 do |val|
  val.iso8601(6)
end
```

Custom tags can also be given as second parameter to `load`, however this should be considered unstable and might change in the future.

```ruby
# Invert values tagged with 0x26 (nonstandard!)
CBOR.load("\xd8\x26\xf5", {0x26 => -> (raw) { !raw }})  # => false
```

Currently supported classes:

- (Unsigned) Integers
- Floats (single and double)
- Byte / Textstring (also symbols)
- Arrays
- Hashes
- BigDecimals
- UUIDs (if the gem `uuidtools` is visible)
- Times
