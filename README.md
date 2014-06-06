# CBOR Simple

```ruby
gem 'cbor-simple'
```

A basic but extensible implementation of [CBOR (RFC7049)](http://tools.ietf.org/html/rfc7049) in plain ruby.

Use just like `JSON` or `YAML`:

```ruby
CBOR.dump(42)         # => "\x18\x2a"
CBOR.load("\x18\x2a") # => 42
```

You can add custom tags like this:

```ruby
CBOR.register_tag 0 do
  Time.iso8601(read())
end
```

And add classes for dumping:

```ruby
CBOR.register_class Time, 0 do |obj|
  send(obj.iso8601(6))
end
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
