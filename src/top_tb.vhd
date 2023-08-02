LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE std.textio.ALL;
USE std.env.finish;
USE std.textio.ALL;
USE ieee.std_logic_textio.ALL;

ENTITY top_tb IS
END top_tb;

ARCHITECTURE sim OF top_tb IS

    CONSTANT clk_hz : INTEGER := 100e6;
    CONSTANT clk_period : TIME := 1 sec / clk_hz;

    SIGNAL clk : STD_LOGIC := '1';
    SIGNAL rst : STD_LOGIC := '0';
    signal t_in_data_i           : STD_LOGIC_VECTOR (7 DOWNTO 0);
    signal t_in_valid_i          : STD_LOGIC:='1';
    signal t_in_ready_o          : STD_LOGIC;
    FILE file_rd : text;
    SIGNAL look_1 : STD_LOGIC;
    CONSTANT C_CLK_PERIOD : TIME := 1 ns; -- NS
    signal err_count_in_frame_o : STD_LOGIC_VECTOR (7 DOWNTO 0);
    signal err_in_frame_o       : STD_LOGIC;
    signal frame_data_o         : STD_LOGIC_VECTOR (7 DOWNTO 0);
    signal frame_valid_o        : STD_LOGIC;
    

  signal cry_v_data_o : STD_LOGIC_VECTOR(7 downto 0);
  signal cry_v_valid_o :STD_LOGIC ;
BEGIN

    clk <= NOT clk AFTER C_CLK_PERIOD / 2;


        

        tops : entity work.tops
        port map (
          clk_i                => clk,
          rst_i                => rst,
          t_in_data_i          => t_in_data_i,
          t_in_valid_i         => t_in_valid_i,
          cry_v_data_o         => cry_v_data_o,
          cry_v_valid_o        => cry_v_valid_o,
          err_count_in_frame_o => err_count_in_frame_o,
          err_in_frame_o       => err_in_frame_o,
          frame_data_o         => frame_data_o,
          frame_valid_o        => frame_valid_o,
          t_in_ready_o         => t_in_ready_o
        );
        












    	---------------------------------------------------------------------------------
	--Transmitter
	--------------------------------------------------------------------------------
    look_1 <= (t_in_ready_o AND t_in_valid_i);
	PROC_TRANS : PROCESS
		--FILE r_text_file_1     : text OPEN read_mode IS "img1.txt";
		VARIABLE r_text_line_1 : line;
		VARIABLE r_number_v_1 : INTEGER;
	BEGIN
        rst <= '0';
		file_open(file_rd, "C:\Users\mbatu\Desktop\vivadoprj\reedsolomon\src\img_lenna.txt", read_mode);
		WAIT FOR 8 ns;
		rst <= '1';

		readline(file_rd, r_text_line_1);
		read(r_text_line_1, r_number_v_1);
		t_in_data_i <= STD_LOGIC_VECTOR(to_unsigned(r_number_v_1, 8));
		WAIT FOR C_CLK_PERIOD;
		WHILE rst = '1' LOOP
           
			WHILE look_1 = '1' LOOP
			if(not endfile(file_rd)) then
				readline(file_rd, r_text_line_1);
				read(r_text_line_1, r_number_v_1);
				t_in_data_i <= STD_LOGIC_VECTOR(to_unsigned(r_number_v_1, 8));
				WAIT FOR C_CLK_PERIOD;
			end if;	
			END LOOP; -- identifier
			WAIT FOR C_CLK_PERIOD;
			
			
		END LOOP;
		WAIT FOR C_CLK_PERIOD;
		WAIT FOR 10 ns;
        finish;
		WAIT FOR C_CLK_PERIOD;

	END PROCESS;
    VIDEO_REC_PROCESS : PROCESS
    FILE w_text_file : text OPEN write_mode IS "C:\Users\mbatu\Desktop\vivadoprj\reedsolomon\src\encry.txt";
    VARIABLE w_text_line : line;

BEGIN
    WAIT FOR 8 ns;
    WHILE rst = '1' LOOP
        IF (cry_v_valid_o = '1') THEN
        ---write(w_text_line, test_eq_wr_addr_o); --write(w_text_line,ram_wr_addr_o,left,5);
            write(w_text_line, (cry_v_data_o));
            writeline(w_text_file, w_text_line);
        END IF;
        WAIT FOR C_CLK_PERIOD;
    END LOOP; -- identifier
END PROCESS;








END ARCHITECTURE;