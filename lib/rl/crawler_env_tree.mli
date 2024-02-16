open Base
open Core
open Core.Option
open Base.List
open Gym

module type TreeCrawlerEnvType = sig
  type t

  val create_env : string list -> CrawlerSys.t -> int -> int array -> t
  val step : t -> int -> Webpage.t * float * bool * unit
  val reset : t -> Webpage.t list
  val create_initial_state_actions : t -> string list -> (Webpage.t * int) list
end