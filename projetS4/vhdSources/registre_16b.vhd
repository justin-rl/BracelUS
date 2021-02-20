----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/16/2021 03:03:29 PM
-- Design Name: 
-- Module Name: registre_16b - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity registre_16b is
    Port ( i_clk : in STD_LOGIC;
           i_reset : in STD_LOGIC;
           i_load : in STD_LOGIC;
           i_dat_load : in STD_LOGIC_VECTOR (15 downto 0);
           o_dat : out STD_LOGIC);
end registre_16b;

architecture Behavioral of registre_16b is

    signal   q_shift_reg   : std_logic_vector(15 downto 0);   -- registre 

begin

    -- registre a décalage,  MSB arrive premier, entre par la droite, decalage a gauche  
    reg_dec: process (i_clk, i_reset)
    begin    
        if (i_reset = '1')  then
            q_shift_reg  <= (others =>'0');
        elsif rising_edge(i_clk) then  
            if (i_load = '1')  then
                q_shift_reg  <= i_dat_load;
            else
                q_shift_reg(15 downto 0) <= q_shift_reg(14 downto 0) & '0';
            end if;
        end if;
     end process;
 
     o_dat   <=  q_shift_reg(15);


end Behavioral;
