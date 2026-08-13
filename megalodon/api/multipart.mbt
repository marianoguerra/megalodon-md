///|
pub(all) struct MultipartBody {
  content_type : String
  body : Bytes
} derive(Eq, Debug)

///|
/// Build a deterministic multipart/form-data body without filesystem or clock
/// access, keeping media upload available on every target.
pub fn multipart_file(
  boundary : String,
  field_name : String,
  file_name : String,
  mime_type : String,
  bytes : Bytes,
  fields? : Array[(String, String)] = [],
) -> MultipartBody raise MegalodonError {
  if boundary == "" || boundary.contains("\r") || boundary.contains("\n") {
    raise InvalidRequest("invalid multipart boundary")
  }
  let out = @buffer.Buffer()
  for entry in fields {
    let (name, value) = entry
    out.write_string_utf8("--\{boundary}\r\n")
    out.write_string_utf8(
      "Content-Disposition: form-data; name=\"\{name}\"\r\n\r\n",
    )
    out.write_string_utf8(value)
    out.write_string_utf8("\r\n")
  }
  out.write_string_utf8("--\{boundary}\r\n")
  out.write_string_utf8(
    "Content-Disposition: form-data; name=\"\{field_name}\"; filename=\"\{file_name}\"\r\n",
  )
  out.write_string_utf8("Content-Type: \{mime_type}\r\n\r\n")
  out.write_bytes(bytes[:])
  out.write_string_utf8("\r\n--\{boundary}--\r\n")
  {
    content_type: "multipart/form-data; boundary=\{boundary}",
    body: out.to_bytes(),
  }
}
