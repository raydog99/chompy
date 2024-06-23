type JobType = FETCH | PARSE | UPDATEDB | READDB | DEDUP

val list : crawl_id: string -> state -> job_info list
val get : crawl_id: string -> id:string -> job_info option
val create : job_config -> job_info option
val abort : crawl_id: string -> id:string -> bool
val stop : crawl_id:string -> id:string -> bool