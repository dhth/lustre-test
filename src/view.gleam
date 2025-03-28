import gleam/int
import gleam/list
import gleam/option
import gleam/string
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event
import types.{type Model, type Msg, type Repo, Model, Repo, Summary, Table}

const badges_style_qp = "style=for-the-badge"

const badges_url = "https://img.shields.io"

pub fn view(model: Model) -> element.Element(Msg) {
  let debug = case model.debug {
    False -> element.none()
    True -> html.div([], [element.text(string.inspect(model))])
  }

  let heading_text = case model.fetching {
    False -> "github user"
    True -> "github user ..."
  }
  let heading =
    html.div([], [
      html.a(
        [
          attribute.href("https://github.com/dhth/lustre-test"),
          attribute.target("_blank"),
        ],
        [
          html.h1([attribute.class("text-4xl mb-4 text-[#fe8019]")], [
            element.text(heading_text),
          ]),
        ],
      ),
    ])

  let search_form =
    html.div([attribute.class("mb-4")], [
      html.input([
        event.on_input(types.UserEnteredUsernameInput),
        attribute.class("px-4 py-1 mr-2 my-2 text-[#282828]"),
        attribute.placeholder("github username"),
        attribute.value(model.user_name),
      ]),
      html.button(
        [
          event.on_click(types.UserSubmittedRequest),
          attribute.class(
            "font-semibold px-4 py-1 bg-[#d3869b] text-[#282828] disabled:bg-[#928374]",
          ),
          attribute.value(model.user_name),
          attribute.disabled({
            string.is_empty(model.user_name) || model.fetching
          }),
        ],
        [element.text("fetch info")],
      ),
    ])

  let results_type_radio =
    html.div([attribute.class("flex flex-wrap gap-2 mb-10")], [
      html.label([attribute.for("results-summary")], [element.text("summary")]),
      html.input([
        attribute.type_("radio"),
        attribute.id("results-summary"),
        attribute.checked(model.results_type == Summary),
        event.on_click(types.UserChangedResultType(Summary)),
      ]),
      html.label([attribute.for("results-table")], [element.text("table")]),
      html.input([
        attribute.type_("radio"),
        attribute.id("results-table"),
        attribute.checked(model.results_type == Table),
        event.on_click(types.UserChangedResultType(Table)),
      ]),
    ])

  let results = case model.results_type {
    Summary -> repos_summary_div(model.repos)
    Table -> repo_tables_div(model.repos)
  }

  html.div(
    [
      attribute.class(
        "container w-2/3 mx-auto bg-[#282828] text-[#ebdbb2] mt-10 text-lg",
      ),
    ],
    [debug, heading, search_form, results_type_radio, results],
  )
}

fn repos_summary_div(repos: List(Repo)) -> element.Element(Msg) {
  case repos {
    [] -> element.none()
    [_, ..] ->
      html.div([attribute.class("mt-8")], list.map(repos, get_repo_details))
  }
}

fn repo_tables_div(repos: List(Repo)) -> element.Element(Msg) {
  case repos {
    [] -> element.none()
    [_, ..] ->
      html.div([attribute.class("mt-8")], [
        html.table(
          [
            attribute.class(
              "table-auto border-2 border-[#3c3836] w-full text-left",
            ),
            attribute.id("repos-table"),
          ],
          [
            html.tr([attribute.class("text-large border-2 border-[#3c3836]")], [
              html.th([attribute.class("px-4 py-4")], [element.text("Name")]),
              html.th([attribute.class("pr-4 py-4")], [
                element.text("Description"),
              ]),
              html.th([attribute.class("pr-4 py-4")], [element.text("Language")]),
              html.th([attribute.class("pr-4 py-4")], [
                element.text("Stargazers"),
              ]),
            ]),
            ..list.map(repos, fn(repo) {
              html.tr([attribute.class("text-base border-2 border-[#3c3836]")], [
                html.a([attribute.href(repo.url), attribute.target("_blank")], [
                  html.td(
                    [attribute.class("text-[#83a598] font-semibold px-4 py-2")],
                    [element.text(repo.name)],
                  ),
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
}

fn get_repo_details(repo: Repo) -> element.Element(Msg) {
  let description = case repo.description {
    option.None -> element.none()
    option.Some(d) ->
      html.p([attribute.class("mb-4 text-[#d5c4a1] font-sm")], [element.text(d)])
  }

  let badge_urls = [
    languages_count_url(repo.name),
    top_language_url(repo.name),
    stars_url(repo.name),
    license_url(repo.name),
    issues_url(repo.name),
    pulls_url(repo.name),
    num_commits_url(repo.name),
    files_count(repo.name),
    num_commits_url(repo.name),
    last_commit_url(repo.name),
    release_date_url(repo.name),
    commits_since_last_release_url(repo.name),
    all_downloads_url(repo.name),
  ]

  html.div(
    [attribute.class("repo-details mb-12 border-2 border-[#3c3836] py-4 px-4")],
    [
      html.h2([attribute.class("text-xl font-semibold text-[#83a598] mb-2")], [
        html.a([attribute.href(repo.url), attribute.target("_blank")], [
          element.text(repo.name),
        ]),
      ]),
      description,
      html.div(
        [attribute.class("flex flex-wrap gap-2 mb-2")],
        badge_urls
          |> list.map(fn(url) { html.img([attribute.src(url)]) }),
      ),
    ],
  )
}

fn languages_count_url(name: String) -> String {
  badges_url <> "/github/languages/count/" <> name <> "?" <> badges_style_qp
}

fn top_language_url(name: String) -> String {
  badges_url <> "/github/languages/top/" <> name <> "?" <> badges_style_qp
}

fn all_downloads_url(name: String) -> String {
  badges_url <> "/github/downloads/" <> name <> "/total?" <> badges_style_qp
}

fn license_url(name: String) -> String {
  badges_url <> "/github/license/" <> name <> "?" <> badges_style_qp
}

fn stars_url(name: String) -> String {
  badges_url <> "/github/stars/" <> name <> "?" <> badges_style_qp
}

fn issues_url(name: String) -> String {
  badges_url <> "/github/issues/" <> name <> "?" <> badges_style_qp
}

fn pulls_url(name: String) -> String {
  badges_url <> "/github/issues-pr/" <> name <> "?" <> badges_style_qp
}

fn num_commits_url(name: String) -> String {
  badges_url <> "/github/commit-activity/t/" <> name <> "?" <> badges_style_qp
}

fn last_commit_url(name: String) -> String {
  badges_url <> "/github/last-commit/" <> name <> "?" <> badges_style_qp
}

fn release_date_url(name: String) -> String {
  badges_url <> "/github/release-date/" <> name <> "?" <> badges_style_qp
}

fn commits_since_last_release_url(name: String) -> String {
  badges_url
  <> "/github/commits-since/"
  <> name
  <> "/latest?"
  <> badges_style_qp
}

fn files_count(name: String) -> String {
  badges_url
  <> "/github/directory-file-count/"
  <> name
  <> "?"
  <> badges_style_qp
}
