library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ec_logic is
  port(i_write_data_in	: in std_logic_vector(4 downto 0);
	rs_data_in	: in std_logic_vector(4 downto 0);
	rt_data_in	: in std_logic_vector(4 downto 0);
	rs_bypass	: out std_logic;
	rt_bypass	: out std_logic
  );
 end ec_logic;

architecture mixed of ec_logic is 

begin
process(i_write_data_in, rs_data_in, rt_data_in)

begin
	rs_bypass <= '0';
	rt_bypass <= '0';
	if (i_write_data_in = rs_data_in) then
		rs_bypass <= '1';
	end if;

	if (i_write_data_in = rt_data_in) then
		rt_bypass <= '1';

	end if;
	
end process;	

end mixed;