--*****************************************************************************
--* Counter Tester
--*****************************************************************************
--*
--* Derek Schacht
--* 08/19/2015
--*
--* This file contains the test for the counter module.
--*****************************************************************************

LIBRARY ieee;
    USE ieee.std_logic_1164.ALL;
 
use work.uart_types.all;
 
ENTITY countet_tester IS
END countet_tester;
 
ARCHITECTURE behavior OF countet_tester IS 
 
    -- Component Declaration for the Unit Under Test (UUT)

   --Inputs
   signal Reset : std_logic := '0';
   signal Clock : std_logic := '0';
   signal Load_Value : Counter_Length_Type;

 	--Outputs
   signal Current_Value : Counter_Length_Type;

   -- Clock period definitions
   constant Clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.UART_Counter PORT MAP (
          Reset => Reset,
          Clock => Clock,
          Current_Value => Current_Value,
          Load_Value => Load_Value
        );

   -- Clock process definitions
   Clock_process :process
   begin
		Clock <= '0';
		wait for Clock_period/2;
		Clock <= '1';
		wait for Clock_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		Reset <= '1';
		Load_Value <= 1000;
      wait for 100 ns;	
		Reset <= '0';
      wait for Clock_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
