library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity oor is
  port( i_A, i_B : in std_logic;
  	    o_F : out std_logic);
 end oor;

architecture mixed of oor is 

begin

o_F <= i_A or i_B;

end mixed;