import effects
import lustre/effect
import types.{type Model, type Msg, Model}

pub fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(Msg)) {
  case msg {
    types.UserEnteredUsernameInput(user_name) -> {
      #(Model(..model, user_name:), effect.none())
    }
    types.UserSubmittedRequest ->
      case model.fetching {
        True -> #(model, effect.none())
        False -> #(
          Model(..model, fetching: True),
          effects.get_repos(model.user_name),
        )
      }
    types.UserChangedResultType(results_type) -> #(
      Model(..model, results_type:),
      effect.none(),
    )
    types.ApiReturnedRepos(Ok(repos)) -> #(
      Model(..model, fetching: False, repos:),
      effect.none(),
    )
    types.ApiReturnedRepos(Error(_)) -> #(
      Model(..model, fetching: False),
      effect.none(),
    )
  }
}
