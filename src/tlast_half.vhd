LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tlast_half IS
    PORT (
        clk_i : IN STD_LOGIC;
        rst_i : IN STD_LOGIC;
        encoder_input_tlast_i: IN STD_LOGIC;
        de_inter_output_tvalid : IN STD_LOGIC;
        de_inter_output_tready  : IN STD_LOGIC;
        decoder_tlast_o : OUT STD_LOGIC;

        --encoder_m_axis_output_tvalid : IN STD_LOGIC;
       -- encoder_m_axis_output_tready : IN STD_LOGIC;
        inter_tlast_o : OUT STD_LOGIC
    );
END tlast_half;

ARCHITECTURE rtl OF tlast_half IS
    SIGNAL counter : INTEGER RANGE 0 TO 384 - 1 := 0;
    signal  flag    :STD_LOGIC:='0';
BEGIN

inter_tlast_o<=encoder_input_tlast_i when flag='1' else '0';
process(clk_i)
begin
    if rising_edge(clk_i) then
        if encoder_input_tlast_i='1' then
            flag<=not flag;
        end if;
    end if;

end process;

PROCESS (clk_i)
    BEGIN
        IF rising_edge(clk_i) THEN
            IF rst_i = '0' THEN
                counter <= 0;
                decoder_tlast_o <= '0';
            ELSE
                IF de_inter_output_tvalid = '1' AND de_inter_output_tready = '1' THEN
                    IF counter = 192-1 THEN
                        
                        counter <= 0;
                        decoder_tlast_o <= '0';
                    elsif counter = 191-1 then
                        decoder_tlast_o <= '1';    
                        counter <= counter + 1;
                    ELSE 
                        decoder_tlast_o <= '0';
                        counter <= counter + 1;
                    END IF;
                ELSE
                    counter <= 0;
                    decoder_tlast_o <= '0';
                END IF;

            END IF;
        END IF;

    END PROCESS;

END ARCHITECTURE;