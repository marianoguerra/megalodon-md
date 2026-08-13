///|
test "non-GET endpoint verbs match the Mastodon REST contract" {
  assert_eq(@client.UpdateCredentials.http_method(), @api.Patch)
  assert_eq(@client.EditStatus("1").http_method(), @api.Put)
  assert_eq(@client.DeleteStatus("1").http_method(), @api.Delete)
  assert_eq(@client.DismissInstanceAnnouncement("1").http_method(), @api.Post)
}

///|
test "path parameters that are not opaque ids are percent encoded" {
  assert_eq(@client.GetInstance.path(), "/api/v2/instance")
  assert_eq(
    @client.GetTagTimeline("moon bit").path(),
    "/api/v1/timelines/tag/moon%20bit",
  )
  assert_eq(
    @client.AddReactionToAnnouncement(id="1", name="party:blobcat").path(),
    "/api/v1/announcements/1/reactions/party%3Ablobcat",
  )
}
