LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY finalprojectbpipelineprocessor IS 
	PORT
	(
		CLK :  IN  STD_LOGIC;
		RST :  IN  STD_LOGIC;
		input4 :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END finalprojectbpipelineprocessor;

ARCHITECTURE structure OF finalprojectbpipelineprocessor IS 

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

COMPONENT oor
	PORT(i_A : IN STD_LOGIC;
		 i_B : IN STD_LOGIC;
		 o_F : OUT STD_LOGIC
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

COMPONENT if_id
	port(CLK : in  std_logic;
  		id_flush, id_stall, ifid_reset : in std_logic;
       		if_instruction  : in std_logic_vector(31 downto 0);
       		id_instruction  : out std_logic_vector(31 downto 0);
       		if_pc_plus_4 : in std_logic_vector(31 downto 0);
       		id_pc_plus_4 : out std_logic_vector(31 downto 0)
	);
END COMPONENT;

COMPONENT id_ex
	port(CLK           : in  std_logic;
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
  	-- END CONTROL signals

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
  	-- END Register signals

  		id_extended_immediate : in std_logic_vector(31 downto 0);
  		ex_extended_immediate : out std_logic_vector(31 downto 0)
  	    );
END COMPONENT;

COMPONENT ex_mem
	port(CLK           : in  std_logic;
		mem_flush, mem_stall, exmem_reset : in std_logic;
		ex_instruction  : in std_logic_vector(31 downto 0);
        mem_instruction  : out std_logic_vector(31 downto 0);
        ex_pc_plus_4 : in std_logic_vector(31 downto 0);
       	mem_pc_plus_4 : out std_logic_vector(31 downto 0);

  	-- CONTROL signals
        ex_reg_dest   : in std_logic;
  	    ex_mem_to_reg : in std_logic;
  	    ex_mem_write  : in std_logic;
  	    ex_reg_write  : in std_logic;
  	    mem_reg_dest   : out std_logic;
  	    mem_mem_to_reg : out std_logic;
  	    mem_mem_write  : out std_logic;
  	    mem_reg_write  : out std_logic;
  	-- END CONTROL signals

  	-- ALU signals
		ex_ALU_out : in std_logic_vector(31 downto 0);
		mem_ALU_out : out std_logic_vector(31 downto 0);
  	-- END ALU signals

	-- Register signals
		ex_rt_data : in std_logic_vector(31 downto 0);
		mem_rt_data : out std_logic_vector(31 downto 0);
  		ex_write_reg_sel : in std_logic_vector(4 downto 0); 
  		mem_write_reg_sel : out std_logic_vector(4 downto 0)
  	-- END Register signals
  	    );
END COMPONENT;

COMPONENT mem_wb
	port(CLK           : in  std_logic;
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
  	-- END CONTROL signals

  	-- ALU signals
		mem_ALU_out : in std_logic_vector(31 downto 0);
		wb_ALU_out : out std_logic_vector(31 downto 0);
  	-- END ALU signals

  	-- Memory signals
		mem_dmem_out : in std_logic_vector(31 downto 0);
		wb_dmem_out : out std_logic_vector(31 downto 0);
  	-- END Memory signals

	-- Register signals
  		mem_write_reg_sel : in std_logic_vector(4 downto 0);
  		wb_write_reg_sel : out std_logic_vector(4 downto 0)
  	-- END Register signals
  	    );
END COMPONENT;

COMPONENT hazard_detect
	port(
	CLK				: in std_logic;
	jump			: in std_logic;
	branch 			: in std_logic;
	branch_taken 		: in std_logic;
	ex_memread		: in std_logic; 
	ex_reg_rt		: in std_logic_vector (4 downto 0);
	id_reg_rs		: in std_logic_vector (4 downto 0);
	id_reg_rt		: in std_logic_vector (4 downto 0);
	ex_write_regsel	: in std_logic_vector (4 downto 0);
	pc_stall   	 	: out std_logic;
	id_flush 		: out std_logic;
	id_stall 		: out std_logic;
	ex_flush		: out std_logic
);
END COMPONENT;



COMPONENT branch_comparator
	port( i_rs_data, i_rt_data : in std_logic_vector(31 downto 0);
  	    o_equal : out std_logic); 
END COMPONENT;

COMPONENT forwarding_unit
	port(CLK : in std_logic;
	rd_mem : in std_logic_vector(4 downto 0);
	rd_wb : in std_logic_vector(4 downto 0);
	rs_sel : in std_logic_vector(4 downto 0);
	rt_sel : in std_logic_vector(4 downto 0);
	reg_write_mem : in std_logic;
	reg_write_wb : in std_logic;
	mem_read : in std_logic;
	rs_mux : out std_logic_vector(1 downto 0);
	rt_mux : out std_logic_vector(1 downto 0)
  );
END COMPONENT;

COMPONENT mux31_32bit
 port( i_0, i_1, i_2 : in std_logic_vector(31 downto 0);
  		i_sel : in std_logic_vector(1 downto 0);
  	    o_mux : out std_logic_vector(31 downto 0));
END COMPONENT;

COMPONENT ec_logic
	 port(i_write_data_in	: in std_logic_vector(4 downto 0);
	rs_data_in	: in std_logic_vector(4 downto 0);
	rt_data_in	: in std_logic_vector(4 downto 0);
	rs_bypass	: out std_logic;
	rt_bypass	: out std_logic
  );
END COMPONENT;


SIGNAL	i_nxt_PC :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	branch_jump_PC :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL  is_branch_jump : STD_LOGIC;
SIGNAL	o_F         	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	o_F_id         	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL  o_F_ex           :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL  o_F_mem           :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL  o_F_wb           :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	o_F_secondadder  :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	write_sel 	 	 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	o_PC		 	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	q_imem 			 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	q_imem_id 		 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	q_imem_ex 		 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	q_imem_mem 		 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	q_imem_wb 		 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	rs_data 	  	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	rs_data_2 	  	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	rs_data_ex 	  	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	rt_data 	 	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	rt_data_2 	 	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	rs_into_compar	 	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	rt_into_compar	 	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	rt_data_ex 	  	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	rt_data_mem 	  	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	o_signextend 	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	o_signextend_ex 	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ib_alu       	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ALU_in_rs       	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ALU_in_rt       	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL rs_mux_w			:STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL rt_mux_w			:STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL rs_mux_branch			:STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL rt_mux_branch			:STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	ALU_OP 		 	 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	ALU_OP_ex 		 	 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	i_write_data     :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ALU_out 	 	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ALU_out_mem 	 	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ALU_out_wb 	 	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	dmem_q 		 	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	dmem_q_wb 		 	 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	shift_signextend :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	jumpadress       :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	shifted          :  STD_LOGIC_VECTOR(27 DOWNTO 0);

SIGNAL	zero_out 	 :  STD_LOGIC;
SIGNAL	jump         :  STD_LOGIC;
SIGNAL	branch       :  STD_LOGIC;
SIGNAL	branch_ex       :  STD_LOGIC;
SIGNAL	ALU_SRC    	 :  STD_LOGIC;
SIGNAL	ALU_SRC_ex    	 :  STD_LOGIC;
SIGNAL	mem_write :  STD_LOGIC;
SIGNAL	mem_write_ex :  STD_LOGIC;
SIGNAL	mem_write_mem :  STD_LOGIC;
SIGNAL	mem_to_reg   :  STD_LOGIC;
SIGNAL	mem_to_reg_ex   :  STD_LOGIC;
SIGNAL	mem_to_reg_mem   :  STD_LOGIC;
SIGNAL	mem_to_reg_wb   :  STD_LOGIC;
SIGNAL	reg_write    :  STD_LOGIC;
SIGNAL	reg_write_ex    :  STD_LOGIC;
SIGNAL	reg_write_mem    :  STD_LOGIC;
SIGNAL	reg_write_wb    :  STD_LOGIC;
SIGNAL	reg_dest     :  STD_LOGIC;
SIGNAL	reg_dest_ex     :  STD_LOGIC;
SIGNAL	reg_dest_mem     :  STD_LOGIC;
SIGNAL	reg_dest_wb     :  STD_LOGIC;


SIGNAL	rs_sel_ex         :  STD_LOGIC_VECTOR(4 DOWNTO 0);	
SIGNAL	rt_sel_ex         :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	rd_sel_ex         :  STD_LOGIC_VECTOR(4 DOWNTO 0);		 	 
SIGNAL	rd_sel_mem         :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	rd_sel_wb         :  STD_LOGIC_VECTOR(4 DOWNTO 0);	 	 
SIGNAL branch_taken	: STD_LOGIC;
SIGNAL branch_and_taken : STD_LOGIC;
SIGNAL id_flush_w : STD_LOGIC;
SIGNAL pc_stall : STD_LOGIC;
SIGNAL ex_flush_w : STD_LOGIC;
SIGNAL id_stall_w : STD_LOGIC;

SIGNAL rs_bypass_w : STD_LOGIC;
SIGNAL rt_bypass_w : STD_LOGIC;


BEGIN 


g_inst32 : ec_logic
PORT MAP(i_write_data_in => rd_sel_wb,
	rs_data_in => q_imem_id(25 downto 21),
	rt_data_in => q_imem_id(20 downto 16),
	rs_bypass => rs_bypass_w,
	rt_bypass => rt_bypass_w
);

g_inst33 : mux21_32bit
PORT MAP(i_sel => rs_bypass_w,
		 i_0 => rs_data,
		 i_1 => i_write_data,
		 o_mux => rs_data_2);
g_inst34 : mux21_32bit
PORT MAP(i_sel => rt_bypass_w,
		 i_0 => rt_data,
		 i_1 => i_write_data,
		 o_mux => rt_data_2);

g_inst31 : forwarding_unit
PORT MAP(CLK => CLK,
	rd_mem => rd_sel_mem,
	rd_wb => rd_sel_wb,
	rs_sel => q_imem_id(25 DOWNTO 21),
	rt_sel => q_imem_id(20 DOWNTO 16),
	reg_write_mem => reg_write_mem,
	reg_write_wb => reg_write_wb,
	rs_mux => rs_mux_branch,
	rt_mux => rt_mux_branch,
	mem_read => mem_to_reg_mem
  	);

g_inst29 : mux31_32bit
 PORT MAP( i_0 => rs_data,
		i_1 => ALU_out_mem,
		i_2 => i_write_data,
  		i_sel => rs_mux_branch,
  	    	o_mux => rs_into_compar
		);

g_inst30 : mux31_32bit
 PORT MAP( i_0 => rt_data,
		i_1 => ALU_out_mem,
		i_2 => i_write_data,
  		i_sel => rt_mux_branch,
  	    	o_mux => rt_into_compar
		);	
g_inst24 : branch_comparator
PORT MAP( i_rs_data => rs_into_compar,
		i_rt_data =>rt_into_compar,
  	    o_equal => branch_taken); 

g_inst23 : mux21_32bit
PORT MAP(i_sel => is_branch_jump,
		 i_0 => o_F,
		 i_1 => branch_jump_PC,
		 o_mux => i_nxt_PC);
g_inst1 : pc_reg
PORT MAP(CLK => CLK,
		 reset => RST,
		 stall => pc_stall,
		 i_next_PC => i_nxt_PC,
		 o_PC => o_PC);
		 
 
g_inst3 : adder_32
PORT MAP(i_A => o_PC,
		 i_B => input4,
		 o_F => o_F);

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
		 
g_inst19 : if_id
PORT MAP(if_instruction => q_imem,
		if_pc_plus_4 => o_F,
		id_instruction => q_imem_id,
		id_pc_plus_4 => o_F_id,
		CLK => CLK,
		id_flush => id_flush_w,
		id_stall => id_stall_w,
		ifid_reset => RST
		);

---------------------------------------------------------ID COMPONENTS
g_inst4 : main_control
PORT MAP(i_instruction => q_imem_id,
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
		 i_0 => q_imem_id(20 downto 16),
		 i_1 => q_imem_id(15 downto 11),
		 o_mux => write_sel);
		 
g_inst6 : register_file
PORT MAP(CLK => CLK,
		 w_en => reg_write_wb,
		 reset => RST,
		 rs_sel => q_imem_id(25 DOWNTO 21),
		 rt_sel => q_imem_id(20 DOWNTO 16),
		 w_data => i_write_data,
		 w_sel => rd_sel_wb,
		 rs_data => rs_data,
		 rt_data => rt_data);
		 
g_inst7 : sign_extender_16_32
PORT MAP(i_to_extend => q_imem_id(15 DOWNTO 0),
		 o_extended => o_signextend);


--shift left 2 before adder		 
g_inst12 : sll_2
PORT MAP(i_to_shift => o_signextend,
		 o_shifted => shift_signextend);
		 
g_inst13 : oor
PORT MAP(i_A => jump,
		 i_B => branch_and_taken,
		 o_F => is_branch_jump);
g_inst15 : and_2
PORT MAP(i_A => branch,
		 i_B => branch_taken,
		 o_F => branch_and_taken);

g_inst14 : adder_32
PORT MAP(i_A => o_F_id,
		 i_B => shift_signextend,
		 o_F => o_F_secondadder);




g_inst16 : mux21_32bit
PORT MAP(i_sel => jump,
		 i_0 => o_F_secondadder,
		 i_1 => jumpadress,
		 o_mux => branch_jump_PC);
		 
g_inst17 : sll_2_25
PORT MAP(i_to_shift => q_imem_id(25 DOWNTO 0),
		 o_shifted => shifted);

g_inst18 : jump_extra
PORT MAP(i_from_adder => o_F_id(31 DOWNTO 28),
		 i_from_sll => shifted,
		 o_shifted => jumpadress);
		 
g_inst28 : hazard_detect
PORT MAP(CLK => CLK,			
	jump =>	jump,		
	branch => branch,
	branch_taken => branch_and_taken,	
	ex_memread => mem_to_reg_ex,
	ex_reg_rt => rt_sel_ex,		
	id_reg_rs => q_imem_id(25 DOWNTO 21),
	id_reg_rt => q_imem_id(20 DOWNTO 16),
	ex_write_regsel	=> rd_sel_ex,
	pc_stall => pc_stall,
	id_flush => id_flush_w,
	id_stall => id_stall_w,
	ex_flush => ex_flush_w
	);
	
	
g_inst20 : id_ex
PORT MAP(id_instruction => q_imem_id,
		id_pc_plus_4 => o_F_id,
		ex_instruction => q_imem_ex,
		ex_pc_plus_4 => o_F_ex,
		CLK => CLK,
		ex_flush => ex_flush_w,
		idex_reset => RST,
		ex_stall => '0',
		id_rs_data => rs_data_2,
  		id_rt_data => rt_data_2,
  		ex_rs_data => rs_data_ex, 
  		ex_rt_data => rt_data_ex,
  		id_rs_sel => q_imem_id(25 DOWNTO 21),
  		id_rt_sel => q_imem_id(20 DOWNTO 16),
  		id_rd_sel => write_sel,
  		ex_rs_sel => rs_sel_ex,
  		ex_rt_sel => rt_sel_ex,
  		ex_rd_sel => rd_sel_ex,

		id_reg_dest => reg_dest,
  	   	id_branch => branch,
  	    	id_mem_to_reg => mem_to_reg,
  	    	id_ALU_op => ALU_OP,
  	    	id_mem_write => mem_write,
  	    	id_ALU_src => ALU_SRC,
  	    	id_reg_write => reg_write,
  	    	ex_reg_dest => reg_dest_ex,
  	    	ex_branch => branch_ex,
  	    	ex_mem_to_reg => mem_to_reg_ex,
  	    	ex_ALU_op => ALU_OP_ex,
  	    	ex_mem_write => mem_write_ex,
  	    	ex_ALU_src => ALU_SRC_ex,
  	    	ex_reg_write => reg_write_ex,
		id_extended_immediate => o_signextend,
  		ex_extended_immediate => o_signextend_ex
		);
		 
g_inst8 : mux21_32bit
PORT MAP(i_sel => ALU_SRC_ex,
		 i_0 => ALU_in_rt,
		 i_1 => o_signextend_ex,
		 o_mux => ib_alu);

g_inst25 : mux31_32bit
 PORT MAP( i_0 => rs_data_ex,
		i_1 => ALU_out_mem,
		i_2 => i_write_data,
  		i_sel => rs_mux_w,
  	    	o_mux => ALU_in_rs
		);

g_inst26 : mux31_32bit
 PORT MAP( i_0 => rt_data_ex,
		i_1 => ALU_out_mem,
		i_2 => i_write_data,
  		i_sel => rt_mux_w,
  	    	o_mux => ALU_in_rt
		);		
g_inst27 : forwarding_unit
PORT MAP(CLK => CLK,
	rd_mem => rd_sel_mem,
	rd_wb => rd_sel_wb,
	rs_sel => rs_sel_ex,
	rt_sel => rt_sel_ex,
	reg_write_mem => reg_write_mem,
	reg_write_wb => reg_write_wb,
	rs_mux => rs_mux_w,
	rt_mux => rt_mux_w,
	mem_read => mem_to_reg_mem
  	);
g_inst9 : ALU
PORT MAP(ALU_OP => ALU_OP_ex,
		 i_A =>  ALU_in_rs,
		 i_B => ib_alu,
		 shamt => q_imem_ex(10 DOWNTO 6),
		 zero => zero_out,
		 ALU_out => ALU_out);

g_inst21 : ex_mem
  port map(CLK => CLK,
		mem_flush => '0',
		mem_stall => '0',
		exmem_reset => RST,
		ex_instruction =>q_imem_ex,
        	mem_instruction =>q_imem_mem,
        	ex_pc_plus_4 => o_F_ex,
       		mem_pc_plus_4 => o_F_mem,

  	-- CONTROL signals
            ex_reg_dest => reg_dest_ex,
  	    ex_mem_to_reg => mem_to_reg_ex,
  	    ex_mem_write => mem_write_ex,
  	    ex_reg_write => reg_write_ex,
  	    mem_reg_dest => reg_dest_mem,
  	    mem_mem_to_reg => mem_to_reg_mem,
  	    mem_mem_write => mem_write_mem,
  	    mem_reg_write => reg_write_mem,
  	-- END CONTROL signals

  	-- ALU signals
		ex_ALU_out => ALU_out,
		mem_ALU_out => ALU_out_mem,
  	-- END ALU signals

	-- Register signals
		ex_rt_data => rt_data_ex,
		mem_rt_data => rt_data_mem,
  		ex_write_reg_sel => rd_sel_ex,
  		mem_write_reg_sel => rd_sel_mem
  	-- END Register signals
  	    );


g_inst10 : dmem
GENERIC MAP(depth_exp_of_2 => 10,
			mif_filename => "dmem.mif"
			)
PORT MAP(clock => CLK,
		 wren => mem_write_mem,
		 address => ALU_out_mem(11 DOWNTO 2),
		 byteena => "1111",
		 data => rt_data_mem,
		 q => dmem_q);
--chooses between mem or alu to send to registers		 
g_inst11 : mux21_32bit
PORT MAP(i_sel => mem_to_reg_wb,
		 i_0 => ALU_out_wb,
		 i_1 => dmem_q_wb,
		 o_mux => i_write_data);
		 


g_isnt22 : mem_wb
PORT MAP(CLK => CLK,
	wb_flush => '0',
	wb_stall => '0',
	memwb_reset => RST,
	mem_instruction => q_imem_mem,
        wb_instruction => q_imem_wb,
        mem_pc_plus_4 => o_F_mem,
       	wb_pc_plus_4 => o_F_wb,

  	-- CONTROL signals
        mem_reg_dest => reg_dest_mem,
  	    mem_mem_to_reg =>mem_to_reg_mem,
  	    mem_reg_write => reg_write_mem,
  	    wb_reg_dest => reg_dest_wb,
  	    wb_mem_to_reg => mem_to_reg_wb,
  	    wb_reg_write => reg_write_wb,
  	-- END CONTROL signals

  	-- ALU signals
		mem_ALU_out => ALU_out_mem,
		wb_ALU_out => ALU_out_wb,
  	-- END ALU signals

  	-- Memory signals
		mem_dmem_out => dmem_q,
		wb_dmem_out => dmem_q_wb,
  	-- END Memory signals

	-- Register signals
  		mem_write_reg_sel => rd_sel_mem,
  		wb_write_reg_sel => rd_sel_wb
  	-- END Register signals
  	    );



END structure;