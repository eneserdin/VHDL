library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity FIFO_ee is
generic(
   C_DATA_WIDTH : integer := 10
  ;C_DEPTH      : integer := 10
  );
port(
   clk          : in std_logic
  ;rst          : in std_logic
  ;datain       : in std_logic_vector(C_DATA_WIDTH-1 downto 0)
  ;dataout      : out std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0')
  ;wr_en : in std_logic
  ;rd_en : in std_logic
  ;full : out std_logic
  ;empty : out std_logic
  ;data_count : out std_logic_vector(C_DEPTH - 1 downto 0)
  );
end entity;


architecture behavioral of FIFO_ee is

  type mem_type is array (0 to 2**C_DEPTH - 1) of std_logic_vector(C_DATA_WIDTH-1 downto 0);
  shared variable mem : mem_type;

  signal empty_i : std_logic;
  signal full_i : std_logic;


  signal wr_ptr : unsigned(C_DEPTH downto 0) := (others => '0');
  signal rd_ptr : unsigned(C_DEPTH downto 0) := (others => '0');

  signal cnt : unsigned(C_DEPTH-1 downto 0) := (others => '0');
  begin
    process(clk)
      begin
        if rising_edge(clk) then
          if wr_en = '1' and full_i = '0' then
            mem(to_integer(wr_ptr(C_DEPTH-1 downto 0))) := datain;
            wr_ptr <= wr_ptr + 1;
          end if;

          if rd_en = '1' and empty_i = '0' then
            dataout <= mem(to_integer(rd_ptr(C_DEPTH-1 downto 0)));
            rd_ptr <= rd_ptr + 1;
          end if;
         end if;
      end process;

      full_i <= '1' when wr_ptr(C_DEPTH-1 downto 0) = rd_ptr(C_DEPTH-1 downto 0) and wr_ptr(C_DEPTH) = not rd_ptr(C_DEPTH) else '0';

      empty_i <= '1' when wr_ptr = rd_ptr else '0';

      full <= full_i;
      empty <= empty_i;
    
    process(clk)
    variable data_count_var : unsigned(data_count'range);
    begin
        if rising_edge(clk) then
            if rst = '1' then
                data_count_var := (others => '0');
            else
                if wr_en = '1' then
                    data_count_var := data_count_var + 1;
                end if;
                
                if rd_en = '1' then
                    data_count_var := data_count_var - 1;
                end if;
            end if;
            data_count <= std_logic_vector(data_count_var);
        end if;
    end process;
                    
                
 end Behavioral;
 
                           
