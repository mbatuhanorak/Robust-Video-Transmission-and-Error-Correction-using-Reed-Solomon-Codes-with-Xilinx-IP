LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY encoder_inter IS
    PORT (
        clk_i : IN STD_LOGIC;
        rst_i : IN STD_LOGIC;
        encoder_input_tlast_i: IN STD_LOGIC;
        inter_tlast_o : OUT STD_LOGIC
    );
END encoder_inter;

ARCHITECTURE rtl OF encoder_inter IS
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


END ARCHITECTURE;