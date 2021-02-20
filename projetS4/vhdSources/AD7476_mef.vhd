--------------------------------------------------------------------------------
-- MEF de controle du convertisseur AD7476  
-- AD7476_mef.vhd
-- ref: http://www.analog.com/media/cn/technical-documentation/evaluation-documentation/AD7476A_7477A_7478A.pdf 
---------------------------------------------------------------------------------------------
--	Librairy and Package Declarations
---------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

---------------------------------------------------------------------------------------------
--	Entity Declaration
---------------------------------------------------------------------------------------------
entity AD7476_mef is
port(
    clk_ADC                 : in std_logic;
    reset			        : in std_logic;
    i_bit                   : in std_logic;
    i_ADC_Strobe            : in std_logic;     --  cadence echantillonnage AD1
    i_val_cpt               : in std_logic_vector(3 downto 0);  
    o_ADC_nCS		        : out std_logic;    -- Signal Chip select vers l'ADC  
    o_Decale			    : out std_logic;    -- Signal de décalage   
    o_FinSequence_Strobe    : out std_logic;     -- Strobe de fin de séquence d'échantillonnage
    o_cpt_rst               : out std_logic 
);
end AD7476_mef;
 
---------------------------------------------------------------------------------------------
--	Object declarations
---------------------------------------------------------------------------------------------
architecture Behavioral of AD7476_mef is

--	Components

--	Constantes

--	Signals

--	Registers

-- Attributes

    type state_type is (HOLD, DROP_NCS, SYNC, SAMPLE, DONE);
    signal curr_state, next_state : state_type;
    
    signal internal_o_adc_ncs : std_logic;
    signal internal_o_decale : std_logic;
    signal internal_o_FinSequence_Strobe : std_logic;
    signal internal_o_cpt_en : std_logic;
    signal internal_o_cpt_rst : std_logic;

begin

-- Assignation du prochain état

    process(clk_ADC, reset)
    begin
        if reset = '1' then
            curr_state <= HOLD;
        elsif rising_edge(clk_ADC) then
            curr_state <= next_state;
        end if;
    end process;
    
    
    process (curr_state, i_ADC_Strobe, i_val_cpt, i_bit)
    begin
        case curr_state is
            when HOLD =>
                if i_ADC_Strobe = '1' then
                    next_state <= SYNC;
                else
                    next_state <= curr_state;
                end if;
            when SYNC => 
                if i_val_cpt = "0010" and i_bit = '0' then
                    next_state <= SAMPLE;
                elsif i_bit = '1' then
                    next_state <= HOLD;
                else
                    next_state <= curr_state;
                end if;
            when SAMPLE =>
                if i_val_cpt = "1110" then
                    next_state <= DONE;
                else
                    next_state <= curr_state;
                end if;
            when DONE =>
                next_state <= HOLD;
            when others => next_state <= HOLD;
        end case;
    end process;
    
    
    process (curr_state)
    begin
        case curr_state is
            when HOLD =>
                internal_o_adc_ncs <= '1';
                internal_o_decale <= '0';
                internal_o_FinSequence_Strobe <= '0';
                internal_o_cpt_rst <= '1';
            when SYNC =>
                internal_o_adc_ncs <= '0';
                internal_o_decale <= '0';
                internal_o_FinSequence_Strobe <= '0';
                internal_o_cpt_rst <= '0';
            when SAMPLE =>
                internal_o_adc_ncs <= '0';
                internal_o_decale <= '1';
                internal_o_FinSequence_Strobe <= '0';
                internal_o_cpt_rst <= '0';
            when DONE =>
                internal_o_adc_ncs <= '1';
                internal_o_decale <= '0';
                internal_o_FinSequence_Strobe <= '1';
                internal_o_cpt_rst <= '0';
            when others =>
                internal_o_adc_ncs <= '1';
                internal_o_decale <= '0';
                internal_o_FinSequence_Strobe <= '0';
                internal_o_cpt_rst <= '0';
        end case;
    end process;

    o_ADC_nCS <= internal_o_adc_ncs;
    o_Decale <= internal_o_decale;
    o_FinSequence_Strobe <= internal_o_FinSequence_Strobe;
    o_cpt_rst <= internal_o_cpt_rst;


---- Calcul des sorties
---- ATTENTION: Les valeurs des sorties ci-dessous sont temporaires. Connectez-les aux bonnes valeurs selon votre MEF.
--o_ADC_nCS <=	'1';				
--o_Decale	<=	'0';
--o_FinSequence_Strobe <=	'0';


 
end Behavioral;
