///|
pub(all) enum ParamValue {
  Str(String)
  Int(Int64)
  Bool(Bool)
  Strs(Array[String])
  Ints(Array[Int64])
} derive(Eq, Debug)

///|
/// Ordered parameters permit repeated keys and deterministic tests.
pub(all) struct Params {
  entries : Array[(String, ParamValue)]
} derive(Eq, Debug)

///|
pub fn Params::new() -> Params {
  { entries: [] }
}

///|
pub fn Params::of(entries : Array[(String, ParamValue)]) -> Params {
  { entries, }
}

///|
pub fn Params::put(self : Self, key : String, value : ParamValue) -> Unit {
  self.entries.push((key, value))
}

///|
pub fn Params::put_opt(self : Self, key : String, value : ParamValue?) -> Unit {
  if value is Some(v) {
    self.put(key, v)
  }
}

///|
pub fn Params::put_string(self : Self, key : String, value : String?) -> Unit {
  self.put_opt(key, value.map(v => Str(v)))
}

///|
pub fn Params::put_int(self : Self, key : String, value : Int64?) -> Unit {
  self.put_opt(key, value.map(v => Int(v)))
}

///|
pub fn Params::put_bool(self : Self, key : String, value : Bool?) -> Unit {
  self.put_opt(key, value.map(v => Bool(v)))
}

///|
pub fn Params::put_strings(
  self : Self,
  key : String,
  value : Array[String]?,
) -> Unit {
  self.put_opt(key, value.map(v => Strs(v)))
}

///|
pub fn Params::encode(self : Self) -> String {
  let out = StringBuilder::new()
  let mut first = true
  fn append(key : String, value : String) -> Unit {
    if !first {
      out.write_char('&')
    }
    first = false
    out.write_string(percent_encode(key))
    out.write_char('=')
    out.write_string(percent_encode(value))
  }
  for entry in self.entries {
    let (key, value) = entry
    match value {
      Str(value) => append(key, value)
      Int(value) => append(key, value.to_string())
      Bool(value) => append(key, if value { "true" } else { "false" })
      Strs(values) =>
        for value in values {
          append(key, value)
        }
      Ints(values) =>
        for value in values {
          append(key, value.to_string())
        }
    }
  }
  out.to_string()
}

///|
/// RFC 3986 percent-encoding over UTF-8 bytes.
pub fn percent_encode(text : String) -> String {
  let bytes = @utf8.encode(text)
  let out = StringBuilder::new(size_hint=bytes.length())
  for byte in bytes {
    let value = byte.to_int()
    if is_unreserved(value) {
      out.write_char(value.unsafe_to_char())
    } else {
      out.write_char('%')
      out.write_char(hex_digit(value >> 4))
      out.write_char(hex_digit(value & 0x0f))
    }
  }
  out.to_string()
}

///|
fn is_unreserved(byte : Int) -> Bool {
  (byte >= 'a'.to_int() && byte <= 'z'.to_int()) ||
  (byte >= 'A'.to_int() && byte <= 'Z'.to_int()) ||
  (byte >= '0'.to_int() && byte <= '9'.to_int()) ||
  byte == '-'.to_int() ||
  byte == '.'.to_int() ||
  byte == '_'.to_int() ||
  byte == '~'.to_int()
}

///|
fn hex_digit(value : Int) -> Char {
  if value < 10 {
    ('0'.to_int() + value).unsafe_to_char()
  } else {
    ('A'.to_int() + value - 10).unsafe_to_char()
  }
}
