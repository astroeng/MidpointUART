--*****************************************************************************
--* TX Tester
--*****************************************************************************
--*
--* Derek Schacht
--* 08/19/2015
--*
--* This file contains the test for the TX Module.
--*****************************************************************************

LIBRARY ieee;
    USE ieee.std_logic_1164.ALL;

use work.uart_types.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tx_tester IS
END tx_tester;
 
ARCHITECTURE behavior OF tx_tester IS 
 
  

   --Inputs
   signal Reset : std_logic := '0';
   signal Clock : std_logic := '0';
   signal TX_Data : std_logic_vector(7 downto 0) := (others => '0');
   signal TX_Data_Clock : std_logic := '0';
   signal TX_Divider : Counter_Length_Type;

 	--Outputs
   signal TX_Pin : std_logic;
   signal TX_Status : uart_status_array_type;

   -- Clock period definitions
   constant Clock_period : time := 2 ns;

 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.UART_TX_Logic PORT MAP (
          Reset => Reset,
          Clock => Clock,
          TX_Pin => TX_Pin,
          TX_Data => TX_Data,
          TX_Data_Clock => TX_Data_Clock,
          TX_Divider => TX_Divider,
          TX_Status => TX_Status
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
      wait for 100 ns;	

			Reset <= '0';
			TX_Data <= "01100110";
			TX_Divider <= 10;

      wait for Clock_period*10;
		
			TX_Data_Clock <= '1';
			
		wait for Clock_period;
		
			TX_Data_Clock <= '0';

      -- insert stimulus here 

      wait;
   end process;

END;
