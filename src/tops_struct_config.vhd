-- Generation properties:
--   Format              : hierarchical
--   Generic mappings    : exclude
--   Leaf-level entities : direct binding
--   Regular libraries   : use library name
--   View name           : include
--   
LIBRARY reed_lib;
CONFIGURATION tops_struct_config OF tops IS
   FOR struct
      FOR ALL : dual_port_bram
         USE ENTITY reed_lib.dual_port_bram(rtl);
      END FOR;
      FOR ALL : err_ctrl
         USE ENTITY reed_lib.err_ctrl(rtl);
      END FOR;
      FOR ALL : noise_gen
         USE ENTITY reed_lib.noise_gen(rtl);
      END FOR;
      FOR ALL : pattern_generator_r2
         USE ENTITY reed_lib.pattern_generator_r2(arch);
      END FOR;
      FOR ALL : rs_decoder_0
         USE CONFIGURATION reed_lib.rs_decoder_0_rs_decoder_0_arch_config;
      END FOR;
      FOR ALL : rs_encoder_0
         USE CONFIGURATION reed_lib.rs_encoder_0_rs_encoder_0_arch_config;
      END FOR;
      FOR ALL : sid_de_interleaver
         USE CONFIGURATION reed_lib.sid_de_interleaver_sid_de_interleaver_arch_config;
      END FOR;
   END FOR;
END tops_struct_config;
