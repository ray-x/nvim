;; extends

(command
  name: (command_name) @injection.language
  argument: (raw_string) @injection.content)

((command
   name: (command_name) @_name
   argument: (raw_string) @injection.content)
 (#eq? @_name "gawk")
 (#set! injection.language "awk"))
