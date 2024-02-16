open Base
open Core
open Core.Option
open Base.List
open Gym

module TreeCrawlerEnv : sig
  type t

  val create_env : string list -> CrawlerSys.t -> int -> int array -> t
  val step : t -> int -> Webpage.t * float * bool * unit
  val reset : t -> Webpage.t list
  val create_initial_state_actions : t -> string list -> (Webpage.t * int) list
end = struct
  type t = {
    total_time_steps : int;
    mutable current_step : int;
    action_space : int space;
    obs_shape : int array;
    seed_urls : string list;
    crawling_history_ids : (int, Webpage.t) Hashtbl.t;
    tree_frontier : TreeFrontier.t;
    closure : Closure.t;
    fetch_history : (string, Webpage.t list) Hashtbl.t;
    max_domain_pages : int;
  }

  let create_env seed_urls crawler_sys total_time_steps obs_shape =
    {
      total_time_steps;
      current_step = 0;
      action_space = Box.create ~low:0 ~high:Float.infinity ();
      obs_shape;
      seed_urls;
      crawling_history_ids = Hashtbl.create (module Int);
      tree_frontier = TreeFrontier.create ();
      closure = Closure.create ();
      fetch_history = Hashtbl.create (module String);
      max_domain_pages = max_domain_pages;
    }

  let step env action =
    if env.current_step = env.total_time_steps then
      None, None, true, ()
    else
      env.current_step <- env.current_step + 1;
      try
        env.state_title <- None;
        env.state_body <- None;
        env.state_webpage <- None;
        env.state <- take_action env action;
        let reward = get_reward env in
        env.state_webpage |> Option.iter ~f:(fun w -> Webpage.set_relevance w ~relevance:reward);
        let t3 = Time.now () in
        let () =
          List.iter env.crawler_sys.false_messages ~f:(fun message ->
              try
                if Re2.(matches (create_exn message) env.state_body ~pos:0 ~len:100) then (
                  env.current_step <- env.current_step - 1;
                  raise (Exit false)
                )
              with
              | _ -> ()
            )
        in
        let t4 = Time.now () in
        env.state_webpage, reward, false, ()
      with
      | Exit false -> None, None, false, ()
      | _ -> env.state_webpage <- None; None, None, false, ()

  and reset env =
    env.current_step <- 0;
    env.tree_frontier <- TreeFrontier.create ();
    env.closure <- Closure.create ();
    env.has_extracted_counter <- 0;
    env.crawling_history_ids <- Hashtbl.create (module Int);
    env.relevant <- 0;