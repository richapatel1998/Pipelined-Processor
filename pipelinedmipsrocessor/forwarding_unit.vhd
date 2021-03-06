library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity forwarding_unit is
  port(
    CLK : in std_logic;
	rd_mem : in std_logic_vector(4 downto 0);
	rd_wb : in std_logic_vector(4 downto 0);
	rs_sel : in std_logic_vector(4 downto 0);
	rt_sel : in std_logic_vector(4 downto 0);
	reg_write_mem : in std_logic;
	reg_write_wb : in std_logic;
	rs_mux : out std_logic_vector(1 downto 0);
	rt_mux : out std_logic_vector(1 downto 0)
  );
 end forwarding_unit;

architecture mixed of forwarding_unit is 

begin
process(CLK, rd_mem, rd_wb, rs_sel, rt_sel, reg_write_mem, reg_write_wb)

begin
	if (rd_mem = "00000") or (rd_wb = "00000") then
		rs_mux <= "00";
		rt_mux <= "00";
	end if;
	
	if ((rd_mem = rs_sel) and (reg_write_mem = '1') and (rd_mem /= "00000") ) then
		rs_mux <= "01";
	elsif ((rd_wb = rs_sel) and (reg_write_wb = '1' and (rd_wb /= "00000")))then
		rs_mux <= "10";
	else
		rs_mux <= "00";
	end if;
	
	if ((rd_mem = rt_sel) and (reg_write_mem = '1'and (rd_mem /= "00000"))) then
		rt_mux <= "01";
	elsif ((rd_wb = rt_sel) and (reg_write_wb = '1' and (rd_wb /= "00000"))) then
		rt_mux <= "10";
	else
		rt_mux <= "00";
	end if;
	
end process;	

end mixed;