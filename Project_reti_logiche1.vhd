{\rtf1\ansi\ansicpg1252\cocoartf2761
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 ----------------------------------------------------------------------------------\
-- Company: \
-- Engineer: \
-- \
-- Create Date: 09/28/2024 11:20:26 PM\
-- Design Name: \
-- Module Name: project_reti_logiche - project_reti_logiche_arch\
-- Project Name: \
-- Target Devices: \
-- Tool Versions: \
-- Description: \
-- \
-- Dependencies: \
-- \
-- Revision:\
-- Revision 0.01 - File Created\
-- Additional Comments:\
-- \
----------------------------------------------------------------------------------\
\
\
library IEEE;\
use IEEE.STD_LOGIC_1164.ALL;\
\
-- Uncomment the following library declaration if using\
-- arithmetic functions with Signed or Unsigned values\
--use IEEE.NUMERIC_STD.ALL;\
\
-- Uncomment the following library declaration if instantiating\
-- any Xilinx leaf cells in this code.\
--library UNISIM;\
--use UNISIM.VComponents.all;\
\
entity project_reti_logiche is\
  port (\
        i_clk : in std_logic; \
        i_rst : in std_logic;\
        i_start : in std_logic;\
        i_add : in std_logic_vector(15 downto 0);\
        i_k : in std_logic_vector(9 downto 0);\
        \
        o_done : out std_logic;\
        \
        o_mem_addr : out std_logic_vector (15 downto 0);\
        i_mem_data : in std_logic_vector (7 downto 0);\
        o_mem_data : out std_logic_vector (7 downto 0);\
        o_mem_we : out std_logic;\
        o_mem_en : out std_logic\
    );\
end project_reti_logiche;\
\
architecture project_reti_logiche_arch of project_reti_logiche is\
\
component add_register is \
    Port (\
        i_clk   : in  std_logic;      \
        i_start : in std_logic;\
        i_rst : in  std_logic;       \
        input  : in  std_logic_vector (15 downto 0); \
        output : out std_logic_vector (15 downto 0); \
        enable_read_input : in std_logic;\
        enable_incr : in std_logic\
    );\
end component add_register;\
   \
component counter_k_register is\
Port (\
        i_clk   : in  std_logic;           \
        i_start : in std_logic;\
        i_rst: in  std_logic;           \
        input : in  std_logic_vector (9 downto 0); \
        output : out std_logic_vector (9 downto 0);  \
        enable_read_input : in std_logic;\
        enable_decr : in std_logic\
        );    \
end component counter_k_register;\
\
component credibility_register is \
Port(\
        i_clk : in std_logic; \
        i_start : in std_logic;\
        i_rst : in std_logic;\
        output : out std_logic_vector(7 downto 0);\
        enable_rst_31 : in std_logic;\
        enable_rst_0: in std_logic;\
        enable_decr_cred : in std_logic -- se w!= 0 allora viene attivato e mette la credibilit\'e0 a 31\
    );\
end component credibility_register;  \
\
component word_register is\
Port(\
        i_clk : in std_logic; \
        i_start : in std_logic;\
        i_rst : in std_logic;\
        input : in std_logic_vector(7 downto 0);\
        output : out std_logic_vector(7 downto 0);\
        enable_rst : in std_logic;\
        enable_read : in std_logic\
    );   \
end component word_register;\
\
component FSM is\
Port ( \
           i_clk : in std_logic;\
           i_rst : in std_logic;\
           i_start : in std_logic;\
           i_mem_data : in std_logic_vector(7 downto 0);\
           \
           data_k : in std_logic_vector(9 downto 0);\
           \
           o_done: out std_logic;\
           o_mem_en : out std_logic;\
           o_mem_we : out std_logic;\
           \
           en_rst_c_31 :  out std_logic;\
           en_rst_c_0 : out std_logic;\
           en_decr_cred : out std_logic;\
           \
           en_rst_k : out std_logic;\
           en_decr_k : out std_logic;\
           \
           en_rst_add : out std_logic;\
           en_incr_add : out std_logic;\
           \
           en_rst_w : out std_logic;\
           en_read_w : out std_logic;\
           \
           en_mux : out std_logic;\
           en_sel_mux :out std_logic\
\
           );\
end component FSM;\
\
component data_selector_mux is\
  Port ( \
  input_cred : in std_logic_vector(7 downto 0);\
  input_w : in std_logic_vector(7 downto 0);\
  enable : in std_logic;\
  sel : in std_logic;\
  output : out std_logic_vector (7 downto 0)\
  );\
end component data_selector_mux;\
\
--enable signals\
signal en_rst_k : std_logic;\
signal en_decr_k : std_logic;\
signal en_rst_add : std_logic;\
signal en_incr_add : std_logic;\
signal en_rst_w : std_logic;\
signal en_change_w : std_logic;\
signal en_reg_c_0 : std_logic;\
signal en_reg_c_31 : std_logic;\
signal en_reg_decr_c : std_logic;\
signal en_mux : std_logic;\
signal en_sel_mux : std_logic;\
\
--output signals\
signal data_k : std_logic_vector(9 downto 0); \
signal data_add : std_logic_vector(15 downto 0); \
signal data_inw : std_logic_vector(7 downto 0);\
signal data_inc : std_logic_vector(7 downto 0);\
\
begin\
\
counter : counter_k_register port map (\
        i_clk  => i_clk,  \
        i_rst => i_rst,       \
        i_start => i_start,\
        input => i_k,  \
        output => data_k,  \
        enable_read_input => en_rst_k,\
        enable_decr => en_decr_k\
);\
\
addregister : add_register port map (\
        i_clk => i_clk,      \
        i_start => i_start,\
        i_rst => i_rst,       \
        input  => i_add, \
        output => o_mem_addr, \
        enable_read_input => en_rst_add,\
        enable_incr => en_incr_add\
);\
\
credibilityregister : credibility_register port map (\
        i_clk => i_clk, \
        i_start => i_start,\
        i_rst => i_rst,\
        output => data_inc,\
        enable_rst_31 => en_reg_c_31,\
        enable_rst_0 => en_reg_c_0,\
        enable_decr_cred => en_reg_decr_c \
);\
\
wordregister : word_register port map (\
        i_clk => i_clk, \
        i_start => i_start,\
        i_rst => i_rst,\
        input => i_mem_data,\
        output => data_inw,\
        enable_rst => en_rst_w,\
        enable_read => en_change_w\
);\
\
fsm1 : FSM port map (\
           i_clk => i_clk,\
           i_rst => i_rst,\
           i_start => i_start,\
           i_mem_data => i_mem_data,\
           \
           data_k => data_k,\
           \
           o_done => o_done,\
           o_mem_en => o_mem_en,\
           o_mem_we => o_mem_we,\
           \
           en_rst_c_31 => en_reg_c_31,\
           en_rst_c_0 => en_reg_c_0,\
           en_decr_cred => en_reg_decr_c,\
           \
           en_rst_k => en_rst_k,\
           en_decr_k => en_decr_k,\
           \
           en_rst_add => en_rst_add,\
           en_incr_add => en_incr_add,\
           \
           en_rst_w => en_rst_w,\
           en_read_w => en_change_w,\
           \
           en_mux => en_mux,\
           en_sel_mux => en_sel_mux\
);\
\
dataselectormux : data_selector_mux port map ( \
  input_cred => data_inc,\
  input_w => data_inw,\
  enable => en_mux, \
  sel => en_sel_mux,\
  output => o_mem_data\
  );\
           \
end project_reti_logiche_arch;\
\
----------------------------------------------------------------------------------\
-- Company: \
-- Engineer: \
-- \
-- Create Date: 09/28/2024 11:24:00 PM\
-- Design Name: \
-- Module Name: counter_k_register - counter_k_register_arch\
-- Project Name: \
-- Target Devices: \
-- Tool Versions: \
-- Description: \
-- \
-- Dependencies: \
-- \
-- Revision:\
-- Revision 0.01 - File Created\
-- Additional Comments:\
-- \
----------------------------------------------------------------------------------\
\
\
library IEEE;\
use IEEE.STD_LOGIC_1164.ALL;\
use ieee.numeric_std.all;\
\
-- Uncomment the following library declaration if using\
-- arithmetic functions with Signed or Unsigned values\
use IEEE.NUMERIC_STD.ALL;\
\
-- Uncomment the following library declaration if instantiating\
-- any Xilinx leaf cells in this code.\
--library UNISIM;\
--use UNISIM.VComponents.all;\
\
entity counter_k_register is\
  Port (\
        i_clk   : in  std_logic; \
        i_rst : in  std_logic;           \
        i_start : in std_logic;\
        input : in  std_logic_vector (9 downto 0); \
        output: out std_logic_vector (9 downto 0);  \
        enable_read_input : in std_logic;\
        enable_decr : in std_logic\
    );\
end counter_k_register;\
\
architecture counter_k_register_arch of counter_k_register is\
    signal reg_data : std_logic_vector (9 downto 0); \
begin\
    output <= reg_data;\
    -- Processo per aggiornare il registro\
    process (i_clk, i_rst)\
    begin\
    \
        if i_rst = '1' then\
            reg_data <= (others => '0');\
        elsif i_clk'event and i_clk = '1' then\
            --first address \
            if enable_read_input ='1' and i_start='1'  then\
                reg_data <= std_logic_vector(unsigned(input));\
                \
            elsif enable_decr = '1' and i_start = '1' then\
                reg_data <= std_logic_vector(unsigned(reg_data)-1);\
            end if;\
        end if;\
    end process;\
\
end counter_k_register_arch;\
\
----------------------------------------------------------------------------------\
-- Company: \
-- Engineer: \
-- \
-- Create Date: 09/28/2024 11:33:53 PM\
-- Design Name: \
-- Module Name: add_register - add_register_arch\
-- Project Name: \
-- Target Devices: \
-- Tool Versions: \
-- Description: \
-- \
-- Dependencies: \
-- \
-- Revision:\
-- Revision 0.01 - File Created\
-- Additional Comments:\
-- \
----------------------------------------------------------------------------------\
\
\
library IEEE;\
use IEEE.STD_LOGIC_1164.ALL;\
use IEEE.NUMERIC_STD.ALL;\
use ieee.numeric_std.all;\
\
-- Uncomment the following library declaration if using\
-- arithmetic functions with Signed or Unsigned values\
use IEEE.NUMERIC_STD.ALL;\
\
-- Uncomment the following library declaration if instantiating\
-- any Xilinx leaf cells in this code.\
--library UNISIM;\
--use UNISIM.VComponents.all;\
\
entity add_register is\
  Port (\
        i_clk   : in  std_logic;      \
        i_start : in std_logic;\
        i_rst : in  std_logic;       \
        input  : in  std_logic_vector (15 downto 0); \
        output : out std_logic_vector (15 downto 0); \
        enable_read_input : in std_logic;\
        enable_incr : in std_logic\
    );\
end add_register;\
\
architecture add_register_arch of add_register is\
    signal stored_value : std_logic_vector(15 downto 0); \
begin\
\
    -- Processo per aggiornare il registro\
    process (i_clk, i_rst)\
    begin\
        if i_rst = '1' then\
            stored_value <= (others => '0');\
\
        elsif i_clk'event and i_clk = '1' then\
            if enable_read_input ='1' and i_start='1' then\
                stored_value <= std_logic_vector(unsigned(input));\
                \
		    elsif enable_incr ='1' and i_start ='1' then\
                stored_value <= std_logic_vector(unsigned(stored_value) + 1);\
              \
            end if;\
       end if; \
    end process;\
    output <= stored_value;\
end add_register_arch;\
\
----------------------------------------------------------------------------------\
-- Company: \
-- Engineer: \
-- \
-- Create Date: 09/29/2024 12:02:17 AM\
-- Design Name: \
-- Module Name: credibility_register - credibility_register_arch\
-- Project Name: \
-- Target Devices: \
-- Tool Versions: \
-- Description: \
-- \
-- Dependencies: \
-- \
-- Revision:\
-- Revision 0.01 - File Created\
-- Additional Comments:\
-- \
----------------------------------------------------------------------------------\
\
\
library IEEE;\
use IEEE.STD_LOGIC_1164.ALL;\
use IEEE.NUMERIC_STD.ALL;\
use ieee.numeric_std.all;\
\
-- Uncomment the following library declaration if using\
-- arithmetic functions with Signed or Unsigned values\
use IEEE.NUMERIC_STD.ALL;\
\
-- Uncomment the following library declaration if instantiating\
-- any Xilinx leaf cells in this code.\
--library UNISIM;\
--use UNISIM.VComponents.all;\
\
entity credibility_register is\
port(\
        i_clk : in std_logic; \
        i_start : in std_logic;\
        i_rst : in std_logic;\
        --input: in std_logic_vector(7 downto 0);\
        output : out std_logic_vector(7 downto 0);\
        enable_rst_31 : in std_logic;\
        enable_rst_0: in std_logic;\
        enable_decr_cred : in std_logic -- se w!= 0 allora viene attivato e mette la credibilit\'e0 a 31\
    );\
end credibility_register;\
\
architecture credibility_register_arch of credibility_register is\
    signal stored_value : std_logic_vector(7 downto 0);\
    \
begin\
    \
    process(i_clk,i_rst)\
    begin\
    \
        if i_rst = '1' then\
            stored_value <= "00000000";\
\
        elsif i_clk'event and i_clk = '1'  then\
           if i_start = '1' then\
                if enable_rst_31 = '1' then \
                    stored_value <= "00011111";\
\
		        elsif enable_decr_cred = '1' then\
		          if stored_value/= "00000000" then\
			        stored_value <= std_logic_vector(unsigned(stored_value) - 1);\
			      \
			      else\
			         stored_value <= stored_value;\
			      end if;\
			    \
		        elsif enable_rst_0 = '1' then\
			        stored_value <= "00000000";\
			\
 	            end if;\
 	        end if;\
        end if;   \
        \
   end process;\
   output <= stored_value;\
   \
end credibility_register_arch;\
\
----------------------------------------------------------------------------------\
-- Company: \
-- Engineer: \
-- \
-- Create Date: 09/28/2024 11:59:14 PM\
-- Design Name: \
-- Module Name: word_register - word_register_arch\
-- Project Name: \
-- Target Devices: \
-- Tool Versions: \
-- Description: \
-- \
-- Dependencies: \
-- \
-- Revision:\
-- Revision 0.01 - File Created\
-- Additional Comments:\
-- \
----------------------------------------------------------------------------------\
\
\
library IEEE;\
use IEEE.STD_LOGIC_1164.ALL;\
\
-- Uncomment the following library declaration if using\
-- arithmetic functions with Signed or Unsigned values\
use IEEE.NUMERIC_STD.ALL;\
\
-- Uncomment the following library declaration if instantiating\
-- any Xilinx leaf cells in this code.\
--library UNISIM;\
--use UNISIM.VComponents.all;\
\
entity word_register is\
  port(\
        i_clk : in std_logic; \
        i_start : in std_logic;\
        i_rst : in std_logic;\
        input : in std_logic_vector(7 downto 0);\
        output : out std_logic_vector(7 downto 0);\
        enable_rst : in std_logic;\
        enable_read : in std_logic\
    );\
end word_register;\
\
architecture word_register_arch of word_register is\
    signal stored_value : std_logic_vector(7 downto 0);  -- Valore attualmente memorizzato\
    signal last_valid_value : std_logic_vector(7 downto 0);  -- Ultimo valore non nullo\
begin \
process(i_clk,i_rst)\
    \
    begin\
    if i_rst = '1' then\
        -- Se il reset \'e8 attivo, azzera i valori\
        stored_value <= "00000000";\
        last_valid_value <= "00000000";  \
\
    elsif rising_edge(i_clk) then\
        if i_start = '1' and enable_read = '1' then  \
            if input /= "00000000" then  \
                stored_value <= input;  \
                last_valid_value <= input;  \
            else\
                stored_value <= last_valid_value;  \
            end if;\
        elsif enable_rst = '1' then\
                stored_value <= "00000000";\
                last_valid_value <= "00000000";\
        end if;\
    end if;\
end process;\
output <= stored_value;\
end word_register_arch;\
\
----------------------------------------------------------------------------------\
-- Company: \
-- Engineer: \
-- \
-- Create Date: 09/29/2024 12:53:59 AM\
-- Design Name: \
-- Module Name: FSM - FSM_arch\
-- Project Name: \
-- Target Devices: \
-- Tool Versions: \
-- Description: \
-- \
-- Dependencies: \
-- \
-- Revision:\
-- Revision 0.01 - File Created\
-- Additional Comments:\
-- \
----------------------------------------------------------------------------------\
\
\
library IEEE;\
use IEEE.STD_LOGIC_1164.ALL;\
\
-- Uncomment the following library declaration if using\
-- arithmetic functions with Signed or Unsigned values\
use IEEE.NUMERIC_STD.ALL;\
use ieee.numeric_std.all;\
-- Uncomment the following library declaration if instantiating\
-- any Xilinx leaf cells in this code.\
--library UNISIM;\
--use UNISIM.VComponents.all;\
\
entity FSM is\
  Port ( \
           i_clk : in std_logic;\
           i_rst : in std_logic;\
           i_start : in std_logic;\
           i_mem_data : in std_logic_vector(7 downto 0);\
           \
           --data_inw : in std_logic_vector(7 downto 0);\
           --data_inc : in std_logic_vector(7 downto 0);\
           --data_add :  in std_logic_vector(15 downto 0);\
           data_k : in std_logic_vector(9 downto 0);\
           \
           o_done: out std_logic;\
           --o_mem_data :  out std_logic_vector(7 downto 0);\
           --o_mem_add :  out std_logic_vector(15 downto 0);\
           o_mem_en : out std_logic;\
           o_mem_we : out std_logic;\
           \
           en_rst_c_31 :  out std_logic;\
           en_rst_c_0 : out std_logic;\
           en_decr_cred : out std_logic;\
           \
           en_rst_k : out std_logic;\
           en_decr_k : out std_logic;\
           \
           en_rst_add : out std_logic;\
           en_incr_add : out std_logic;\
           \
           en_rst_w : out std_logic;\
           en_read_w : out std_logic;\
           \
           en_mux : out std_logic;\
           en_sel_mux : out std_logic\
           );\
end FSM;\
\
architecture FSM_arch of FSM is\
   -- Definizione degli stati\
    type StateType is (INIT_STATE, S1, S2, S3, S4, S5, S6, S7, S8, COMPLETE_SEQUENCE_STATE);\
    signal current_state : StateType;\
\
    \
begin\
-- Transizioni di stato\
    delta_function : process(i_clk, i_rst)\
    begin\
        \
        if i_rst = '1' then\
            current_state <= INIT_STATE;  -- stato iniziale\
        elsif i_clk'event and i_clk='1' then\
        \
            -- Logica di transizione di stato\
            case current_state is\
                when INIT_STATE =>\
                    if i_start = '1' then\
                        current_state <= S1;\
                    end if;\
    \
                when S1 =>\
                    current_state <= S2;\
                    \
    \
                when S2 =>\
                    if data_k /= "0000000000" then\
                        current_state <= S3;\
                    else\
                        current_state <= COMPLETE_SEQUENCE_STATE;\
                    end if;\
                       \
                \
                when S3 =>\
                    if i_mem_data /= "00000000" then\
                        current_state <= S4;\
                    else\
                        current_state <= S5;\
                    end if;\
                    \
                when S4 =>\
                    current_state <= S6;\
                    \
                when S5 =>\
                    current_state <= S6;\
                            \
                when S6 => \
			         current_state <= S7;\
		            \
                when S7 => \
                    current_state <= S8;\
                    \
                when S8 =>\
                    if data_k > "0000000000" then\
                        current_state <= S2;\
                    else\
                        current_state <= COMPLETE_SEQUENCE_STATE;\
                    end if;\
                \
                when COMPLETE_SEQUENCE_STATE =>\
                    if i_start='0' then\
                       current_state <= INIT_STATE ;\
                    end if;\
\
                when others =>\
                    current_state <= INIT_STATE;\
\
            end case;\
        end if;\
    end process;\
    \
    -- Logica di uscita basata sullo stato corrente\
    lambda_function : process(current_state)\
    \
    \
    begin\
        \
        -- Inizializzazione dei segnali\
        en_rst_c_31 <= '0';\
	    en_rst_c_0 <= '0';\
	    en_decr_cred <= '0';\
	    \
        en_rst_k <= '0';\
        en_decr_k <= '0';\
           \
        en_rst_add <= '0';\
        en_incr_add <= '0';\
           \
        en_read_w <= '0';\
        en_rst_w <= '0';\
        \
\
        o_mem_en <= '0'; \
        o_mem_we <= '0';\
	\
	    o_done <= '0'; \
        \
        en_mux <= '0';\
        en_sel_mux <= '0';\
        \
        if current_state =INIT_STATE then\
                \
        elsif current_state = S1 then\
            en_rst_k <= '1';\
            en_rst_add <= '1';\
            en_rst_c_0 <= '1';\
            en_rst_w <= '1';\
		    \
        elsif current_state = S2 then\
            o_mem_en <='1';\
            \
                    \
        elsif current_state = S3 then\
            en_read_w <= '1';\
            en_decr_k <= '1';\
            \
        elsif current_state = S4 then \
	        en_rst_c_31 <= '1';\
            \
              \
        elsif current_state = S5 then\
            en_decr_cred <= '1';\
            en_mux <= '1';\
            o_mem_en<='1';\
            o_mem_we<='1';\
            \
        elsif current_state = S6 then\
	        en_incr_add <= '1';\
                   \
        elsif current_state = S7 then\
            en_mux<= '1';\
	        en_sel_mux <= '1';\
	        o_mem_en<='1';\
            o_mem_we<='1';\
	       \
	          \
       elsif current_state = S8 then\
           en_incr_add <= '1';\
         \
           \
        elsif current_state= COMPLETE_SEQUENCE_STATE then\
           o_done<='1';\
           \
       end if;\
    end process;    \
    \
\
end FSM_arch;\
\
\
----------------------------------------------------------------------------------\
-- Company: \
-- Engineer: \
-- \
-- Create Date: 10/21/2024 10:47:11 PM\
-- Design Name: \
-- Module Name: data_selector_mux - data_selector_mux_arch\
-- Project Name: \
-- Target Devices: \
-- Tool Versions: \
-- Description: \
-- \
-- Dependencies: \
-- \
-- Revision:\
-- Revision 0.01 - File Created\
-- Additional Comments:\
-- \
----------------------------------------------------------------------------------\
\
\
library IEEE;\
use IEEE.STD_LOGIC_1164.ALL;\
\
-- Uncomment the following library declaration if using\
-- arithmetic functions with Signed or Unsigned values\
--use IEEE.NUMERIC_STD.ALL;\
\
-- Uncomment the following library declaration if instantiating\
-- any Xilinx leaf cells in this code.\
--library UNISIM;\
--use UNISIM.VComponents.all;\
\
entity data_selector_mux is\
  Port (\
    input_cred : in std_logic_vector(7 downto 0);\
    input_w : in std_logic_vector(7 downto 0);\
    enable : in std_logic;\
    sel : in std_logic;\
    output : out std_logic_vector (7 downto 0) );\
end data_selector_mux;\
\
architecture data_selector_mux_arch of data_selector_mux is\
\
begin\
\
process(enable, sel, input_cred, input_w)\
\
begin\
 output <= "00000000";\
 if enable = '1' then\
        case sel is\
            when '0' => output <= input_w;\
            when '1' => output <= input_cred;\
            when others => \
        end case;\
 end if;\
end process;\
\
\
end data_selector_mux_arch;\
\
}