open Printf

module type QNetworkType = sig
  type t
  val build : t -> unit
  val lr : t -> float
  val predict : t -> float array -> float array
  val fit : t -> (float array * float array) array -> unit
  val model : t -> unit
end

module type AgentType = sig
  type t
  val initialize : t -> unit
  val train : t -> unit
  val policy : t -> WebpageType.t
end

module Agent (Webpage : WebpageType) (TreeFrontier : TreeFrontierType) (ReplayBuffer : ReplayBufferType) (QNetwork : QNetworkType) : AgentType =
struct
  type t = {
    env : unit;
    target_update_period : int;
    input_dim : int;
    batch_size : int;
    gamma : float;
    q_network : QNetwork.t;
    target_q_network : QNetwork.t;
    buffer : ReplayBuffer.t;
    MAX_DOMAIN_PAGES : int;
  }

  val initialize : t -> unit
  val train : t -> unit
  val policy : t -> WebpageType.t
end