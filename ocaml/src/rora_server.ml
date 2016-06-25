let transport_s = function
  | Net_fd.TCP  -> "tcp"
  | Net_fd.RDMA -> "rdma"

let _alternative_start =
  let open Foreign in
  let open Ctypes in
  foreign
    "alba_alternative_start"
    (string @-> string @-> int @-> int @-> int
     @-> string
     @-> int
     @-> returning int64_t)

let alternative_start transport host port cores queue_depth files_path files_path_length =
  _alternative_start (transport_s transport) host port cores queue_depth
                     files_path files_path_length

external alba_stop_rora_server :
  int64 -> int = "alba_stop_rora_server"


let stop h =
  alba_stop_rora_server h
