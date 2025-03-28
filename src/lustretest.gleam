import gleam/dynamic/decode
import gleam/int
import gleam/list
import gleam/option
import gleam/string
import lustre
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import lustre_http

pub type Repo {
  Repo(
    id: Int,
    name: String,
    url: String,
    description: option.Option(String),
    language: option.Option(String),
    stargazers_count: Int,
  )
}

pub type Model {
  Model(user_name: String, fetching: Bool, repos: List(Repo), debug: Bool)
}

pub type Msg {
  UserEnteredUsernameInput(String)
  UserSubmittedRequest
  ApiReturnedRepos(Result(List(Repo), lustre_http.HttpError))
}

fn init(_) -> #(Model, effect.Effect(Msg)) {
  #(
    Model(user_name: "dhth", fetching: True, repos: [], debug: False),
    get_repos("dhth"),
  )
}

fn get_repos(user_name: String) -> effect.Effect(Msg) {
  let decoder = {
    use id <- decode.field("id", decode.int)
    use name <- decode.field("name", decode.string)
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

  let expect = lustre_http.expect_json(decode.list(decoder), ApiReturnedRepos)

  lustre_http.get(
    "https://api.github.com/users/"
      <> user_name
      <> "/repos?sort=updated&direction=desc&per_page=50",
    expect,
  )
}

pub fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(Msg)) {
  case msg {
    UserEnteredUsernameInput(user_name) -> {
      #(Model(..model, user_name:), effect.none())
    }
    UserSubmittedRequest ->
      case model.fetching {
        True -> #(model, effect.none())
        False -> #(Model(..model, fetching: True), get_repos(model.user_name))
      }
    ApiReturnedRepos(Ok(repos)) -> #(
      Model(..model, fetching: False, repos:),
      effect.none(),
    )
    ApiReturnedRepos(Error(_)) -> #(
      Model(..model, fetching: False),
      effect.none(),
    )
  }
}

pub fn view(model: Model) -> element.Element(Msg) {
  let debug = case model.debug {
    False -> element.none()
    True -> html.div([], [element.text(string.inspect(model))])
  }

  let heading_text = case model.fetching {
    False -> "lustre test"
    True -> "lustre test ..."
  }
  let heading =
    html.div([], [
      html.a(
        [
          attribute.href("https://github.com/dhth/lustre-test"),
          attribute.target("_blank"),
        ],
        [
          html.h1([attribute.class("text-4xl mb-2 text-[#fe8019]")], [
            element.text(heading_text),
          ]),
        ],
      ),
    ])

  let search_form =
    html.div([], [
      html.input([
        event.on_input(UserEnteredUsernameInput),
        attribute.class("px-4 py-1 mr-2 my-2 text-[#282828]"),
        attribute.placeholder("github username"),
        attribute.value(model.user_name),
      ]),
      html.button(
        [
          event.on_click(UserSubmittedRequest),
          attribute.class(
            "font-semibold px-4 py-1 bg-[#d3869b] text-[#282828] disabled:bg-[#928374]",
          ),
          attribute.value(model.user_name),
          attribute.disabled({
            string.is_empty(model.user_name) || model.fetching
          }),
        ],
        [element.text("fetch repos")],
      ),
    ])

  let results = case model.repos {
    [] -> element.none()
    [_, ..] ->
      html.div([attribute.class("mt-8")], [
        html.table(
          [attribute.class("table-auto px-4 py-2"), attribute.id("repos-table")],
          [
            html.tr([attribute.class("text-large")], [
              html.td([], [element.text("Name")]),
              html.td([], [element.text("Description")]),
              html.td([], [element.text("Language")]),
              html.td([], [element.text("Stargazers")]),
            ]),
            ..list.map(model.repos, fn(repo) {
              html.tr([attribute.class("text-base")], [
                html.a([attribute.href(repo.url), attribute.target("_blank")], [
                  html.td([attribute.class("text-[#83a598] font-semibold")], [
                    element.text(repo.name),
                  ]),
                ]),
                html.td([], [element.text(option.unwrap(repo.description, ""))]),
                html.td([], [element.text(option.unwrap(repo.language, ""))]),
                html.td([], [element.text(int.to_string(repo.stargazers_count))]),
              ])
            })
          ],
        ),
      ])
  }

  html.div(
    [
      attribute.class(
        "container w-2/3 mx-auto bg-[#282828] text-[#ebdbb2] mt-10 text-lg",
      ),
    ],
    [debug, heading, search_form, results],
  )
}

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
