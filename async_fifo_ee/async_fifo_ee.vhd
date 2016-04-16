library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity async_fifo_ee is
generic(
    DW : integer := 8;
    AW : integer := 5
    );
port(
     arst : in std_logic
     
    ;wr_clk : in std_logic
    ;wr_en : in std_logic
    ;din : in std_logic_vector(DW-1 downto 0)
    ;full : out std_logic
    
    ;rd_clk : in std_logic
    ;rd_en : in std_logic
    ;dout : out std_logic_vector(DW-1 downto 0) := (others => '0')
    ;empty : out std_logic
    );
end entity;

Architecture behav of async_fifo_ee is

type mem_type is array (0 to 2**AW-1) of std_logic_vector(DW-1 downto 0);
    shared variable mem : mem_type := (others => (others => '0'));

signal wr_addr : unsigned(AW downto 0) := (others => '0');
signal wr_addr_gray : unsigned(AW downto 0) := (others => '0');
signal rd_addr : unsigned(AW downto 0) := (others => '0');
signal rd_addr_gray: unsigned(AW downto 0) := (others => '0');



signal rd_addr_m1      : unsigned(rd_addr'range) := (others => '0');
signal rd_addr_m3      : unsigned(rd_addr'range) := (others => '0');
signal rd_addr_m2      : unsigned(rd_addr'range) := (others => '0');
signal rd_addr_sync    : unsigned(rd_addr'range) := (others => '0');
signal full_sig        : std_logic := '1';

signal wr_addr_m1      : unsigned(wr_addr'range) := (others => '0');
signal wr_addr_m3      : unsigned(wr_addr'range) := (others => '0');
signal wr_addr_m2      : unsigned(wr_addr'range) := (others => '0');
signal wr_addr_sync    : unsigned(wr_addr'range) := (others => '0');
signal empty_sig       : std_logic := '0';

-----------------------------
-- FUNCTIONS ----------------
-----------------------------
impure function gray2bin(datain : unsigned(AW downto 0)) return unsigned is
    variable ret_val : unsigned(AW downto 0);
begin
    ret_val(AW) := datain(AW);
    now_comes_loop : for ii in 0 to AW-1 loop
        ret_val(AW - 1 - ii) := datain(AW - 1 - ii) xor ret_val(AW - ii);
    end loop;
return ret_val;
end function;


impure function bin2gray(datain : unsigned(AW downto 0)) return unsigned is
    variable ret_val : unsigned(AW downto 0);
begin
        ret_val(ret_val'high) := datain(datain'high);
    now_comes_the_loop : for ii in 0 to AW-1 loop
        ret_val(ii) := (datain(ii+1) xor datain(ii));
    end loop;
return ret_val;
end function;
------------------------------------------
-----------
------------------------------------------

begin


--------------------------
-- RAM side
--------------------------
process(wr_clk)
begin
    if arst = '1' then
        wr_addr <= (others => '0');
    else
    if rising_edge(wr_clk) then
        if wr_en = '1' and full_sig = '0' then
            mem(to_integer(wr_addr(AW-1 downto 0))) := din;
            wr_addr <= wr_addr + 1;
        end if;
        wr_addr_gray <= bin2gray(wr_addr);
    end if;
    end if;
end process;

process(rd_clk)
begin
    if arst = '1' then
        rd_addr <= (others => '0');
    else
    if rising_edge(rd_clk) then
        if rd_en = '1' and empty_sig = '0' then
            dout <= mem(to_integer(rd_addr(AW-1 downto 0)));
            rd_addr <= rd_addr + 1;
        end if;
        rd_addr_gray <= bin2gray(rd_addr);
    end if;
    end if;
end process;

------------------------------
-- Full Flag construction
------------------------------
process(wr_clk)
begin
    if falling_edge(wr_clk) then
        rd_addr_m1 <= rd_addr_gray;
        rd_addr_m3 <= rd_addr_m1;
    end if;
    
    if rising_edge(wr_clk) then
        rd_addr_m2 <= rd_addr_m1;
        rd_addr_sync <= gray2bin(rd_addr_m3);
    end if;
    
    if arst = '1' then
        rd_addr_m1 <= (others => '0');
        rd_addr_m2 <= (others => '0');
        rd_addr_m3 <= (others => '0');
        rd_addr_sync <= (others => '0');
    end if;
end process;

full_sig <= '1' when (wr_addr(AW-1 downto 0) = rd_addr_sync(AW-1 downto 0)) and (wr_addr(AW) /= rd_addr_sync(AW)) else
            '0';
full <= full_sig;

------------------------------
-- Empty Flag construction
------------------------------
process(rd_clk)
begin
    if falling_edge(rd_clk) then
        wr_addr_m1 <= wr_addr_gray;
        wr_addr_m3 <= wr_addr_m1;
    end if;
    
    if rising_edge(rd_clk) then
        wr_addr_m2 <= wr_addr_m1;
        wr_addr_sync <= gray2bin(wr_addr_m3);
    end if;

    if arst = '1' then
        wr_addr_m1 <= (others => '0');
        wr_addr_m2 <= (others => '0');
        wr_addr_m3 <= (others => '0');
        wr_addr_sync <= (others => '0');
    end if;
end process;

empty_sig <=    '1' when rd_addr = wr_addr_sync else
                '0';
empty <= empty_sig;


end behav;
