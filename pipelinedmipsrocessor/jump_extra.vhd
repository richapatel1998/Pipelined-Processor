library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- shifts the input "i_to_shift" by 2 and output the result in "o_shifted"
entity jump_extra is
  port( i_from_sll   : in std_logic_vector(27 downto 0);
		i_from_adder : in std_logic_vector(3 downto 0);
  	    o_shifted : out std_logic_vector(31 downto 0));
 end jump_extra;

architecture mixed of jump_extra is 

begin

o_shifted(31 downto 28) <= i_from_adder;
o_shifted(27 downto 0) <= i_from_sll;

end mixed;