library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fwft_fifo_ee_tb is
end entity;


architecture tb of fwft_fifo_ee_tb is

  signal clk : std_logic := '1';
  signal rst : std_logic;

  signal datain : std_logic_vector(9 downto 0);
  signal dataout : std_logic_vector(9 downto 0);

  signal wr_en : std_logic := '0';
  signal rd_en : std_logic := '0';
  
  signal full : std_logic;
  signal empty : std_logic;
  
  signal data_count : std_logic_vector(6 downto 0);

begin

  UUT : entity work.fwft_fifo_ee
    port map(
      clk => clk
      ,rst => rst
      ,datain => datain
      ,dataout => dataout
      ,wr_en => wr_en
      ,rd_en => rd_en
      ,full => full
      ,empty => empty
      ,data_count => data_count
      );

  clk <= not clk after 5 ns;
  rst <= '1','0' after 100 ns;

  
  process
    procedure tic is begin wait until rising_edge(clk); end procedure;
    procedure WRITE_DATA(DATA : std_logic_vector(9 downto 0)) is
        begin wr_en <= '1'; datain <= DATA; tic; wr_en <= '0'; end procedure;
    procedure WRITE_DATA(DATA : integer) is
        begin wr_en <= '1'; datain <= std_logic_vector(to_unsigned(DATA,datain'length)); tic; wr_en <= '0'; end procedure;
    procedure READ_DATA is
        begin rd_en <= '1'; tic; rd_en <= '0'; end procedure;
  begin
    wait for 100 ns;
    tic;tic;tic;tic;tic;


    -- writing starts here
    -- USER STIMULUS
    for ii in 1 to 68 loop
      WRITE_DATA(ii+60);
      
      tic;tic;tic;tic;tic;
    end loop;
    

    for ii in 1 to 68 loop
      READ_DATA;
      
      tic;tic;tic;tic;tic;
    end loop;

    
      
    wait;
  end process;

  
end tb;
