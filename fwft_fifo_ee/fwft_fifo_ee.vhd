library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fwft_fifo_ee is
generic(
   C_DATA_WIDTH : integer := 10
  ;C_DEPTH      : integer := 6
  );
port(
   clk          : in std_logic
  ;rst          : in std_logic
  ;datain       : in std_logic_vector(C_DATA_WIDTH-1 downto 0)
  ;dataout      : out std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0')
  ;wr_en        : in std_logic
  ;rd_en        : in std_logic
  ;full         : out std_logic
  ;empty        : out std_logic
  ;data_count   : out std_logic_vector(C_DEPTH downto 0)
  );
end entity;

Architecture behav of fwft_fifo_ee is

--signal clk          : std_logic;
--signal rst          : std_logic;
--signal datain       : std_logic_vector(C_DATA_WIDTH-1 downto 0);
signal dataout_fifo   : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
signal dataout_r      : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
--signal wr_en        : std_logic;
signal rd_en_fifo        : std_logic;
signal rd_en_fifo_r        : std_logic;
signal full_fifo         : std_logic;
signal empty_fifo        : std_logic;
signal empty_fifo_r        : std_logic;
signal data_count_fifo   : std_logic_vector(C_DEPTH - 1 downto 0);

signal state : integer := 0;
signal rd_en_fsm : std_logic := '0';

signal empty_sig : std_logic := '1';

begin


fifo : entity work.FIFO_ee
generic map(
     C_DATA_WIDTH => C_DATA_WIDTH
    ,C_DEPTH      => C_DEPTH
  )
port map(
     clk          => clk       
    ,rst          => rst       
    ,datain       => datain    
    ,dataout      => dataout_fifo
    ,wr_en        => wr_en     
    ,rd_en        => rd_en_fifo
    ,full         => full_fifo     
    ,empty        => empty_fifo 
    ,data_count   => data_count_fifo
);


rd_en_fifo <= '1' when rd_en = '1' or rd_en_fsm = '1' or ((empty_fifo = '0' and empty_fifo_r = '1' and state = 1)) else
                '0';

process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            empty_fifo_r <= '0';
            rd_en_fsm <= '0';
            state <= 0;
        else
            
            empty_fifo_r <= empty_fifo;
            rd_en_fifo_r <= rd_en_fifo;



            for ii in 0 to 65 loop
                if state = ii then
                    if wr_en = '1' and full_fifo = '0' then
                        state <= state + 1;
                    end if;
                    
                    if rd_en = '1' and empty_sig = '0' then
                        state <= state - 1;
                    end if;
                    
                    if wr_en = '1' and rd_en = '1' then
                        state <= state;
                    end if;
                end if;
            end loop;
            
            if rd_en_fifo = '1' and state /= 0 then
                dataout_r <= dataout_fifo;
            end if;
            

            
        end if;
    end if;
end process;

dataout <= dataout_fifo;-- when rd_en_fifo_r = '1';
data_count <= std_logic_vector(to_unsigned(state,data_count'length));
empty_sig <= '1' when state = 0 else '0';
empty <= empty_sig;
full <= full_fifo;


end behav;


                           
