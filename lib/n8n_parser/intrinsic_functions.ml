let mainWorkflow_code = {|
def mainWorkflow(trigger_input: [{...}]):
  """
  comments: You need to give comments when implementing mainWorkflow
  TODOs: 
    - first define some actions
    - define a trigger
    - then implement this
  """
  print("Please call Workflow-implement first")
  raise NotImplementedError
|}

let get_intrinsic_functions () =
  let node_define_function = `Assoc [
    ("name", `String "function_define");
    ("description", `String "define a list of functions, each one must specify the given (integration-resource-action)");
    ("parameters", `Assoc [
      ("type", `String "object");
      ("properties", `Assoc [
        ("thought", `Assoc [
          ("type", `String "string");
          ("description", `String "Why you choose this function")
        ]);
        ("plan", `Assoc [
          ("type", `String "array");
          ("description", `String "What will you do in the following steps");
          ("items", `Assoc [
            ("type", `String "string")
          ])
        ]);
        ("criticism", `Assoc [
          ("type", `String "string");
          ("description", `String "What main weakness does the current plan have")
        ]);
        ("functions", `Assoc [
          ("type", `String "array");
          ("description", `String "the newly defined functions.");
          ("items", `Assoc [
            ("type", `String "object");
            ("properties", `Assoc [
              ("integration_name", `Assoc [
                ("type", `String "string")
              ]);
              ("resource_name", `Assoc [
                ("type", `String "string")
              ]);
              ("operation_name", `Assoc [
                ("type", `String "string")
              ]);
              ("comments", `Assoc [
                ("type", `String "string");
                ("description", `String "This will be shown to the user, how will you use this node in the workflow")
              ]);
              ("TODO", `Assoc [
                ("type", `String "array");
                ("description", `String "The function didn't have implemented yet. List what you will do to further implement, test and refine this function");
                ("items", `Assoc [
                  ("type", `String "string")
                ])
              ])
            ]);
            ("required", `List [`String "integration_name"; `String "resource_name"; `String "operation_name"; `String "comments"; `String "TODO"])
          ])
        ])
      ]);
      ("required", `List [`String "thought"; `String "plan"; `String "criticism"; `String "functions"])
    ])
  ] in

  let node_rewrite_param_function = `Assoc [
    ("name", `String "function_rewrite_params");
    ("description", `String "Give params of a already defined function with the provided param descriptions, This will overwrite now params");
    ("parameters", `Assoc [
      ("type", `String "object");
      ("properties", `Assoc [
        ("thought", `Assoc [
          ("type", `String "string");
          ("description", `String "Why you choose this function")
        ]);
        ("plan", `Assoc [
          ("type", `String "array");
          ("description", `String "What will you do in the following steps");
          ("items", `Assoc [
            ("type", `String "string")
          ])
        ]);
        ("criticism", `Assoc [
          ("type", `String "string");
          ("description", `String "What main weakness does the current plan have")
        ]);
        ("function_name", `Assoc [
          ("type", `String "string");
          ("description", `String "Such as 'Action_x' or 'Trigger_x'. Must be a already defined function.")
        ]);
        ("params", `Assoc [
          ("type", `String "string");
          ("description", `String "The json object of the input params. The field descriptions should refer to the Function defination in the code")
        ]);
        ("comments", `Assoc [
          ("type", `String "string");
          ("description", `String "This will be shown to the user, how will you use this node in the workflow")
        ]);
        ("TODO", `Assoc [
          ("type", `String "array");
          ("description", `String "What will you do to further implement, test and refine this function");
          ("items", `Assoc [
            ("type", `String "string")
          ])
        ])
      ]);
      ("required", `List [`String "thought"; `String "plan"; `String "criticism"; `String "function_name"; `String "params"; `String "comments"; `String "TODO"])
    ])
  ] in

  let workflow_implement_function = `Assoc [
    ("name", `String "workflow_implment");
    ("description", `String "Implement a workflow, directly write the output of the workflow, staring with \"def mainWorkflow...\" or \"def subworkflow_xxx...\"");
    ("parameters", `Assoc [
      ("type", `String "object");
      ("properties", `Assoc [
        ("thought", `Assoc [
          ("type", `String "string");
          ("description", `String "Why you choose this function")
        ]);
        ("plan", `Assoc [
          ("type", `String "array");
          ("description", `String "What will you do in the following steps");
          ("items", `Assoc [
            ("type", `String "string")
          ])
        ]);
        ("criticism", `Assoc [
          ("type", `String "string");
          ("description", `String "What main weakness does the current plan have")
        ]);
        ("workflow_name", `Assoc [
          ("type", `String "string");
          ("description", `String "the newly implemented workflow. If this workflow exists, we will overwrite it. All names must be \"mainWorkflow\" or \"subworkflow_x\"")
        ]);
        ("code", `Assoc [
          ("type", `String "string");
          ("description", `String "Write the python code of the workflow. We will check you have \"comments\" and \"TODOs\". Input of mainWorkflow should always be trigger_input, Input of subworkflows should always be father_workflow_input")
        ])
      ]);
      ("required", `List [`String "thought"; `String "plan"; `String "criticism"; `String "workflow_name"; `String "code"])
    ])
  ] in

  let ask_user_help_function = `Assoc [
    ("name", `String "ask_user_help");
    ("description", `String "Call this function when you think you can't solve some problems. You can ask user for help.");
    ("parameters", `Assoc [
      ("type", `String "object");
      ("properties", `Assoc [
        ("problems", `Assoc [
          ("type", `String "string");
          ("description", `String "Tell what problem you are confronted with to user and ask for help.")
        ])
      ])
    ])
  ] in

  let task_submit_function = `Assoc [
    ("name", `String "task_submit");
    ("description", `String "Call this function when you think you have finished the task. User will give you some feedback that can help you make your workflow better.");
    ("parameters", `Assoc [
      ("type", `String "object");
      ("properties", `Assoc [
        ("result", `Assoc [
          ("type", `String "string");
          ("description", `String "Tell what you have done to user. Use Markdown format.")
        ])
      ])
    ])
  ] in

  [node_define_function; node_rewrite_param_function; workflow_implement_function; ask_user_help_function; task_submit_function]