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
    debug: Bool,
  )
}

pub type Msg {
  UserEnteredUsernameInput(String)
  UserSubmittedRequest
  UserChangedResultType(ResultsType)
  ApiReturnedRepos(Result(List(Repo), lustre_http.HttpError))
}
