library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity hazard_detect is
  port(
	CLK			: in std_logic;
	jump			: in std_logic;
	branch 			: in std_logic;
	ex_memread		: in std_logic; 
	ex_reg_rt		: in std_logic_vector (4 downto 0);
	id_reg_rs		: in std_logic_vector (4 downto 0);
	id_reg_rt		: in std_logic_vector (4 downto 0);
	ex_write_regsel		: in std_logic_vector (4 downto 0);
	if_flush 		: out std_logic;
	id_flush		: out std_logic;
	pc_stall		: out std_logic;
	id_stall 		: out std_logic
	
);
	
 end hazard_detect;

architecture mixed of hazard_detect is 

begin

process ( id_reg_rt, id_reg_rs, ex_reg_rt, ex_write_regsel, jump, branch, CLK)
begin

if_flush <= '0';
id_flush <= '0';
pc_stall <= '0';
id_stall <= '0';

		if ((jump = '1') or (branch = '1')) then 
		
		if_flush <= '1';
		id_flush <= '1';
		
		end if;
		
		if ((ex_memread = '1') and ((ex_reg_rt = id_reg_rs) or (ex_reg_rt = id_reg_rt))) then
		
		id_stall <= '1';
		pc_stall <= '1';
		
		end if; 

		if ((branch = '1') and ((ex_write_regsel = id_reg_rs) or (ex_write_regsel = id_reg_rt))) then
		
		pc_stall <= '1';
		id_stall <= '1';
		
		end if;
end process;
end mixed;