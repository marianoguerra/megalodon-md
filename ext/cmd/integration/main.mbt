///|
fn[T] require_nonempty(name : String, values : Array[T]) -> Unit raise {
  if values.is_empty() {
    raise Failure("\{name} returned an empty collection")
  }
  println("PASS \{name}: \{values.length()} items")
}

///|
fn report_optional(name : String, result : Result[Int, Error]) -> Unit {
  match result {
    Ok(count) => println("PASS \{name}: \{count} items")
    Err(error) => println("SKIP \{name}: \{error}")
  }
}

///|
async fn main {
  let args = @env.args()
  let base_url = if args.length() > 1 {
    args[1]
  } else {
    "https://mastodon.social"
  }
  println("megalodon live read-only integration: \{base_url}")
  let transport : &@api.Transport = @transport.HttpTransport::new(
    description=base_url,
  )
  let software = @detector.detect(transport, base_url)
  println("PASS detector: \{software.to_string()}")
  let access_token = @env.get_env_var("MEGALODON_ACCESS_TOKEN")
  let client = @client.Client::new(transport, software, base_url, access_token?)
  // Detection already fetched and decoded the v2 instance endpoint. Do not
  // immediately duplicate the same live request; public servers may throttle
  // identical anonymous probes more aggressively than normal navigation.
  println("PASS instance metadata (via detector)")

  let peers_result : Result[Int, Error] = Ok(
    client.get_instance_peers().data.length(),
  ) catch {
    error => Err(error)
  }
  report_optional("instance peers (large-response stress probe)", peers_result)

  let public_timeline = Some(client.get_public_timeline(limit=5)) catch {
    error => {
      println("SKIP public timeline and dependent lookups: \{error}")
      if access_token is None {
        println(
          "INFO set MEGALODON_ACCESS_TOKEN for servers that require authenticated public API reads",
        )
      }
      None
    }
  }
  match public_timeline {
    Some(response) => {
      require_nonempty("public timeline", response.data)
      let first_status = response.data[0]
      let fetched_status = client.get_status(first_status.id)
      assert_eq(fetched_status.data.id, first_status.id)
      println("PASS status lookup: \{first_status.id}")
      let account = client.get_account(first_status.account.id)
      assert_eq(account.data.id, first_status.account.id)
      println("PASS account lookup: \{account.data.acct}")
      let account_statuses = client.get_account_statuses(
        first_status.account.id,
        limit=3,
      )
      require_nonempty("account statuses", account_statuses.data)
      let context_result : Result[Int, Error] = Ok(
        client.get_status_context(first_status.id).status,
      ) catch {
        error => Err(error)
      }
      report_optional("status context", context_result)
    }
    None => ()
  }

  let local_result : Result[Int, Error] = Ok(
    client.get_local_timeline(limit=5).data.length(),
  ) catch {
    error => Err(error)
  }
  report_optional("local timeline", local_result)

  let tag_result : Result[Int, Error] = Ok(
    client.get_tag_timeline("mastodon", limit=5).data.length(),
  ) catch {
    error => Err(error)
  }
  report_optional("tag timeline", tag_result)

  let trends_result : Result[Int, Error] = Ok(
    client.get_instance_trends(limit=5).data.length(),
  ) catch {
    error => Err(error)
  }
  report_optional("trends", trends_result)

  let directory_result : Result[Int, Error] = Ok(
    client.get_instance_directory(
      limit=5,
      order=@client.Active,
      local_only=true,
    ).data.length(),
  ) catch {
    error => Err(error)
  }
  report_optional("directory", directory_result)

  let emojis_result : Result[Int, Error] = Ok(
    client.get_instance_custom_emojis().data.length(),
  ) catch {
    error => Err(error)
  }
  report_optional("custom emojis", emojis_result)

  let announcements_result : Result[Int, Error] = Ok(
    client.get_instance_announcements().data.length(),
  ) catch {
    error => Err(error)
  }
  report_optional("announcements", announcements_result)

  let activity_result : Result[Int, Error] = Ok(
    client.get_instance_activity().data.length(),
  ) catch {
    error => Err(error)
  }
  report_optional("legacy instance activity", activity_result)
  println("live read-only integration completed")
}
