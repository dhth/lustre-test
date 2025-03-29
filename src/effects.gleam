import gleam/dynamic/decode
import lustre/effect
import lustre_http
import types.{type Model, type Msg, Model, Repo}

pub fn init(_) -> #(Model, effect.Effect(Msg)) {
  #(
    Model(
      user_name: "dhth",
      fetching: True,
      repos: [],
      results_type: types.Summary,
      debug: False,
    ),
    get_repos("dhth"),
  )
}

pub fn get_repos(user_name: String) -> effect.Effect(Msg) {
  let decoder = {
    use id <- decode.field("id", decode.int)
    use name <- decode.field("full_name", decode.string)
    use url <- decode.field("html_url", decode.string)
    use description <- decode.field(
      "description",
      decode.optional(decode.string),
    )
    use stargazers_count <- decode.field("stargazers_count", decode.int)
    use language <- decode.field("language", decode.optional(decode.string))
    decode.success(Repo(
      id:,
      name:,
      url:,
      description:,
      language:,
      stargazers_count:,
    ))
  }

  let expect =
    lustre_http.expect_json(decode.list(decoder), types.ApiReturnedRepos)

  lustre_http.get(
    "https://api.github.com/users/"
      <> user_name
      <> "/repos?sort=updated&direction=desc&per_page=50&type=all",
    expect,
  )
}
