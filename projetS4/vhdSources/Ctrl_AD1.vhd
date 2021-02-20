--------------------------------------------------------------------------------
-- Controle du module pmod AD1
-- Ctrl_AD1.vhd
-- ref: http://www.analog.com/media/cn/technical-documentation/evaluation-documentation/AD7476A_7477A_7478A.pdf 

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity Ctrl_AD1 is
port ( 
    reset                       : in    std_logic;  
    clk_ADC                     : in    std_logic; 						-- Horloge à fournir à l'ADC
    i_DO                        : in    std_logic;                      -- Bit de donnée en provenance de l'ADC         
    o_ADC_nCS                   : out   std_logic;                      -- Signal Chip select vers l'ADC 
	
    i_ADC_Strobe                : in    std_logic;                      -- Synchronisation: strobe déclencheur de la séquence de réception    
    o_echantillon_pret_strobe   : out   std_logic;                      -- strobe indicateur d'une réception complète d'un échantillon  
    o_echantillon               : out   std_logic_vector (11 downto 0)  -- valeur de l'échantillon reçu
);
end Ctrl_AD1;

architecture Behavioral of Ctrl_AD1 is
  
    component AD7476_mef
    port ( 
        clk_ADC                 : in    std_logic; 
        reset                   : in    std_logic; 
        i_bit                   : in std_logic;
        i_ADC_Strobe            : in    std_logic;  --  cadence echantillonnage AD1
        i_val_cpt               : in    std_logic_vector(3 downto 0);
        o_ADC_nCS               : out   std_logic;  -- Signal Chip select vers l'ADC  
        o_Decale                : out   std_logic;  -- Signal de décalage
        o_FinSequence_Strobe    : out   std_logic;   -- Strobe de fin de séquence d'échantillonnage
        o_cpt_rst               : out   std_logic 
    );
    end component;
    
    component compteur_nbits
    generic (nbits : integer := 4);
    port ( 
        clk             : in    std_logic; 
        i_en            : in    std_logic; 
        reset           : in    std_logic; 
        o_val_cpt       : out   std_logic_vector (nbits-1 downto 0)
    );
    end component;
    
    
    component reg_dec_12b is
    Port ( 
        i_clk : in STD_LOGIC;
        i_reset : in STD_LOGIC;
        i_en : in STD_LOGIC; -- decal
        i_dat_bit : in STD_LOGIC; --entree serie
        o_dat : out STD_LOGIC_VECTOR(11 downto 0)
    );
    end component;  
    
    
    signal en_cpt : std_logic;
    signal cpt_rst : std_logic;
    signal cpt_val : std_logic_vector(3 downto 0);
    signal decal : std_logic;
    signal done_strobe : std_logic;
    signal ncs : std_logic;
    
    signal en_decal : std_logic;
    signal in_decal : std_logic;
    signal out_decal : std_logic_vector(11 downto 0);
    signal internal_out_decal : std_logic_vector(11 downto 0);

  
    
begin

    in_decal <= i_DO;

--  Machine a etats finis pour le controle du AD7476
    MEF : AD7476_mef
    port map (
        clk_ADC                 => clk_ADC,
        reset                   => reset,
        i_bit                   => i_DO,
        i_ADC_Strobe            => i_ADC_Strobe,
        i_val_cpt               => cpt_val,
        o_ADC_nCS               => ncs,
        o_Decale                => en_decal,
        o_FinSequence_Strobe    => done_strobe,
        o_cpt_rst               => cpt_rst
    );
    
    compteur : compteur_nbits
    port map (
        clk                     => clk_ADC,
        i_en                    => '1',
        reset                   => cpt_rst,
        o_val_cpt               => cpt_val
    );
    
    registre_12bits : reg_dec_12b
    port map (
        i_clk => clk_ADC,
        i_reset => '0',
        i_en => en_decal,
        i_dat_bit => in_decal, --entree serie
        o_dat => out_decal
    );
        


  with done_strobe select
        internal_out_decal <= out_decal when '1',
                              internal_out_decal when others;

  o_echantillon <= internal_out_decal;
  o_echantillon_pret_strobe <= done_strobe;
  o_ADC_nCS <= ncs;

end Behavioral;
