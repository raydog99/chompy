open Chompy.Http_protocol
open Soup

let main () = 
	let example_url = "https://en.wikipedia.org/wiki/Monty_Python_and_the_Holy_Grail" in
	let html_response = Http_protocol.fetch example_url |> Lwt_main.run in
	parse html_response $$ "a[href]" 
		|> iter (fun a -> print_endline (R.attribute "href" a ))

	(*
	Docker, K8
		future: extensible to other cloud native alternatives
		service discovery w zab



	spawn master
		spawn URL frontier (concurrent queue)

		spawn parser workers
			poll, fetch URL frontier
				future: dedup check
				future: compress
				future: robot exclusion
			parse for URLs -> send to URL frontier
			upload doc to storage system

		seed file -> job assignment with consistent hashing

		storage system: FS -> OLAP processing

		spawning process: any case for transient FaaS?
	*)

let () = main ()