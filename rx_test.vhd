--*****************************************************************************
--* RX Test
--*****************************************************************************
--*
--* Derek Schacht
--* 08/19/2015
--*
--* This file contains the test for the RX module.
--*****************************************************************************

LIBRARY ieee;
    USE ieee.std_logic_1164.ALL;

use work.uart_types.all;

ENTITY rx_test IS
END rx_test;
 
ARCHITECTURE behavior OF rx_test IS 

    --Inputs
    signal Reset : std_logic := '0';
    signal Clock : std_logic := '0';
    signal TX_Pin : std_logic := '0';
    signal RX_Data_Clock : std_logic := '0';
    signal TX_Data_Clock : std_logic := '0';
    signal RX_Divider : Counter_Length_Type;

    --Outputs
    signal RX_Data : std_logic_vector(7 downto 0);
    signal TX_Data : std_logic_vector(7 downto 0);
    signal RX_Status : UART_Status_Array_Type;
    signal TX_Status : UART_Status_Array_Type;
    signal RX_Sample : std_logic;
    -- Clock period definitions
    constant Clock_period : time := 20 ns; -- 50Mhz

 
BEGIN
 
	tx : entity work.UART_TX_Logic PORT MAP (
          Reset => Reset,
          Clock => Clock,
          TX_Pin => TX_Pin,
          TX_Data => TX_Data,
          TX_Data_Clock => TX_Data_Clock,
          TX_Divider => RX_Divider,
          TX_Status => TX_Status
        );
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.UART_RX_Logic PORT MAP (
          Reset => Reset,
          Clock => Clock,
          RX_Pin => TX_Pin,
          RX_Data       => RX_Data,
          RX_Data_Clock => RX_Data_Clock,
          RX_Sample     => RX_Sample,
          RX_Divider => RX_Divider,
          RX_Status => RX_Status
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
		RX_Divider <= 5208;
		TX_Data <= "01010101";
      
		wait for 100 us;
      
		Reset <= '0';		

      wait for 100 us;
		
		TX_Data_Clock <= '1';
		
		wait for Clock_period;
		
		TX_Data_Clock <= '0';

		wait for 2 ms;
		
		RX_Data_Clock <= '1';
		
		wait for Clock_period;
		
		RX_Data_Clock <= '0';

      -- insert stimulus here 

      wait;
   end process;

END;
