(*
  Copyright (C) iNuron - info@openvstorage.com
  This file is part of Open vStorage. For license information, see <LICENSE.txt>
*)

open! Prelude

module Generic = struct
    open Stat
    include Stat

    type t = {
        mutable creation: timestamp;
        mutable period : float;
        statistics : (int32, stat) Hashtbl.t;
      }

    let clone t = {t with statistics = Hashtbl.copy t.statistics }

    let stop  t = t.period <- Unix.gettimeofday() -. t.creation
    let clear t =
      t.creation <- Unix.gettimeofday();
      t.period <- 0.0;
      Hashtbl.clear t.statistics

    let snapshot t reset =
      let stopped = clone t in
      let () = stop stopped in
      if reset then clear t;
      stopped

    let show_inner t tag_to_name =
      let b = Buffer.create 1024 in
      let add = Buffer.add_string b in
      add "{\n\tcreation: ";
      add ([%show: Prelude.timestamp] t.creation);
      add ";\n\tperiod: ";
      add (Printf.sprintf "%.2f" t.period);
      add ";\n\t ";
      Hashtbl.fold
        (fun tag stat acc ->
         add (tag_to_name tag);
         add  " : ";
         add ([%show : stat] stat);
         add ";\n\t")
        t.statistics ();
      add "}";
      Buffer.contents b

    let to_yojson_inner t tag_to_name =
      `Assoc
       [ "creation", `Float t.creation;
         "period", `Float t.period;
         "statistics", `Assoc (Hashtbl.map
                                 (fun i32 stat -> tag_to_name i32, stat_to_yojson stat)
                                 t.statistics
                              );
       ]

    let make () = {
        creation = Unix.gettimeofday();
        period  = 0.0;
        statistics = Hashtbl.create 50;
      }

    let _find_stat t tag =
        try Hashtbl.find t.statistics tag
        with Not_found -> Stat.make ()

    let new_delta (t:t) tag delta =
      let stat = _find_stat t tag in
      let stat' = _update stat delta in
      Hashtbl.replace t.statistics tag stat'

    let to_buffer_with_version ~ser_version buf t=
      Llio.int8_to buf ser_version;
      Llio.float_to buf t.creation;
      Llio.float_to buf t.period;
      Llio.hashtbl_to Llio.int32_to stat_to buf t.statistics

    let to_buffer buf t =
      to_buffer_with_version ~ser_version:1 buf t

    let from_buffer_raw buf =
      let creation = Llio.float_from buf in
      let period   = Llio.float_from buf in
      let statistics =
        let ef buf = Llio.pair_from Llio.int32_from stat_from buf in
        Llio.hashtbl_from ef buf
      in
      { creation; period; statistics}

    let from_buffer buf =
      let ser_version = Llio.int8_from buf in
      assert (ser_version = 1);
      from_buffer_raw buf
  end
