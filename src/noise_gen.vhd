LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY noise_gen IS
    PORT (
        aclk : IN STD_LOGIC;
        aresetn : IN STD_LOGIC;
        encoder_input_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        encoder_input_tvalid : IN STD_LOGIC;
        encoder_input_tlast : IN STD_LOGIC;
        encoder_input_tready : OUT STD_LOGIC;
        decoder_output_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        decoder_output_tvalid : OUT STD_LOGIC;
        decoder_output_tready : IN STD_LOGIC;
        decoder_output_tlast : OUT STD_LOGIC
    );
END noise_gen;

ARCHITECTURE rtl OF noise_gen IS
    SIGNAL encoder_input_tdata_r : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL encoder_input_tvalid_r : STD_LOGIC;
    SIGNAL encoder_input_tlast_r : STD_LOGIC;
    SIGNAL decoder_output_tready_r : STD_LOGIC;
    constant error_range:integer:=12;
    SIGNAL counter : integer range 0 to error_range-1:=0;
BEGIN
    decoder_output_tdata <= encoder_input_tdata_r;
    decoder_output_tvalid <= encoder_input_tvalid_r;
    decoder_output_tlast <= encoder_input_tlast_r;
    encoder_input_tready <= decoder_output_tready_r;
    PROCESS (aclk)
    BEGIN
        IF rising_edge(aclk) THEN
            IF aresetn = '0' THEN
                encoder_input_tdata_r <= (OTHERS => '0');
                encoder_input_tvalid_r <= '0';
                encoder_input_tlast_r <= '0';
                decoder_output_tready_r <= '0';
            ELSE
            encoder_input_tdata_r<=encoder_input_tdata;
            -- if counter=error_range-1 then
            --     counter<=0;
            --     encoder_input_tdata_r <= STD_LOGIC_VECTOR(to_unsigned(1+to_integer(unsigned(encoder_input_tdata)),8));
            -- else
            -- counter<=counter+1;
            -- end if;
                
                encoder_input_tvalid_r <= encoder_input_tvalid;
                encoder_input_tlast_r <= encoder_input_tlast;
                decoder_output_tready_r <= decoder_output_tready;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;