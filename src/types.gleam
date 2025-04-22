import gleam/option
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

pub type Theme {
  Light
  Dark
}

pub fn theme_to_string(theme: Theme) -> String {
  case theme {
    Dark -> "🌙"
    Light -> "☀️"
  }
}

pub fn get_next_theme(current: Theme) -> Theme {
  case current {
    Dark -> Light
    Light -> Dark
  }
}

pub type ResultsType {
  Table
  Summary
}

pub type Model {
  Model(
    user_name: String,
    fetching: Bool,
    repos: List(Repo),
    results_type: ResultsType,
    theme: Theme,
    debug: Bool,
  )
}

pub type Msg {
  UserEnteredUsernameInput(String)
  UserSubmittedRequest
  UserChangedResultType(ResultsType)
  ApiReturnedRepos(Result(List(Repo), lustre_http.HttpError))
  ThemeChangeRequested
}

pub fn init_model() -> Model {
  Model(
    user_name: "dhth",
    fetching: True,
    repos: [],
    results_type: Summary,
    theme: Dark,
    debug: False,
  )
}
