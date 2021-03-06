(*
  Copyright (C) iNuron - info@openvstorage.com
  This file is part of Open vStorage. For license information, see <LICENSE.txt>
*)

open! Prelude
open! Mem_key_value_store
open OUnit

let suite = "all" >:::[
      Prelude_test.suite;
      Llio2_test.suite;
      "Choose_test" >::: Choose_test.suite;
      Encryption_test.suite;
      Nsm_protocol_test.suite;
      Nsm_model_test.suite;
      Albamgr_protocol_test.suite;
      Albamgr_test.suite;
      Proxy_test.suite;
      Alba_test.suite;
      Disk_safety_test.suite;
      Asd_test.suite;
      "alba_crc32c" >::: Alba_crc32c_test.suite;
      Compressors_test.suite;
      "cache" >::: Cache_test.suite;
      Fragment_cache_test.suite;
      Gcrypt_test.suite;
      Rebalancing_helper_test.suite;
      Maintenance_test.suite;
      Erasure_test.suite;
      Buffer_pool_test.suite;
      Maintenance_coordination_test.suite;
      Posix_test.suite;
      Fragment_cache_config_test.suite;
      Memcmp_test.suite;
      Alba_osd_test.suite;
      Policy_test.suite;
      Proxy_osd_test.suite;
      Fragment_helper_test.suite;
      Fragment_size_helper_test.suite;
      Read_preference_test.suite;
    ]
