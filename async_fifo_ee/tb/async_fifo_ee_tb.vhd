library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity async_fifo_ee_tb is
end entity;

Architecture behav of async_fifo_ee_tb is


signal arst       : std_logic := '0';

signal wr_clk     : std_logic := '0';
signal wr_en      : std_logic := '0';
signal din        : std_logic_vector(7 downto 0) := (others => '0');
signal full       : std_logic;

signal rd_clk     : std_logic := '0';
signal rd_en      : std_logic := '0';
signal dout       : std_logic_vector(7 downto 0);
signal empty      : std_logic;




begin


uut : entity work.async_fifo_ee port map(
     arst       => arst   

    ,wr_clk     => wr_clk 
    ,wr_en      => wr_en  
    ,din        => din    
    ,full       => full   

    ,rd_clk     => rd_clk 
    ,rd_en      => rd_en  
    ,dout       => dout   
    ,empty      => empty  
    );


wr_clk <= not wr_clk after 4 ns;
rd_clk <= not rd_clk after 3.5 ns;

arst <= '1','0' after 50 ns;

process
procedure tic_wr is begin wait until rising_edge(wr_clk); end procedure;
procedure tic_rd is begin wait until rising_edge(rd_clk); end procedure;
procedure WR_ST(data : integer) is
begin
    wr_en <= '1';
    din <= std_logic_vector(to_unsigned(data,8));
    tic_wr;
    wr_en <= '0';
end procedure;

procedure RD_ST is
begin
    rd_en <= '1';
    tic_rd;
    rd_en <= '0';
end procedure;

begin
    wait for 100 ns;
    tic_wr;
    for ii in 1 to 32 loop
    WR_ST(ii);
    end loop;
    
    wait for 500 ns;
    tic_rd;
    for ii in 1 to 32 loop
    RD_ST;
    end loop;
    
wait;
end process;
    
    
    
end behav;
