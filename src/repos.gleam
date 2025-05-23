import effects.{get_repos}
import lustre
import lustre/effect.{type Effect}
import types.{type Model, type Msg, init_model}
import update
import view

pub fn main() {
  let app = lustre.application(init, update.update, view.view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
}

fn init(_) -> #(Model, Effect(Msg)) {
  let model = init_model()
  #(model, get_repos(model.user_name))
}
