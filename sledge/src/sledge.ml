(* Copyright (c) 2018 - present Facebook, Inc. All rights reserved.

   This source code is licensed under the BSD style license found in the
   LICENSE file in the root directory of this source tree. An additional
   grant of patent rights can be found in the PATENTS file in the same
   directory. *)

(** Sledge executable entry point *)

let main ~input ~output =
  try
    let program = Frontend.translate input in
    Trace.flush () ;
    Option.iter output ~f:(function
      | "-" -> Format.printf "%a@." Llair.fmt program
      | filename ->
          Out_channel.with_file filename ~f:(fun oc ->
              let ff = Format.formatter_of_out_channel oc in
              Format.fprintf ff "%a@." Llair.fmt program ) ) ;
    Format.printf "@\nRESULT: Success@."
  with exn ->
    let bt = Caml.Printexc.get_raw_backtrace () in
    Trace.flush () ;
    ( match exn with
    | Frontend.Invalid_llvm msg ->
        Format.printf "@\nRESULT: Invalid input: %s@." msg
    | Unimplemented msg ->
        Format.printf "@\nRESULT: Unimplemented: %s@." msg
    | Failure msg -> Format.printf "@\nRESULT: Internal error: %s@." msg
    | _ ->
        Format.printf "@\nRESULT: Unknown error: %s@."
          (Caml.Printexc.to_string exn) ) ;
    Caml.Printexc.raise_with_backtrace exn bt


;; Config.run main
