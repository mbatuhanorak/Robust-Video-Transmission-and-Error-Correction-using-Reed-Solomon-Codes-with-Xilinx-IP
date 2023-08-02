
-- ------------------------------------------------------------------------
--
--  (c) Copyright 2010 Xilinx, Inc. All rights reserved.
--
--  This file contains confidential and proprietary information
--  of Xilinx, Inc. and is protected under U.S. and
--  international copyright and other intellectual property
--  laws.
--
--  DISCLAIMER
--  This disclaimer is not a license and does not grant any
--  rights to the materials distributed herewith. Except as
--  otherwise provided in a valid license issued to you by
--  Xilinx, and to the maximum extent permitted by applicable
--  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
--  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
--  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
--  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
--  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
--  (2) Xilinx shall not be liable (whether in contract or tort,
--  including negligence, or under any other theory of
--  liability) for any loss or damage of any kind or nature
--  related to, arising under or in connection with these
--  materials, including for any direct, or any indirect,
--  special, incidental, or consequential loss or damage
--  (including loss of data, profits, goodwill, or any type of
--  loss or damage suffered as a result of any action brought
--  by a third party) even if such damage or loss was
--  reasonably foreseeable or Xilinx had been advised of the
--  possibility of the same.
--
--  CRITICAL APPLICATIONS
--  Xilinx products are not designed or intended to be fail-
--  safe, or for use in any application requiring fail-safe
--  performance, such as life-support or safety devices or
--  systems, Class III medical devices, nuclear facilities,
--  applications related to the deployment of airbags, or any
--  other applications that could lead to death, personal
--  injury, or severe property or environmental damage
--  (individually and collectively, "Critical
--  Applications"). Customer assumes the sole risk and
--  liability of any use of Xilinx products in Critical
--  Applications, subject only to applicable laws and
--  regulations governing limitations on product liability.
--
--  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
--  PART OF THIS FILE AT ALL TIMES. 
--
  




-- ------------------------------------------------------------------------
-- Description
-- -----------
-- This is an example testbench for the  Interleaver/De-interleaver 
-- LogiCORE module.  The testbench has been generated by the Xilinx 
-- CORE Generator software to accompany the netlist you have generated.
--
-- This testbench is for demonstration purposes only.  
--
-- See the Symbol Interleaver/Deinterleaver datasheet for further 
-- information about this core.
-- ------------------------------------------------------------------------
-- Overview of Structure
-- ---------------------
-- The testbench contains the following important blocks:
--
--   ~ Stimuli Manager         : This sets up the stimuli for the testbench.  It does
--                               so by populating configuration objects for other testbench
--                               components and then enabling them when appropriate
--
--   ~ Upstream Data Master    : Supplies symbol data on the Data In Channel.  
--
--   ~ Downstream Data Slave   : Consumes sample data on the Data Out Channel
--
-- ------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity tb_sid_0 is
end tb_sid_0;


architecture tb OF tb_sid_0 is

  constant stim_seed            : integer := 1;

  -- --------------------------------------------------------------------
  -- Timing constants
  -- --------------------------------------------------------------------
  constant clk_period   : time := 100 ns;
  constant t_hold       : time := 10 ns;
  constant t_strobe     : time := clk_period - (1 ns);
    
  constant MAX_ARRAY : integer := 100;  -- Max size for configuration arrays

  signal check_clk : std_logic;  -- The clock used to do checks


  -- -----------------------------
  -- Stimuli types and variables
  -- -----------------------------
  -- Holds configuration information for the blocks.
  --
  type t_sid_configuration is record
    object_valid : boolean; -- Set to true when the object is initialised.  False when it isn't
                            -- This is used when we have a fixed array of these but don't want to use them all.

    block_size : integer;
  end record;

  -- Holds configuration information for the Upstream Data Master (USDM)
  --
  type t_usdm_configuration is record
    object_valid : boolean; -- Set to true when the object is initialised.  False when it isn't
                            -- This is used when we have a fixed array of these but don't want to use them all.

    number_of_transfers   : integer;  -- How many samples to transfer before stopping.  
    waitstates_allowed    : boolean;  -- Set to true if the Upstream Data Master is allowed to insert waitstates
    chance_of_a_waitstate : integer;  -- The % chance of having a waitstate if they are enabled.
    min_waitstate_length  : integer;  -- The minimum length waitstate allowed.
    max_waitstate_length  : integer;  -- The maximum length waitstate allowed.
    pre_wait_length       : integer;  -- How long to wait before we start sending the block. This lets us insert gaps between blocks
  end record;
  
  -- Holds configuration information for the Downstream Data Slave (DSDS)
  --
  type t_dsds_configuration is record
    object_valid              : boolean;         -- Set to true when the object is initialised.  False when it isn't
                                                 -- This is used when we have a fixed array of these but don't want to use them all.

    number_of_transfers       : integer;         -- How many samples to transfer before stopping.  
    waitstates_allowed        : boolean;         -- Set to true if the Upstream Data Master is allowed to insert waitstates
    chance_of_a_waitstate     : integer;         -- The % chance of having a waitstate if they are enabled.
    min_waitstate_length      : integer;         -- The minimum length waitstate allowed.
    max_waitstate_length      : integer;         -- The maximum length waitstate allowed.
  end record;
  

  type t_sid_configuration_array  is array (natural range <>) of t_sid_configuration;
  type t_usdm_configuration_array is array (natural range <>) of t_usdm_configuration;
  type t_dsds_configuration_array is array (natural range <>) of t_dsds_configuration;
 
  shared variable sv_configurations      : t_sid_configuration_array (1 to MAX_ARRAY);
  shared variable sv_usdm_configurations : t_usdm_configuration_array(1 to MAX_ARRAY);
  shared variable sv_dsds_configurations : t_dsds_configuration_array(1 to MAX_ARRAY);
  
  signal sv_usdm_enable   : boolean := false; -- Set to true to enable the Upstream Data Master
  signal sv_usdm_finished : boolean := false; -- Set by the USDM to say it is finished
  signal sv_dsds_enable   : boolean := false; -- Set to true to enable the DSDS
  signal sv_dsds_finished : boolean := false; -- Set by the DSDS to say it is finished. 


  shared variable sv_symbol_count: integer := 0;  -- Keep a count of how many symbols have been seen.  A test ending with 0 is a failure


  signal sim_finished   : std_logic := '0';

  -- Error handling
  shared variable sv_model_mismatch            : integer := 0; -- A count of the number of mismatches between the netlist and the models
  shared variable sv_samples_compared_to_model : integer := 0;  -- The number of samples that were compared against the model
 
  -- ------------------------------------------------------------------------------------------------
  -- Random number generation
  -- ------------------------------------------------------------------------------------------------
  subtype T_RANDINT is integer range 1 to integer'high;

  -- Initialise the random state variable based on an integer seed
  --
  function init_rand(seed : integer) return T_RANDINT is
    variable result : T_RANDINT;
  begin
    if seed < T_RANDINT'low then
      result := T_RANDINT'low;
    elsif seed > T_RANDINT'high then
      result := T_RANDINT'high;
    else
      result := seed;
    end if;
    return result;
  end init_rand;

  -- Generate a random integer between min and max limits
  --
  procedure rand_int(variable rand   : inout T_RANDINT;
                     constant minval : in    integer;
                     constant maxval : in    integer;
                     variable result : out   integer
                     ) is
    variable k, q      : integer;
    variable real_rand : real;
    variable res       : integer;
  begin
    -- Create a new random integer in the range 1 to 2**31-1 and put it back into rand VARIABLE
    -- Based on an example from Numerical Recipes in C, 2nd Edition, page 279
    --
    k := rand/127773;
    q := 16807*(rand-k*127773)-2836*k;
    if q < 0 then
      q := q + 2147483647;
    end if;
    rand := init_rand(q);

    real_rand := (real(rand - T_RANDINT'low)) / real(T_RANDINT'high - T_RANDINT'low);
    res       := integer((real_rand * real(maxval+1-minval)) - 0.5) + minval;
    if res < minval then
      res := minval;
    elsif res > maxval then
      res := maxval;
    end if;
    result := res;
  end rand_int;
  
  -----------------------------------------------------------------------
  -- DUT signals
  -----------------------------------------------------------------------
  -- Naming convention
  --
  -- "<name>"                : A signal driven by the testbench
  -- "<name>_to_dut"         : A signal coming from the testbench. These 
  --                           signals are a delayed verison of the signal <name>
  -- "<name>_from_dut"       : A signal coming from the DUT    

  -- General signals
  --
  signal aclk                       : std_logic := '0';  -- the master clock
  signal aresetn_to_dut             : std_logic := '1';  -- synchronous active low reset
  signal aresetn                    : std_logic := '1';  -- synchronous active low reset

  -- Data Input Channel signals
  --
  signal s_axis_data_tvalid_to_dut   : std_logic := '0';  -- Payload is valid
  signal s_axis_data_tvalid          : std_logic := '0';  -- payload is valid
  signal s_axis_data_tready_from_dut : std_logic := '1';  -- SID is ready
  signal s_axis_data_tdata_to_dut    : std_logic_vector(7 downto 0) := (others => '0');  -- data payload
  signal s_axis_data_tdata           : std_logic_vector(7 downto 0) := (others => '0');  -- data payload
  signal s_axis_data_tlast_to_dut    : std_logic := '0';  -- 
  signal s_axis_data_tlast           : std_logic := '0';  -- 

  -- Data Out Channel signals
  --
  signal m_axis_data_tvalid_from_dut : std_logic := '0';  -- payload is valid
  signal m_axis_data_tready_to_dut   : std_logic := '0';  -- Downstream Data Slave is ready
  signal m_axis_data_tready          : std_logic := '0';  -- Downstream Data Slave is ready
  signal m_axis_data_tdata_from_dut  : std_logic_vector(7 downto 0) := (others => '0');  -- data payload
  signal m_axis_data_tlast_from_dut  : std_logic := '0';  -- 

  -- Event signals
  --
  signal event_tlast_unexpected_from_dut : std_logic := '0';
  signal event_tlast_missing_from_dut    : std_logic := '0';
  signal event_halted_from_dut           : std_logic := '0';



  -----------------------------------------------------------------------
  -- Aliases
  -----------------------------------------------------------------------
  -- These are a convenience for viewing data in a simulator waveform viewer.
  --
  signal s_axis_data_tdata_data : std_logic_vector(7 downto 0);
  signal m_axis_data_tdata_data : std_logic_vector(7 downto 0);



--------------------------------------------------------------------------------
-- start of architecture
--------------------------------------------------------------------------------
begin
  -- ----------------------------------------------------------------------------
  -- Stimuli Manager
  -- ----------------------------------------------------------------------------
  -- The Stimuli Manager moves the simulation through a predefined set of phases,
  -- where each phase is equivalent to a "test" or "Scenario" where the stimuli is
  -- biased to a particular set of conditions.
  -- 
  proc_stimuli_manager : process
  begin
    sim_finished <= '0';
    -- Send small block. 
    -- ------------------

    -- Set up the Upstream Data Master that drives the Data Input AXI Channel
    --    
    sv_usdm_configurations(1).object_valid         := true;
    sv_usdm_configurations(1).waitstates_allowed   := false;
    sv_usdm_configurations(1).number_of_transfers  := 384;
    sv_usdm_configurations(1).pre_wait_length      := 0;

    -- Set up the Downstream Data Slave that reads samples from the Data Output Channel
    --
    sv_dsds_configurations(1).object_valid         := true;
    sv_dsds_configurations(1).waitstates_allowed   := false;
    sv_dsds_configurations(1).number_of_transfers  := 384;

    sv_configurations(1).object_valid        := true;
    sv_configurations(1).block_size          := 384;

    -- Send large block. 
    -- ------------------



    -- Set up the Upstream Data Master that drives the Data Input AXI Channel
    --
    sv_usdm_configurations(2).object_valid          := true;
    sv_usdm_configurations(2).waitstates_allowed    := true;
    sv_usdm_configurations(2).chance_of_a_waitstate := 25;
    sv_usdm_configurations(2).min_waitstate_length  := 1;
    sv_usdm_configurations(2).max_waitstate_length  := 4;
    sv_usdm_configurations(2).number_of_transfers   := 384;
    sv_usdm_configurations(2).pre_wait_length       := 20; -- Wait for 20 clocks before sending data for this block

    -- Set up the Downstream Data Slave that reads samples from the Data Output Channel
    --
    sv_dsds_configurations(2).object_valid          := true;
    sv_dsds_configurations(2).number_of_transfers   := 384;
    sv_dsds_configurations(2).waitstates_allowed    := true;
    sv_dsds_configurations(2).chance_of_a_waitstate := 25;
    sv_dsds_configurations(2).min_waitstate_length  := 1;
    sv_dsds_configurations(2).max_waitstate_length  := 4;

    sv_configurations(2).object_valid        := true;
    sv_configurations(2).block_size          := 384;
  


  

    sv_usdm_enable              <= true;
    sv_dsds_enable              <= true;

    wait on aclk until (sv_usdm_finished = false and sv_dsds_finished = false);
     
    -- Now wait until they all finish.
    wait on aclk until (sv_usdm_finished = true and sv_dsds_finished = true);
 
    sim_finished <= '1';
    
    wait;
  end process proc_stimuli_manager;
  
  -- ----------------------------------------------------------------------------
  -- Upstream Data Master
  -- ----------------------------------------------------------------------------
  --
  -- generation of s_axis_data_tvalid and s_axis_data_tdata.
  --
  proc_usdm : process
    variable v_rand_gen                : T_RANDINT := init_rand(stim_seed+1);  -- Seed for a random generator
    variable v_rint                    : integer;                            -- An integer to randomise
    variable v_tdata                   : std_logic_vector(7 downto 0);
    variable v_tlast                   : std_logic;
    variable v_clocks_to_wait          : integer := 0;
    variable v_number_of_configurations: integer;

    -- data_in_channel_send() - send 1 item of data
    --
    procedure data_in_channel_send (
      variable tdata_value : in std_logic_vector;
      variable tlast_value : in std_logic;
      signal   aclk        : in    std_logic;
      signal   tready      : in    std_logic;
      signal   tvalid      : out   std_logic;
      signal   tlast       : out   std_logic;
      signal   tdata       : out   std_logic_vector
      ) is
    begin
      tdata  <= tdata_value;
      tlast  <= tlast_value;
      tvalid <= '1';

      -- Now wait until the rising clock edge were tready is 1

      loop
        wait until rising_edge(aclk);
        exit when (tready = '1'  );
      end loop;

      tvalid                               <= '0';
      tlast                                <= '0';
      tdata(tdata'left downto tdata'right) <= (others => '0');
    end data_in_channel_send;
  begin
    
    sv_usdm_finished <= true;
    wait on aclk until sv_usdm_enable = true;
    sv_usdm_finished <= false;
    
    -- Work out how many configurations to process
    -- 
    v_number_of_configurations := 0;
    for i in 1 to MAX_ARRAY loop
      if sv_usdm_configurations(i).object_valid = true then
        v_number_of_configurations := v_number_of_configurations + 1;
      else
        exit;
      end if;
    end loop;

    for v_cfg_index in 1 to v_number_of_configurations loop

      -- Optionally wait before starting the block.      
      -- 
      if sv_usdm_configurations(v_cfg_index).pre_wait_length > 0 then
        v_clocks_to_wait := sv_usdm_configurations(v_cfg_index).pre_wait_length;
        for i in 0 to v_clocks_to_wait-1 loop
          wait until rising_edge(aclk);
        end loop;
      end if;

      for v_cfg_data_count in 1 to sv_usdm_configurations(v_cfg_index).number_of_transfers loop



        v_tdata(7 downto 0) := std_logic_vector(to_unsigned(v_cfg_data_count mod 256, 8));
           
        -- Drive TLAST
        -- 
        if v_cfg_data_count = sv_configurations(v_cfg_index).block_size then
          v_tlast := '1';
        else
          v_tlast := '0';
        end if;
         
        -- If waitstates are allowed, wait before sending the data
        --
        if sv_usdm_configurations(v_cfg_index).waitstates_allowed = true then
        
          -- Decide if we want a waitstate in the first place
          --
          rand_int(v_rand_gen, 0, 99, v_rint);
          if v_rint < sv_usdm_configurations(v_cfg_index).chance_of_a_waitstate then
              
            rand_int(v_rand_gen, sv_usdm_configurations(v_cfg_index).min_waitstate_length, 
                                 sv_usdm_configurations(v_cfg_index).max_waitstate_length, v_rint);
            v_clocks_to_wait := v_rint;
              
            for i in 0 to v_clocks_to_wait-1 loop
              wait until rising_edge(aclk);
            end loop;
          end if;
        end if;
        
        data_in_channel_send (tdata_value => v_tdata,
                              tlast_value => v_tlast,
                              aclk        => aclk,
                              tready      => s_axis_data_tready_from_dut,
                              tvalid      => s_axis_data_tvalid,
                              tlast       => s_axis_data_tlast,
                              tdata       => s_axis_data_tdata
                              );
        
      end loop;  -- End of loop that sends samples for this block
    end loop; -- End of loop that sends entire blocks

    sv_usdm_finished <= true;
    wait on aclk until sv_usdm_enable = false;
  end process;


  -- ----------------------------------------------------------------------------
  -- Downstream Data Slave
  -- ----------------------------------------------------------------------------
  --
  -- generation of m_axis_data_tready (if c_has_dout_tready = 1) and tracking 
  -- of the output frame number

  proc_dsds : process
    variable v_rand_gen         : T_RANDINT := init_rand(stim_seed+2);  -- Seed for a random generator
    variable v_rint             : integer;                            -- An integer to randomise
    variable v_clocks_to_wait   : integer := 0;
    variable v_number_of_configurations: integer;
  begin

    sv_dsds_finished <= true;
    wait on aclk until sv_dsds_enable = true;
    
    sv_dsds_finished <= false;
    
    -- Work out how many configurations to process
    -- 
    v_number_of_configurations := 0;
    for i in 1 to MAX_ARRAY loop
      if sv_dsds_configurations(i).object_valid = true then
        v_number_of_configurations := v_number_of_configurations + 1;
      else
        exit;
      end if;
    end loop;

    for v_cfg_index in 1 to v_number_of_configurations loop
      -- For this configuration, receive the required number of samples and then start the loop again.
      
      for v_cfg_data_count in 1 to sv_dsds_configurations(v_cfg_index).number_of_transfers loop
        -- If waitstates are allowed, wait before transfering the data
        if sv_dsds_configurations(v_cfg_index).waitstates_allowed = true and sv_dsds_configurations(v_cfg_index).number_of_transfers > 0 then
          m_axis_data_tready <= '0';  
            
          -- Decide if we want a waitstate in the first place
          rand_int(v_rand_gen, 0, 99, v_rint);
          if v_rint < sv_dsds_configurations(v_cfg_index).chance_of_a_waitstate then
            rand_int(v_rand_gen, sv_dsds_configurations(v_cfg_index).min_waitstate_length, 
                                 sv_dsds_configurations(v_cfg_index).max_waitstate_length, v_rint);
            v_clocks_to_wait := v_rint;
            for i in 0 to v_clocks_to_wait-1 loop
              wait until rising_edge(aclk);
            end loop;
          end if;
        end if;
            
        m_axis_data_tready <= '1';  -- Drive TREADY to 1 to end the waistate.
          
        -- Now wait on the transaction to complete
        wait until rising_edge(aclk) and (m_axis_data_tvalid_from_dut = '1');

      end loop;  -- End of loop that receives samples for this block
    end loop; -- End of loop that receives entire blocks
      
    sv_dsds_finished <= true;
    wait on aclk until sv_dsds_enable = false;

  end process;







  -- ----------------------------------------------------------------------------
  -- Clock Generation
  -- ----------------------------------------------------------------------------
  --
  proc_clk : process
   variable v_errors: integer := 0;
  begin
    aclk <= '0';
    wait for clk_period;   
    while sim_finished = '0'  loop
      aclk <= '0';
      wait for clk_period/2;
      aclk <= '1';
      wait for clk_period/2;
    end loop;

    if sv_symbol_count = 0 then
     v_errors := v_errors + 1;
     report "ERROR: No symbol's seen in this simulation." severity failure;
    end if;

    if v_errors = 0 then
      report "Not a real failure. Simulation finished successfully. Test completed successfully" severity failure;
    end if;
    wait;
  end process;


  -- ----------------------------------------------------------------------------
  -- Reset
  -- ----------------------------------------------------------------------------
  --
  -- This testbench doesn't manipulate reset.  Driving reset to 0 may cause certain
  -- testbench agents to fail.
  --
  aresetn <= '1';



  -----------------------------------------------------------------------
  -- Instantiate the DUT
  -----------------------------------------------------------------------
  --
  dut : entity work.sid_0
      port map(
        aresetn                => aresetn,
        s_axis_data_tdata      => s_axis_data_tdata_to_dut,
        s_axis_data_tvalid     => s_axis_data_tvalid_to_dut,
        s_axis_data_tlast      => s_axis_data_tlast_to_dut,
        s_axis_data_tready     => s_axis_data_tready_from_dut,
        m_axis_data_tdata      => m_axis_data_tdata_from_dut,
        m_axis_data_tvalid     => m_axis_data_tvalid_from_dut,
        m_axis_data_tlast      => m_axis_data_tlast_from_dut,
        m_axis_data_tready     => m_axis_data_tready_to_dut,
        event_tlast_unexpected => event_tlast_unexpected_from_dut,
        event_tlast_missing    => event_tlast_missing_from_dut,
        event_halted           => event_halted_from_dut,
        aclk                   => aclk
        );

  -- ----------------------------------------------------------------------------
  -- Connect the testbench to the DUT.  
  -- ----------------------------------------------------------------------------
  -- Delay all signals so that they arrive after the clock edge.
  -- 
  aresetn_to_dut              <= aresetn            after T_HOLD;
  s_axis_data_tdata_to_dut    <= s_axis_data_tdata  after T_HOLD;
  s_axis_data_tvalid_to_dut   <= s_axis_data_tvalid after T_HOLD;
  s_axis_data_tlast_to_dut    <= s_axis_data_tlast  after T_HOLD;
  m_axis_data_tready_to_dut   <= m_axis_data_tready after T_HOLD;


  -------------------------------------------------------------------------------
  -- Assign TDATA / TUSER fields to aliases, for easy simulator waveform viewing
  -------------------------------------------------------------------------------

  -- Data Input Channel alias signals
  --
  s_axis_data_tdata_data        <= s_axis_data_tdata(7 downto 0);

  -- Data Output Channel alias signals
  --
  m_axis_data_tdata_data        <= m_axis_data_tdata_from_dut(7 downto 0);


  -----------------------------------------------------------------------
  -- Check outputs
  -----------------------------------------------------------------------
  check_clk <= transport aclk after T_STROBE;




  check_outputs : process (check_clk)
    variable check_ok : boolean := true;

    -- Previous values of data master channel signals
    --
    variable m_data_tvalid_prev : std_logic := '0';
    variable m_data_tready_prev : std_logic := '0';
    variable m_data_tdata_prev  : std_logic_vector(7 downto 0) := (others => '0');
    variable m_data_tdata_x     : std_logic_vector(7 downto 0) := (others => 'X');
  begin

    if rising_edge(check_clk) then
      -- Do not check the output payload values, as this requires a numerical model
      -- which would make this demonstration testbench unwieldy.
      -- Instead, check the protocol of the data master channel:

      -- check that the payload is valid (not X) when TVALID is high
      -- and check that the payload does not change while TVALID is high until TREADY goes high

      if m_axis_data_tvalid_from_dut = '1' and m_axis_data_tready_to_dut = '1' and not is_x(m_axis_data_tdata_data) and aresetn = '1' then
         sv_symbol_count := sv_symbol_count + 1;
      end if;


      if m_axis_data_tvalid_from_dut = '1' and aresetn = '1' then
        if m_axis_data_tdata_from_dut = m_data_tdata_x then
          report "ERROR: m_axis_data_tdata is invalid when m_axis_data_tvalid is high" severity error;
          check_ok := false;
        end if;

        if m_data_tvalid_prev = '1' and m_data_tready_prev = '0' then  -- payload must be the same as last cycle
          if m_axis_data_tdata_from_dut /= m_data_tdata_prev then
            report "ERROR: m_axis_data_tdata changed while m_axis_data_tvalid was high and m_axis_data_tready was low" severity error;
            check_ok := false;
          end if;
        end if;
      end if;
      assert check_ok
        report "ERROR: terminating test with failures." severity failure;

      -- Record payload values for checking next clock cycle
      -- 
      if check_ok then
        m_data_tvalid_prev  := m_axis_data_tvalid_from_dut;
        m_data_tready_prev  := m_axis_data_tready;
        m_data_tdata_prev   := m_axis_data_tdata_from_dut;
      end if;
    end if;  
  end process check_outputs;

 
end tb;


