LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY err_ctrl IS
    GENERIC (
        DATA_WIDTH : INTEGER := 8;
        ADDR_DEPTH : INTEGER := 160
    );
    PORT (
        clk_i : IN STD_LOGIC;
        rst_i : IN STD_LOGIC;
        frame_data_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        frame_tlast_i : IN STD_LOGIC;
        frame_valid_i : IN STD_LOGIC;
        frame_ready_o : OUT STD_LOGIC;
        status_ready_o : OUT STD_LOGIC;

        dec_status_tdata_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        dec_status_valid_i : IN STD_LOGIC;
        frame_data_o : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        err_count_in_frame_o : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        err_in_frame_o : OUT STD_LOGIC;
        frame_valid_o : OUT STD_LOGIC;
        -------
        addr_a : OUT INTEGER RANGE 0 TO ADDR_DEPTH - 1;
        addr_b : OUT INTEGER RANGE 0 TO ADDR_DEPTH - 1;

        --waddr_a : IN INTEGER RANGE 0 TO 2 ** ADDR_DEPTH - 1;
        --waddr_b : IN INTEGER RANGE 0 TO 2 ** ADDR_DEPTH - 1;
        data_a : OUT STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0):=(others=>'0');
        we_a : OUT STD_LOGIC;
        q_b : In STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0)

    );
END err_ctrl;

ARCHITECTURE rtl OF err_ctrl IS
    SIGNAL addr_a_c : INTEGER RANGE 0 TO  ADDR_DEPTH - 1;
    SIGNAL count_c : INTEGER RANGE 0 TO  ADDR_DEPTH - 1;
    SIGNAL addr_count_c : INTEGER RANGE 0 TO  ADDR_DEPTH - 1;
    SIGNAL tick : STD_LOGIC;
    SIGNAL frame_valid_r : STD_LOGIC;
BEGIN
frame_ready_o <= '1';
    status_ready_o <= '1';
    PROCESS (clk_i)
    BEGIN
        IF rising_edge(clk_i) THEN
            IF rst_i = '0' THEN
            err_in_frame_o <= '0';
            tick<='0';
            err_count_in_frame_o <= (others=>'0');
            ELSE
                IF frame_valid_i = '1' THEN

                END IF;
                IF dec_status_valid_i = '1' THEN
                    
                    IF dec_status_tdata_i(0) = '1' THEN
                    tick <= '0';
                    ELSE
                    tick <= '1';
                    END IF;
                    err_count_in_frame_o <= "000" & dec_status_tdata_i(6 DOWNTO 2);

                    IF dec_status_tdata_i(1) = '1' THEN
                        err_in_frame_o <= '1';
                    ELSE
                        err_in_frame_o <= '0';
                    END IF;
                END IF;
                IF count_c = ADDR_DEPTH - 1 THEN
                    tick <= '0';
                    count_c <= 0;
                ELSE
                if tick='1' then
                    count_c <= count_c + 1;
                end if;
                    
                END IF;
            END IF;
        END IF;
    END PROCESS;
    PROCESS (clk_i)
    BEGIN
        IF rising_edge(clk_i) THEN
            IF frame_valid_i = '1' THEN
                addr_a_c <= addr_a_c + 1;
                if addr_a_c = 159 then
                addr_a_c<=0;
                end if;
                addr_a <= addr_a_c;
                data_a <= frame_data_i;
                we_a <= '1';
            ELSE
                we_a <= '0';
                addr_a_c <= 0;
            END IF;
        END IF;
    END PROCESS;
    frame_data_o <= q_b;
    PROCESS (clk_i)
    BEGIN
        IF rising_edge(clk_i) THEN
        frame_valid_o<=frame_valid_r;
            IF tick = '1' THEN
                addr_count_c <= addr_count_c + 1;
                addr_b <= addr_count_c;
                if addr_count_c=159 then 
                addr_count_c<=0;
                end if;
                frame_valid_r <= '1';
            ELSE
            frame_valid_r <= '0';
                addr_count_c <= 0;
            END IF;

        END IF;
    END PROCESS;
END ARCHITECTURE;