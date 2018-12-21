LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY singleprocessor IS 
	PORT
	(
		CLK :  IN  STD_LOGIC;
		RST :  IN  STD_LOGIC;
		input4 :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END singleprocessor;

ARCHITECTURE structure OF singleprocessor IS 

COMPONENT main_control
	PORT(i_instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_reg_dest : OUT STD_LOGIC;
		 o_jump : OUT STD_LOGIC;
		 o_branch : OUT STD_LOGIC;
		 o_mem_to_reg : OUT STD_LOGIC;
		 o_mem_write : OUT STD_LOGIC;
		 o_ALU_src : OUT STD_LOGIC;
		 o_reg_write : OUT STD_LOGIC;
		 o_ALU_op : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END COMPONENT;

COMPONENT adder_32
	PORT(i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mux21_32bit
	PORT(i_sel : IN STD_LOGIC;
		 i_0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_mux : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT ALU
	PORT(ALU_OP : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 shamt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 zero : OUT STD_LOGIC;
		 ALU_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT sll_2
	PORT(i_to_shift : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_shifted : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT and_2
	PORT(i_A : IN STD_LOGIC;
		 i_B : IN STD_LOGIC;
		 o_F : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT jump_extra
	PORT(i_from_adder : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 i_from_sll : IN STD_LOGIC_VECTOR(27 DOWNTO 0);
		 o_shifted : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT sll_2_25
	PORT(i_to_shift : IN STD_LOGIC_VECTOR(25 DOWNTO 0);
		 o_shifted : OUT STD_LOGIC_VECTOR(27 DOWNTO 0)
	);
END COMPONENT;

COMPONENT dmem
GENERIC (depth_exp_of_2 : INTEGER;
			mif_filename : STRING
			);
	PORT(clock : IN STD_LOGIC;
		 wren : IN STD_LOGIC;
		 address : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 byteena : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT sign_extender_16_32
	PORT(i_to_extend : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 o_extended : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT pc_reg
	PORT(CLK : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 i_next_PC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_PC : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT imem
GENERIC (depth_exp_of_2 : INTEGER;
			mif_filename : STRING
			);
	PORT(clock : IN STD_LOGIC;
		 wren : IN STD_LOGIC;
		 address : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 byteena : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT register_file
	PORT(CLK : IN STD_LOGIC;
		 w_en : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 rs_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 rt_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 w_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 w_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 rs_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 rt_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mux21_5bit
	PORT(i_sel : IN STD_LOGIC;
		 i_0 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 i_1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 o_mux : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;







SIGNAL	i_nxt_PC :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	o_F         	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	o_F_secondadder  :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	write_sel 	 	 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	o_PC		 	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	q_imem 			 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	rs_data 	  	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	rt_data 	 	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	o_signextend 	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ib_alu       	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ALU_OP 		 	 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	i_write_data     :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ALU_out 	 	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	dmem_q 		 	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	shift_signextend :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	top_first_mux    :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	jumpadress       :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	shifted          :  STD_LOGIC_VECTOR(27 DOWNTO 0);

SIGNAL	zero_out 	 :  STD_LOGIC;
SIGNAL	jump         :  STD_LOGIC;
SIGNAL	branch       :  STD_LOGIC;
SIGNAL	ALU_SRC    	 :  STD_LOGIC;
SIGNAL	mem_write :  STD_LOGIC;
SIGNAL	mem_to_reg   :  STD_LOGIC;
SIGNAL	reg_write    :  STD_LOGIC;
SIGNAL	reg_dest     :  STD_LOGIC;
SIGNAL	and_gate 	 :  STD_LOGIC;


BEGIN 

g_inst1 : pc_reg
PORT MAP(CLK => CLK,
		 reset => RST,
		 i_next_PC => i_nxt_PC,
		 o_PC => o_PC);
		 
		 
g_inst2 : imem
GENERIC MAP(depth_exp_of_2 => 10,
			mif_filename => "imem.mif"
			)
PORT MAP(clock => CLK,
		 wren => '0',
		 address => o_PC(11 DOWNTO 2),
		 byteena => "1111",
		 data => o_PC,
		 q => q_imem);
		 
g_inst3 : adder_32
PORT MAP(i_A => o_PC,
		 i_B => input4,
		 o_F => o_F);

		 
g_inst4 : main_control
PORT MAP(i_instruction => q_imem,
		 o_reg_dest => reg_dest,
		 o_jump => jump,
		 o_branch => branch,
		 o_mem_to_reg => mem_to_reg,
		 o_mem_write => mem_write,
		 o_ALU_src => ALU_SRC,
		 o_reg_write => reg_write,
		 o_ALU_op => ALU_OP);

g_inst5 : mux21_5bit
PORT MAP(i_sel => reg_dest,
		 i_0 => q_imem (20 downto 16),
		 i_1 => q_imem (15 downto 11),
		 o_mux => write_sel);
		 
g_inst6 : register_file
PORT MAP(CLK => CLK,
		 w_en => reg_write,
		 reset => RST,
		 rs_sel => q_imem(25 DOWNTO 21),
		 rt_sel => q_imem(20 DOWNTO 16),
		 w_data => i_write_data,
		 w_sel => write_sel,
		 rs_data => rs_data,
		 rt_data => rt_data);
		 
g_inst7 : sign_extender_16_32
PORT MAP(i_to_extend => q_imem(15 DOWNTO 0),
		 o_extended => o_signextend);
		 
g_inst8 : mux21_32bit
PORT MAP(i_sel => ALU_SRC,
		 i_0 => rt_data,
		 i_1 => o_signextend,
		 o_mux => ib_alu);
		 
g_inst9 : ALU
PORT MAP(ALU_OP => ALU_OP,
		 i_A => rs_data,
		 i_B => ib_alu,
		 shamt => q_imem(10 DOWNTO 6),
		 zero => zero_out,
		 ALU_out => ALU_out);


g_inst10 : dmem
GENERIC MAP(depth_exp_of_2 => 10,
			mif_filename => "dmem.mif"
			)
PORT MAP(clock => CLK,
		 wren => mem_write,
		 address => ALU_out(11 DOWNTO 2),
		 byteena => "1111",
		 data => rt_data,
		 q => dmem_q);
		 
g_inst11 : mux21_32bit
PORT MAP(i_sel => mem_to_reg,
		 i_0 => ALU_out,
		 i_1 => dmem_q,
		 o_mux => i_write_data);
		 
		 
g_inst12 : sll_2
PORT MAP(i_to_shift => o_signextend,
		 o_shifted => shift_signextend);
		 
g_inst13 : and_2
PORT MAP(i_A => branch,
		 i_B => zero_out,
		 o_F => and_gate);


g_inst14 : adder_32
PORT MAP(i_A => o_F,
		 i_B => shift_signextend,
		 o_F => o_F_secondadder);


g_inst15 : mux21_32bit
PORT MAP(i_sel => and_gate,
		 i_0 => o_F,
		 i_1 => o_F_secondadder,
		 o_mux => top_first_mux);


g_inst16 : mux21_32bit
PORT MAP(i_sel => jump,
		 i_0 => top_first_mux,
		 i_1 => jumpadress,
		 o_mux => i_nxt_PC);
		 
g_inst17 : sll_2_25
PORT MAP(i_to_shift => q_imem(25 DOWNTO 0),
		 o_shifted => shifted);

g_inst18 : jump_extra
PORT MAP(i_from_adder => o_F(31 DOWNTO 28),
		 i_from_sll => shifted,
		 o_shifted => jumpadress);




END structure;