LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY trivium_core IS
    PORT (
        SYS_CLK : IN STD_LOGIC; --System or User clock
        rst_i : IN STD_LOGIC; --System or User clock
        data_valid_i : IN STD_LOGIC;
        data_ready_o : OUT STD_LOGIC;
        data_i : IN STD_LOGIC;

        cry_ready_i : IN STD_LOGIC;
        cry_valid_o : OUT STD_LOGIC;
        crydata_v_valid_o : OUT STD_LOGIC;
        crydata_v_o : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        crydata_o : OUT STD_LOGIC
    ); --Cipher stream output
END trivium_core;

ARCHITECTURE Behavioral OF trivium_core IS
    SIGNAL STATE : STD_LOGIC_VECTOR(287 DOWNTO 0) := (OTHERS => '0'); ---Main LFSR of the Cipher
    SIGNAL k1, k2, k3, t1, t2, t3, key_stream : STD_LOGIC := '0'; ---XOR Feedback Nodes
    TYPE states IS (RESET_1, LOAD_KEY_IV, INIT_CYCLES, OPERATIONAL);
    SIGNAL pr_state : states;
    SIGNAL INIT_COUNTER : INTEGER RANGE 0 TO 2047 := 0;
    SIGNAL empty_r : STD_LOGIC;
    SIGNAL data_valid_r : STD_LOGIC;
    SIGNAL data_r : STD_LOGIC;
    SIGNAL crydata_r : STD_LOGIC;
    SIGNAL ctrl : STD_LOGIC;
    SIGNAL crydata_v : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL index_crydata : INTEGER RANGE 0 TO 7 := 0;
    SIGNAL new_counter : INTEGER RANGE 0 TO 1500:= 0;
    SIGNAL active : STD_LOGIC;

    ----System contstants
    CONSTANT INIT_LIMIT : INTEGER RANGE 0 TO 2047 := 1152;
    CONSTANT KEY : STD_LOGIC_VECTOR(79 DOWNTO 0) :=X"0F62B5085BAE0154A7FA"; --Secret 80-bit key input port
    CONSTANT IV : STD_LOGIC_VECTOR(79 DOWNTO 0) := X"288FF65DC42B92F960C7";--80-bit Initialization vector input port

    SIGNAL KEY_FLIP : STD_LOGIC_VECTOR(79 DOWNTO 0);
    SIGNAL IV_FLIP : STD_LOGIC_VECTOR(79 DOWNTO 0);

    FUNCTION little_endian (b : STD_LOGIC_VECTOR) RETURN STD_LOGIC_VECTOR IS -- 80-bit Big Endian to Little Endian Convert (bit reverses each byte)
        VARIABLE result : STD_LOGIC_VECTOR(79 DOWNTO 0); --ex 0x0123456789 -> 0x084C2A6E19 

    BEGIN
        FOR i IN 0 TO 9 LOOP
            result(((i * 8) + 7) DOWNTO (i * 8)) := b(i * 8) &
            b((i * 8) + 1) &
            b((i * 8) + 2) &
            b((i * 8) + 3) &
            b((i * 8) + 4) &
            b((i * 8) + 5) &
            b((i * 8) + 6) &
            b((i * 8) + 7);
        END LOOP;
        RETURN result;
    END;

BEGIN
    cry_valid_o <= NOT empty_r; --
    crydata_o <= crydata_r;
    data_ready_o <= (empty_r OR cry_ready_i) WHEN active = '1' ELSE
        '0';
    MAIN_TRIVIUM : PROCESS (SYS_CLK) ---Core LFSR is comprised of three shift registers connected via feedback nodes (t1,t2,t3) 
    BEGIN --Core must be loaded with key and 
        IF (SYS_CLK'event AND SYS_CLK = '1') THEN
            IF rst_i = '0'THEN
                pr_state <= RESET_1;
                INIT_COUNTER <= 0;
                active <= '0';
                data_valid_r<='0';
                data_r<='0';
            END IF;
            CASE pr_state IS
                WHEN RESET_1 =>
                    IF rst_i = '0'THEN
                        pr_state <= RESET_1;
                        INIT_COUNTER <= 0;
                        empty_r <= '1';
                        --crydata_r <= '0';
                        ctrl <= '0';
                        new_counter<=0;
                        crydata_v <= (OTHERS => '0');
                        index_crydata <= 0;
                        crydata_v_valid_o <= '0';
                    ELSE
                        pr_state <= LOAD_KEY_IV;
                    END IF;

                WHEN LOAD_KEY_IV =>
                    STATE(92 DOWNTO 0) <= "0000000000000" & KEY_FLIP;
                    STATE(176 DOWNTO 93) <= X"0" & IV_FLIP;
                    STATE(287 DOWNTO 177) <= "111" & X"000000000000000000000000000";
                    pr_state <= INIT_CYCLES;
                WHEN INIT_CYCLES =>
                    IF (INIT_COUNTER = INIT_LIMIT-1) THEN
                        INIT_COUNTER <= 0;
                        pr_state <= OPERATIONAL;
                        ctrl <= '0';
                        active <= '1';

                    ELSE
                        STATE(92 downto 0) <= STATE(91 downto 0) & t3;  
                        STATE(176 downto 93) <= STATE(175 downto 93) & t1;
                        STATE(287 downto 177) <= STATE(286 downto 177) & t2;
                        INIT_COUNTER <= INIT_COUNTER + 1;
                    END IF;
                WHEN OPERATIONAL =>
                    data_valid_r <= data_valid_i;
                    data_r <= data_i;
                    IF ((empty_r = '1' OR cry_ready_i = '1')) THEN
                        IF (data_valid_i = '1') THEN
                            empty_r <= '0';
                            STATE(92 DOWNTO 0) <= STATE(91 DOWNTO 0) & t3;
                            STATE(176 DOWNTO 93) <= STATE(175 DOWNTO 93) & t1;
                            STATE(287 DOWNTO 177) <= STATE(286 DOWNTO 177) & t2;

                            ctrl <= '1';
                            crydata_v(index_crydata) <= crydata_r;
                            IF index_crydata = 7 THEN
                                index_crydata <= 0;
                                crydata_v_valid_o <= '1';
                                new_counter<=new_counter+1;
                            ELSE
                                crydata_v_valid_o <= '0';
                                index_crydata <= index_crydata + 1;
                            END IF;

                        ELSE
                            ctrl <= '0';
                            empty_r <= '1';
                        END IF;
                    ELSE
                        ctrl <= '0';
                        empty_r <= '0';
                    END IF;
                    pr_state <= OPERATIONAL;
                WHEN OTHERS =>
            END CASE;

        END IF;
    END PROCESS;
    crydata_r <= key_stream XOR data_i;
    --XOR Nodes
    k1 <= STATE(65) XOR STATE(92);
    k2 <= STATE(161) XOR STATE(176);
    k3 <= STATE(242) XOR STATE(287);
    t1 <= k1 XOR ((STATE(90) AND STATE(91)) XOR STATE(170));
    t2 <= k2 XOR ((STATE(174) AND STATE(175)) XOR STATE(263));
    t3 <= k3 XOR ((STATE(285) AND STATE(286)) XOR STATE(68));
    key_stream <= k1 XOR k2 XOR k3;
    crydata_v_o <= crydata_v;
    --Change input values to "little endian" so output matches offical test vectors
    KEY_FLIP <= little_endian(KEY);--little_endian
    IV_FLIP  <= little_endian(IV);--little_endian
    PROCESS (SYS_CLK)
    BEGIN
        IF rising_edge(SYS_CLK) THEN
            IF rst_i = '0' THEN

            ELSE
                IF ctrl = '1' THEN

                else
                --index_crydata <= 0;
                END IF;

            END IF;

        END IF;
    END PROCESS;

END Behavioral;