open Yojson.Basic.Util

module Logger = struct
  let log ?(level=Logs.Info) msg =
    Logs.log level (fun m -> m "%s" msg)

  let red_text msg = "\027[31m" ^ msg ^ "\027[0m"
  let light_black_text msg = "\027[90m" ^ msg ^ "\027[0m"
end

let chat_completion_request args = 
  `Assoc [
    ("usage", `String "usage info");
    ("choices", `List [
      `Assoc [
        ("message", `Assoc [
          ("function_call", `Assoc [
            ("name", `String "function_name");
            ("arguments", `String "{\"arg1\": \"value1\"}")
          ]);
          ("content", `String "message content")
        ])
      ]
    ])
  ]

module OpenAIFunction = struct
  let parse args =
    let retry_time = ref 1 in
    let max_time = 3 in
    let rec try_request i =
      if i > max_time then (
        let error_str = "Failed to generate chat response." in
        Logger.log ~level:Logs.Error (Logger.light_black_text error_str);
        raise (Failure error_str)
      ) else (
        let output = chat_completion_request args in
        let usage = output |> member "usage" |> to_string in
        let message = output |> member "choices" |> to_list |> List.hd |> member "message" in
        let () = Printf.printf "%s\n" usage in

        match message |> member "function_call" |> to_option with
        | Some _ -> message
        | None ->
          let args_messages = args |> List.assoc "messages" in
          let updated_messages = args_messages @ [
            `Assoc [("role", `String "assistant"); ("content", message |> member "content" |> to_string)];
            `Assoc [("role", `String "user"); ("content", `String "No Function call here! You should always use a function call as your response.")]
          ] in
          let new_args = ("messages", `List updated_messages) :: (List.remove_assoc "messages" args) in
          Logger.log (Logger.red_text (Printf.sprintf "Retry for the %d'th time" (!retry_time + 1)));
          retry_time := !retry_time + 1;
          try_request (i + 1)
      )
    in
    let message = try_request !retry_time in
    let function_name = message |> member "function_call" |> member "name" |> to_string in
    let function_arguments = message |> member "function_call" |> member "arguments" |> to_string |> Yojson.Basic.from_string in
    let content = message |> member "content" |> to_option |> Option.map to_string |> Option.value ~default:"" in
    content, function_name, function_arguments, message
end