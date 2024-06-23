val get : string -> Configuration
val get_as_map : string -> (string * string) list
val set_property : string -> string -> string -> unit
val list : string list
val create : Config.t -> string
val delete : string -> unit