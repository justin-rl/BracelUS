----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/18/2021 11:28:55 AM
-- Design Name: 
-- Module Name: Ctrl_DAC - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Ctrl_DAC is
    Port (
        clk_DAC : in std_logic;
        i_reset : in std_logic;
        ----
        o_DAC_tsync : out std_logic;
        o_DAC_data : out std_logic
     );
end Ctrl_DAC;

architecture Behavioral of Ctrl_DAC is

component compteur_nbits is
generic (nbits : integer := 4);
   port ( clk             : in    std_logic; 
          i_en            : in    std_logic; 
          reset           : in    std_logic; 
          o_val_cpt       : out   std_logic_vector (nbits-1 downto 0)
          );
end component;

component dac_mef is
    Port (
        clk_DAC : in std_logic;
        i_reset : in std_logic;
        strobe_collecte : in std_logic;
        i_cpt_val : in std_logic_vector(3 downto 0);
        ----
        o_t_sync : out std_logic;
        o_rst_cpt : out std_logic;
        o_done : out std_logic      
     );
end component;

component registre_16b is
    Port ( i_clk : in STD_LOGIC;
           i_reset : in STD_LOGIC;
           i_load : in STD_LOGIC;
           i_dat_load : in STD_LOGIC_VECTOR (15 downto 0);
           o_dat : out STD_LOGIC);
end component;

constant nbEchantillonMemoire : integer := 24;
type tableau is array (integer range 0 to nbEchantillonMemoire - 1) of std_logic_vector(11 downto 0);
constant mem_forme_signal : tableau := (
    x"800",
    x"A11",
    x"BFF",
    x"DA7",
    x"EEC",
    x"FB9",
    x"FFF",
    x"FB9",
    x"EEC",
    x"DA7",
    x"BFF",
    x"A11",
    x"800",
    x"5EE",
    x"400",
    x"258",
    x"113",
    x"046",
    x"001",
    x"046",
    x"113",
    x"258",
    x"400",
    x"5EE"
);

    constant c_NbIteration : unsigned(2 downto 0) := "010";

    signal d_compteur_echantillonMemoire : unsigned(7 downto 0) := (others => '0');
    signal d_echantillonMemoire : std_logic_vector(15 downto 0) := (others => '0');
    signal q_iteration : unsigned(2 downto 0) := (others => '0');
    signal q_collecte : std_logic := '0';
    signal q_prec_collecte : std_logic;
    signal q_strobe_collecte : std_logic;
    
    signal cpt_val : std_logic_vector(3 downto 0) := "0000";
    
    signal dac_t_sync : std_logic := '1';
    signal dac_t_sync_prec : std_logic := '0';
    signal reset_cpt : std_logic := '0';
    signal dac_echantillon : std_logic;
    signal done_ech : std_logic := '0';
    
    signal load_reg : std_logic := '0';
    signal out_reg : std_logic := '0';

begin

  reg_16b : registre_16b
    port map (
        i_clk => clk_DAC,
        i_reset => '0',
        i_load => load_reg,
        i_dat_load => d_echantillonMemoire,
        o_dat => out_reg
    );

    compteur : compteur_nbits
    port map (
        clk => clk_DAC,
        i_en => '1',
        reset => reset_cpt,
        o_val_cpt => cpt_val
    );
    
    mef : dac_mef
    port map (
        clk_DAC => clk_DAC,
        i_reset => i_reset,
        strobe_collecte => q_strobe_collecte,
        i_cpt_val => cpt_val,
        ----
        o_t_sync => dac_t_sync,
        o_rst_cpt => reset_cpt,
        o_done => done_ech
    );

    lireEchantillon : process (i_reset, clk_DAC)
        begin
           if(i_reset = '1') then 
              d_compteur_echantillonMemoire <= x"00";
              d_echantillonMemoire <= x"0000";
              q_iteration <= (others => '0');
           else
              if rising_edge(clk_DAC) then
                 if (d_compteur_echantillonMemoire = "00" or done_ech = '1') then
                     d_echantillonMemoire <= "0000"&mem_forme_signal(to_integer(d_compteur_echantillonMemoire));
                     q_collecte <= '1';
                     load_reg <= '1';
                     if (to_integer(q_iteration) < c_NbIteration) then
                        if (d_compteur_echantillonMemoire = mem_forme_signal'length-1) then
                            d_compteur_echantillonMemoire <= x"00";
                            q_iteration <= q_iteration + 1;
                        else
                            d_compteur_echantillonMemoire <= d_compteur_echantillonMemoire + 1;
                        end if;
                     end if;
                 else
                    q_collecte <= '0';
                    load_reg <= '0';
                 end if;
             end if;
           end if;
        end process;
        
    process (clk_DAC, q_collecte) is
    begin
        if (rising_edge(clk_DAC)) then
            q_prec_collecte <= q_collecte;
        end if;
    end process;
    
    process (q_prec_collecte, q_collecte) is
    begin
        q_strobe_collecte <= q_collecte and not(q_prec_collecte);
    end process;     
        
        
   o_DAC_data <= out_reg;
   o_DAC_tsync <= dac_t_sync;

end Behavioral;
