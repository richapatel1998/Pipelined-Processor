LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY fiveStageProcessor2 IS 
	PORT
	(
		CLK :  IN  STD_LOGIC;
		RST :  IN  STD_LOGIC
	);
END fiveStageProcessor2;

ARCHITECTURE structure OF fiveStageProcessor2 IS 

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

COMPONENT mux21_1bit
	Port(i_sel : IN STD_LOGIC;
		 i_0 : IN STD_LOGIC;
		 i_1 : IN STD_LOGIC;
		 o_mux : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT mux31_32bit
	PORT(i_sel : IN STD_LOGIC_VECTOR(1 downto 0);
			i_0 : in std_logic_vector(31 downto 0);
			i_1	: in std_logic_vector(31 downto 0);
			i_2	: in std_logic_vector(31 downto 0);
			o_mux	: out std_logic_vector(31 downto 0)
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
		 stall : IN STD_LOGIC;
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

COMPONENT ex_mem
	PORT(CLK           : in  std_logic;
		mem_flush, mem_stall, exmem_reset : in std_logic;
		ex_instruction  	: in std_logic_vector(31 downto 0); -- pass instruction along (useful for debugging)
        mem_instruction 	 : out std_logic_vector(31 downto 0);
        ex_pc_plus_4 		: in std_logic_vector(31 downto 0);
       	mem_pc_plus_4 		: out std_logic_vector(31 downto 0);
  	-- CONTROL signals
        ex_reg_dest   		: in std_logic;
  	    ex_mem_to_reg 		: in std_logic;
  	    ex_mem_write  		: in std_logic;
  	    ex_reg_write  		: in std_logic;
  	    mem_reg_dest  		 : out std_logic;
  	    mem_mem_to_reg 		: out std_logic;
  	    mem_mem_write  		: out std_logic;
  	    mem_reg_write  		: out std_logic;
  	-- ALU signals
		ex_ALU_out 			: in std_logic_vector(31 downto 0);
		mem_ALU_out 		: out std_logic_vector(31 downto 0);
	-- Register signals
		ex_rt_data 			: in std_logic_vector(31 downto 0);
		mem_rt_data 		: out std_logic_vector(31 downto 0);
  		ex_write_reg_sel 	: in std_logic_vector(4 downto 0); -- see the Reg. Dest. mux in the pipeline archteicture diagram
  		mem_write_reg_sel 	: out std_logic_vector(4 downto 0)
  	    );
END COMPONENT; 

COMPONENT id_ex
	PORT(CLK           : in  std_logic;
  		ex_flush, ex_stall, idex_reset : in std_logic;
  		id_instruction  : in std_logic_vector(31 downto 0); -- pass instruction along (useful for debugging)
        ex_instruction  : out std_logic_vector(31 downto 0);
        id_pc_plus_4 : in std_logic_vector(31 downto 0);
       	ex_pc_plus_4 : out std_logic_vector(31 downto 0);
  	-- CONTROL signals
        id_reg_dest   : in std_logic;
  	    id_branch 	 : in std_logic;
  	    id_mem_to_reg : in std_logic;
  	    id_ALU_op 	 : in std_logic_vector(3 downto 0);
  	    id_mem_write  : in std_logic;
  	    id_ALU_src 	 : in std_logic;
  	    id_reg_write  : in std_logic;
  	    ex_reg_dest   : out std_logic;
  	    ex_branch 	 : out std_logic;
  	    ex_mem_to_reg : out std_logic;
  	    ex_ALU_op 	 : out std_logic_vector(3 downto 0);
  	    ex_mem_write  : out std_logic;
  	    ex_ALU_src 	 : out std_logic;
  	    ex_reg_write  : out std_logic;
  	-- Register signals
  		id_rs_data : in std_logic_vector(31 downto 0);
  		id_rt_data : in std_logic_vector(31 downto 0);
  		ex_rs_data : out std_logic_vector(31 downto 0);
  		ex_rt_data : out std_logic_vector(31 downto 0);
  		id_rs_sel : in std_logic_vector(4 downto 0);
  		id_rt_sel : in std_logic_vector(4 downto 0);
  		id_rd_sel : in std_logic_vector(4 downto 0);
  		ex_rs_sel : out std_logic_vector(4 downto 0);
  		ex_rt_sel : out std_logic_vector(4 downto 0);
  		ex_rd_sel : out std_logic_vector(4 downto 0);
  		id_extended_immediate : in std_logic_vector(31 downto 0);
  		ex_extended_immediate : out std_logic_vector(31 downto 0)
  	    );
END COMPONENT; 

COMPONENT if_id
	PORT(CLK            : in  std_logic;
  		id_flush, id_stall, ifid_reset : in std_logic;
       	if_instruction  : in std_logic_vector(31 downto 0);
       	id_instruction  : out std_logic_vector(31 downto 0);
       	if_pc_plus_4 : in std_logic_vector(31 downto 0);
       	id_pc_plus_4 : out std_logic_vector(31 downto 0));
END COMPONENT;

COMPONENT mem_wb
	PORT(CLK           : in  std_logic;
		wb_flush, wb_stall, memwb_reset : in std_logic;
		mem_instruction  : in std_logic_vector(31 downto 0); -- pass instruction along (useful for debugging)
        wb_instruction  : out std_logic_vector(31 downto 0);
        mem_pc_plus_4 : in std_logic_vector(31 downto 0);
       	wb_pc_plus_4 : out std_logic_vector(31 downto 0);

  	-- CONTROL signals
        mem_reg_dest   : in std_logic;
  	    mem_mem_to_reg : in std_logic;
  	    mem_reg_write  : in std_logic;
  	    wb_reg_dest   : out std_logic;
  	    wb_mem_to_reg : out std_logic;
  	    wb_reg_write  : out std_logic;
  	-- ALU signals
		mem_ALU_out : in std_logic_vector(31 downto 0);
		wb_ALU_out : out std_logic_vector(31 downto 0);
  	-- Memory signals
		mem_dmem_out : in std_logic_vector(31 downto 0);
		wb_dmem_out : out std_logic_vector(31 downto 0);
	-- Register signals
  		mem_write_reg_sel : in std_logic_vector(4 downto 0);
  		wb_write_reg_sel : out std_logic_vector(4 downto 0)
  	    );
END COMPONENT; 

COMPONENT branch_comparator
	PORT(i_rs_data, i_rt_data : in std_logic_vector(31 downto 0);
  	    o_equal : out std_logic);
END COMPONENT;

COMPONENT hazard_detect
	PORT(
	CLK				: in std_logic;
	jump			: in std_logic;
	branch 			: in std_logic;
	ex_memread		: in std_logic; 
	ex_reg_rt		: in std_logic_vector (4 downto 0);
	id_reg_rs		: in std_logic_vector (4 downto 0);
	id_reg_rt		: in std_logic_vector (4 downto 0);
	ex_write_regsel	: in std_logic_vector (4 downto 0);
	if_flush 		: out std_logic;
	id_flush		: out std_logic;
	pc_stall		: out std_logic;
	id_stall 		: out std_logic);
END COMPONENT;

COMPONENT forwarding_unit
	PORT(
	CLK 			: in std_logic;
	rd_mem 			: in std_logic_vector(4 downto 0);
	rd_wb 			: in std_logic_vector(4 downto 0);
	rs_sel 			: in std_logic_vector(4 downto 0);
	rt_sel 			: in std_logic_vector(4 downto 0);
	reg_write_mem 	: in std_logic;
	reg_write_wb 	: in std_logic;
	rs_mux 			: out std_logic_vector(1 downto 0);
	rt_mux 			: out std_logic_vector(1 downto 0));
END COMPONENT;




SIGNAL	i_nxt_PC :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	o_F         	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);    --PC + 4 Value ??
SIGNAL 	o_if_id_F	: STD_LOGIC_VECTOR(31 downto 0);
SIGNAL	ex_pc_plus_4	: STD_LOGIC_VECTOR(31 downto 0);
SIGNAL	mem_pc_plus_4	: STD_LOGIC_VECTOR(31 downto 0);
SIGNAL	wb_pc_plus_4	: STD_LOGIC_VECTOR(31 downto 0);
SIGNAL	o_F_secondadder  :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	write_sel 	 	 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	mem_write_reg_sel 	 	 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	wb_write_reg_sel 	 	 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	o_PC		 	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	q_imem 			 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	id_instuction	: STD_LOGIC_VECTOR(31 downto 0);
SIGNAL	ex_instuction	: STD_LOGIC_VECTOR(31 downto 0);
SIGNAL	mem_instuction	: STD_LOGIC_VECTOR(31 downto 0);
SIGNAL	wb_instuction	: STD_LOGIC_VECTOR(31 downto 0);
SIGNAL	rs_data 	  	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	rt_data 	 	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ex_rs_data 	  	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ex_rt_data 	 	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	mem_rt_data 	 	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	o_signextend 	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ex_extended_immediate 	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ib_alu       	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ALU_OP 		 	 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	ex_ALU_OP		: STD_LOGIC_VECTOR(3 downto 0);
-----SIGNAL	i_write_data     :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ALU_out 	 	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	dmem_q 		 	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	wb_dmem_out 		 	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	shift_signextend :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	branch_mux    :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	jumpaddress       :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	shifted          :  STD_LOGIC_VECTOR(27 DOWNTO 0);
SIGNAL 	ex_rs_sel 		:	std_logic_vector(4 downto 0);
SIGNAL 	ex_rt_sel 		:  	std_logic_vector(4 downto 0);
SIGNAL	ex_rd_sel 		:  	std_logic_vector(4 downto 0);
SIGNAL 	i_ALU_1			:	std_logic_vector(31 downto 0);
SIGNAL 	i_ALU_2			:	std_logic_vector(31 downto 0);
SIGNAL 	o_dmem_mux		:	std_logic_vector(31 downto 0);
SIGNAL 	mem_ALU_out		:	std_logic_vector(31 downto 0);
SIGNAL 	wb_ALU_out		:	std_logic_vector(31 downto 0);
SIGNAL 	rs_mux			:	std_logic_vector(1 downto 0);	
SIGNAL 	rt_mux			:	std_logic_vector(1 downto 0);

SIGNAL	zero_out 	 :  STD_LOGIC;
SIGNAL	jump         :  STD_LOGIC;
SIGNAL	branch       :  STD_LOGIC;
SIGNAL	ex_branch	: STD_LOGIC;
SIGNAL	ALU_SRC    	 :  STD_LOGIC;
SIGNAL	ex_ALU_SRC	: STD_LOGIC; 
SIGNAL	mem_write :  STD_LOGIC;
SIGNAL	ex_mem_write	: STD_LOGIC;
SIGNAL	mem_mem_write	: STD_LOGIC;
SIGNAL	mem_to_reg   :  STD_LOGIC;
SIGNAL	ex_mem_to_reg	: STD_LOGIC;
SIGNAL	mem_mem_to_reg	: STD_LOGIC;
SIGNAL	wb_mem_to_reg	: STD_LOGIC;
SIGNAL	reg_write    :  STD_LOGIC;
SIGNAL	ex_reg_write	: STD_LOGIC;
SIGNAL	mem_reg_write	: STD_LOGIC;
SIGNAL	wb_reg_write	: STD_LOGIC;
SIGNAL	reg_dest     :  STD_LOGIC;
SIGNAL	ex_reg_dest	: STD_LOGIC;
SIGNAL	mem_reg_dest	: STD_LOGIC;
SIGNAL	wb_reg_dest	: STD_LOGIC;
SIGNAL	and_gate 	 :  STD_LOGIC;
SIGNAL	flush		: STD_LOGIC;
SIGNAL	o_equal		: STD_LOGIC;
SIGNAL hazard_mux 	: STD_LOGIC;
SIGNAL if_flush		: STD_LOGIC;
SIGNAL id_flush		: STD_LOGIC;
SIGNAL pc_stall		: STD_LOGIC;
SIGNAL id_stall		: STD_LOGIC;

BEGIN 

g_inst1 : pc_reg
PORT MAP(CLK => CLK,
		 reset => RST,
		 stall => pc_stall,
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
		 i_B => X"00000004",
		 o_F => o_F);

		 
g_inst4 : main_control
PORT MAP(i_instruction => id_instuction,
		 o_reg_dest => reg_dest,
		 o_jump => jump,
		 o_branch => branch,
		 o_mem_to_reg => mem_to_reg,
		 o_mem_write => mem_write,
		 o_ALU_src => ALU_SRC,
		 o_reg_write => reg_write,
		 o_ALU_op => ALU_OP);

g_inst5 : mux21_5bit    ------------------------mux to select write register
PORT MAP(i_sel => ex_reg_dest,
		 i_0 => ex_rt_sel,
		 i_1 => ex_rd_sel,
		 o_mux => write_sel);
		 
g_inst6 : register_file
PORT MAP(CLK => CLK,
		 w_en => wb_reg_write,
		 reset => RST,
		 rs_sel => id_instuction(25 DOWNTO 21),
		 rt_sel => id_instuction(20 DOWNTO 16),
		 w_data => o_dmem_mux,
		 w_sel =>   wb_write_reg_sel,
		 rs_data => rs_data,
		 rt_data => rt_data);
		 
g_inst7 : sign_extender_16_32
PORT MAP(i_to_extend => id_instuction(15 DOWNTO 0),
		 o_extended => o_signextend);
		 
g_inst8 : mux21_32bit   -------------------mux going into ALU 
PORT MAP(i_sel => ex_ALU_SRC,
		 i_0 => i_ALU_2,
		 i_1 => ex_extended_immediate,
		 o_mux => ib_alu);
		 
g_inst9 : ALU
PORT MAP(ALU_OP => ex_ALU_OP,
		 i_A => i_ALU_1,
		 i_B => ib_alu,
		 shamt => ex_instuction(10 DOWNTO 6), 
		 zero => zero_out,
		 ALU_out => ALU_out);


g_inst10 : dmem
GENERIC MAP(depth_exp_of_2 => 10,
			mif_filename => "dmem.mif"
			)
PORT MAP(clock => CLK,
		 wren => mem_mem_write,
		 address => mem_ALU_out(11 DOWNTO 2),
		 byteena => "1111",
		 data => mem_rt_data,
		 q => dmem_q);
		 
g_inst11 : mux21_32bit       -------------------------mux after dmem
PORT MAP(i_sel => wb_mem_to_reg,
		 i_0 => wb_ALU_out,
		 i_1 => wb_dmem_out,
		 o_mux => o_dmem_mux);
		 
		 
g_inst12 : sll_2
PORT MAP(i_to_shift => o_signextend,
		 o_shifted => shift_signextend);
		 
g_inst13 : and_2
PORT MAP(i_A => branch,
		 i_B => o_equal,
		 o_F => and_gate);


g_inst14 : adder_32
PORT MAP(i_A => o_if_id_F,
		 i_B => shift_signextend,
		 o_F => o_F_secondadder);


g_inst15 : mux21_32bit -----------------------mux to select if we are branching 
PORT MAP(i_sel => and_gate,
		 i_0 => o_F,
		 i_1 => o_F_secondadder,
		 o_mux => branch_mux);


g_inst16 : mux21_32bit ---------------mux to see if we are jumping
PORT MAP(i_sel => jump,
		 i_0 => branch_mux,
		 i_1 => jumpaddress,
		 o_mux => i_nxt_PC);
		 
g_inst17 : sll_2_25
PORT MAP(i_to_shift => id_instuction(25 DOWNTO 0),
		 o_shifted => shifted);

g_inst18 : jump_extra
PORT MAP(i_from_adder => o_if_id_F(31 downto 28),
		 i_from_sll => shifted,
		 o_shifted => jumpaddress);

g_inst28 : if_id
PORT MAP(CLK => CLK,
		 id_flush => if_flush,
		 id_stall => id_stall,
		 ifid_reset => '0',
		 if_instruction => q_imem,
		 id_instruction => id_instuction,
		 if_pc_plus_4 => o_F,
		 id_pc_plus_4 => o_if_id_F
		 );
		 
g_inst19 : branch_comparator
PORT MAP(i_rs_data => rs_data,
		i_rt_data => rt_data,
		o_equal => o_equal
		);
	
g_inst20 : id_ex 
PORT MAP(CLK => CLK,
		ex_flush => id_flush,
		ex_stall => '0',
		idex_reset => '0',
		id_instruction => id_instuction,
		ex_instruction => ex_instuction,
		id_pc_plus_4 => o_if_id_F,
		ex_pc_plus_4 => ex_pc_plus_4,
		id_reg_dest	=> reg_dest,
        id_branch	=> branch,
        id_mem_to_reg	=> mem_to_reg,
        id_ALU_op	=> ALU_OP,
        id_mem_write	=>	mem_write,
		id_ALU_src	=> ALU_SRC,
		id_reg_write	=> reg_write,
		ex_reg_dest	=>  ex_reg_dest,
		ex_branch 	=> 	ex_branch,
		ex_mem_to_reg	=> ex_mem_to_reg,
		ex_ALU_op	=> 	ex_ALU_OP,
		ex_mem_write	=> ex_mem_write,
		ex_ALU_src	=> 	ex_ALU_SRC,
		ex_reg_write	=> ex_reg_write,
		id_rs_data	=>	rs_data,
		id_rt_data	=>	rt_data,
		ex_rs_data	=>	ex_rs_data,
		ex_rt_data	=>	ex_rt_data,
		id_rs_sel 	=>	id_instuction(25 DOWNTO 21),
		id_rt_sel 	=>	id_instuction(20 DOWNTO 16),
		id_rd_sel 	=>	id_instuction(15 DOWNTO 11),
		ex_rs_sel 	=>  ex_rs_sel,
		ex_rt_sel 	=>	ex_rt_sel,
		ex_rd_sel	=> 	ex_rd_sel,
		id_extended_immediate	=> o_signextend,
		ex_extended_immediate	=> ex_extended_immediate
		); 
		
g_inst21 : mux31_32bit     -----3 to 1 rs data mux
PORT MAP(i_sel => rs_mux,
			i_0 => ex_rs_data,
			i_1 => mem_ALU_out, 
			i_2 => o_dmem_mux,
			o_mux => i_ALU_1
		);

g_inst22 : mux31_32bit    ---------3 to 1 rt data mux
PORT MAP(i_sel => rt_mux,
				i_0 => ex_rt_data,
				i_1 => mem_ALU_out,
				i_2 => o_dmem_mux,
				o_mux => i_ALU_2
			);
			
g_inst23 : ex_mem
PORT MAP(CLK => CLK, 
		mem_flush		 => '0',
		mem_stall		 => '0', 
		exmem_reset		 => '0', 
		ex_instruction	 => ex_instuction,
		mem_instruction	 =>	mem_instuction,
		ex_pc_plus_4	 => ex_pc_plus_4,	
		mem_pc_plus_4 	 => mem_pc_plus_4,
		ex_reg_dest   	 => ex_reg_dest,
		ex_mem_to_reg 	 =>	ex_mem_to_reg,
		ex_mem_write  	 =>	ex_mem_write,
		ex_reg_write  	 => ex_reg_write,
		mem_reg_dest  	 => mem_reg_dest,
		mem_mem_to_reg 	 => mem_mem_to_reg,
		mem_mem_write  	 => mem_mem_write,
		mem_reg_write  	 => mem_reg_write,
		ex_ALU_out 		 => ALU_out,
		mem_ALU_out 	 => mem_ALU_out,
		ex_rt_data 		 => i_ALU_2,
		mem_rt_data 	 => mem_rt_data,
		ex_write_reg_sel 	=> write_sel,
		mem_write_reg_sel	=> mem_write_reg_sel
		);
	
g_inst24 : mem_wb
PORT MAP(	CLK 			=> CLK, 
			wb_flush		=> '0',
			wb_stall 		=> '0', 
			memwb_reset		=> '0',
			mem_instruction	=> mem_instuction,
	        wb_instruction	=> wb_instuction,	
		    mem_pc_plus_4 	=>	mem_pc_plus_4,
		   	wb_pc_plus_4 	=>	wb_pc_plus_4,
		
		-- CONTROL signals
		    mem_reg_dest   	=>	mem_reg_dest,
		    mem_mem_to_reg 	=>	mem_mem_to_reg,
		    mem_reg_write  	=>	mem_reg_write,
		    wb_reg_dest   	=>	wb_reg_dest,
		    wb_mem_to_reg 	=>	wb_mem_to_reg,
		    wb_reg_write  	=>	wb_reg_write,
		-- END CONTROL signals
		
		-- ALU signals
			mem_ALU_out 	=>	mem_ALU_out,
			wb_ALU_out 		=>	wb_ALU_out,
		-- END ALU signals
		
		-- Memory signals
			mem_dmem_out 	=>	dmem_q,
			wb_dmem_out 	=>	wb_dmem_out,
		-- END Memory signals
		
		-- Register signals
			mem_write_reg_sel 	=>	mem_write_reg_sel,
			wb_write_reg_sel 	=>  wb_write_reg_sel
		-- END Register signals
		);
		
g_inst25 : mux21_1bit   ------------------mux for hazard detection DO WE NEED THIS ??????
PORT MAP( i_sel => '0',
			i_0 => reg_write,
			i_1 => '0',
			o_mux => hazard_mux
			); 
		
g_inst26 : hazard_detect
PORT MAP(
	CLK				=> CLK,
	jump			=> jump,
	branch 			=> branch,
	ex_memread		=> ex_mem_to_reg, 
	ex_reg_rt		=> ex_rt_sel,
	id_reg_rs		=> id_instuction(25 DOWNTO 21),
	id_reg_rt		=> id_instuction(20 DOWNTO 16),
	ex_write_regsel	=> write_sel,
	if_flush 		=> if_flush,
	id_flush		=> id_flush,
	pc_stall		=> pc_stall,
	id_stall 		=> id_stall);
	
g_inst27 : forwarding_unit
PORT MAP(
	CLK 			=>	CLK,			
	rd_mem 			=>  mem_write_reg_sel,
	rd_wb 			=>	wb_write_reg_sel,
	rs_sel 			=>  ex_rs_sel,
	rt_sel 			=>	ex_rt_sel,
	reg_write_mem 	=>  mem_reg_write,
	reg_write_wb 	=>	wb_reg_write,
	rs_mux 			=>	rs_mux,
	rt_mux          =>	rt_mux);			
		
END structure;