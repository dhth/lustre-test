import gleam/int
import gleam/list
import gleam/option
import gleam/string
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event
import types.{type Model, type Msg, type Repo, type Theme, Summary, Table}

const badges_style_qp = "style=for-the-badge"

const badges_url = "https://img.shields.io"

const heading_text_class_light = "text-[#000000]"

const heading_text_class_dark = "text-[#fe8019]"

pub fn view(model: Model) -> element.Element(Msg) {
  html.div(
    [
      attribute.class(
        "min-h-screen text-lg " <> model.theme |> bg_and_text_class,
      ),
    ],
    [
      html.div([attribute.class("container w-2/3 max-sm:w-4/5 py-10 mx-auto")], [
        model |> debug_section,
        heading(model.fetching, model.theme),
        model |> search_form,
        model |> controls_section,
        model |> results_section,
      ]),
    ],
  )
}

fn bg_and_text_class(theme: Theme) -> String {
  case theme {
    types.Dark -> "bg-[#282828] text-[#ebdbb2]"
    types.Light -> "bg-[#ffffff] text-[#242225]"
  }
}

fn debug_section(model: Model) -> element.Element(Msg) {
  case model.debug {
    False -> element.none()
    True -> html.div([], [element.text(string.inspect(model))])
  }
}

fn heading(fetching: Bool, theme: Theme) -> element.Element(Msg) {
  let heading_text = case fetching {
    False -> "repos"
    True -> "repos ..."
  }

  let heading_class = case theme {
    types.Dark -> heading_text_class_dark
    types.Light -> heading_text_class_light
  }

  html.div([], [
    html.a(
      [
        attribute.href("https://github.com/dhth/lustre-test"),
        attribute.target("_blank"),
      ],
      [
        html.h1(
          [attribute.class("text-4xl mb-4 font-semibold " <> heading_class)],
          [element.text(heading_text)],
        ),
      ],
    ),
  ])
}

fn search_form(model: Model) -> element.Element(Msg) {
  let input_class = case model.theme {
    types.Dark -> "bg-[#b8bb26] text-[#282828]"
    types.Light -> "bg-[#fabd2f] text-[#282828]"
  }

  let button_class = case model.theme {
    types.Dark -> "bg-[#d3869b]"
    types.Light -> "bg-[#8ec07c]"
  }

  html.div([attribute.class("mb-4")], [
    html.input([
      event.on_input(types.UserEnteredUsernameInput),
      attribute.class(
        "px-4 py-1 mr-2 my-2 font-semibold placeholder-[#686868] "
        <> input_class,
      ),
      attribute.placeholder("github username"),
      attribute.value(model.user_name),
    ]),
    html.button(
      [
        event.on_click(types.UserSubmittedRequest),
        attribute.class(
          "font-semibold px-4 py-1 text-[#282828] disabled:bg-[#a89984] "
          <> button_class,
        ),
        attribute.value(model.user_name),
        attribute.disabled({
          string.is_empty(model.user_name |> string.trim) || model.fetching
        }),
      ],
      [element.text("fetch info")],
    ),
  ])
}

fn controls_section(model: Model) -> element.Element(Msg) {
  html.div([attribute.class("flex flex-wrap gap-4 items-center")], [
    html.div([attribute.class("flex flex-wrap gap-2 items-center")], [
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
    ]),
    html.button(
      [event.on_click(types.ThemeChangeRequested), attribute.class("px-2 py-1")],
      [
        element.text(
          model.theme |> types.get_next_theme |> types.theme_to_string,
        ),
      ],
    ),
  ])
}

fn results_section(model: Model) -> element.Element(Msg) {
  case model.results_type {
    Summary -> repos_summary_div(model.repos, model.theme)
    Table -> repo_tables_div(model.repos, model.theme)
  }
}

fn repos_summary_div(repos: List(Repo), theme: Theme) -> element.Element(Msg) {
  case repos {
    [] -> element.none()
    [_, ..] ->
      html.div(
        [attribute.class("mt-8")],
        repos |> list.map(fn(repo) { repo_details(repo, theme) }),
      )
  }
}

fn repo_tables_div(repos: List(Repo), theme: Theme) -> element.Element(Msg) {
  let border_class = theme |> border_class

  case repos {
    [] -> element.none()
    [_, ..] ->
      html.div([attribute.class("mt-8 overflow-x-auto ")], [
        html.table(
          [
            attribute.class(
              "table-auto border w-full text-left " <> border_class,
            ),
            attribute.id("repos-table"),
          ],
          [
            html.tr([attribute.class("text-large border " <> border_class)], [
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
              html.tr([attribute.class("text-base border " <> border_class)], [
                html.a([attribute.href(repo.url), attribute.target("_blank")], [
                  html.td(
                    [
                      attribute.class(
                        "font-semibold px-4 py-2 " <> theme |> repo_name_class,
                      ),
                    ],
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

fn repo_details(repo: Repo, theme: Theme) -> element.Element(Msg) {
  let description = case repo.description {
    option.None -> element.none()
    option.Some(d) ->
      html.p([attribute.class("mb-4 font-sm")], [element.text(d)])
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
    [
      attribute.class(
        "repo-details mb-12 border py-4 px-4 " <> theme |> border_class,
      ),
    ],
    [
      html.h2(
        [
          attribute.class(
            "text-xl font-semibold mb-2 " <> theme |> repo_name_class,
          ),
        ],
        [
          html.a([attribute.href(repo.url), attribute.target("_blank")], [
            element.text(repo.name),
          ]),
        ],
      ),
      description,
      html.div(
        [attribute.class("flex flex-wrap gap-2 mb-2 ease-in")],
        badge_urls
          |> list.map(fn(url) { html.img([attribute.src(url)]) }),
      ),
    ],
  )
}

fn border_class(theme: Theme) -> String {
  case theme {
    types.Dark -> "border-[#3c3836]"
    types.Light -> "border-[#83a598]"
  }
}

fn repo_name_class(theme: Theme) -> String {
  case theme {
    types.Dark -> "text-[#83a598]"
    types.Light -> "text-[#458588]"
  }
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
