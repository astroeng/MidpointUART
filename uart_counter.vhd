--*****************************************************************************
--* UART Counter
--*****************************************************************************
--*
--* Derek Schacht
--* 08/19/2015
--*
--* This file contains the logic needed to control the timing of the UART.
--*****************************************************************************

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;

use work.uart_types.all;

entity UART_Counter is

	port (Reset         : in    UART_Bit_Type;
          Clock         : in    UART_Bit_Type;
          Current_Value :   out Counter_Length_Type;
          Load_Value    : in    Counter_Length_Type);

end UART_Counter;

architecture Behavioral of UART_Counter is

begin

	process (Clock)
	
		variable Count_Value : Counter_Length_Type;
	
	begin
	
		Current_Value <= Count_Value;
	
		if rising_edge (Clock) then
		
			if (Reset = UART_Reset_Polarity) then
			
				Count_Value := Load_Value;
				
			elsif Count_Value > 0 then
			
				Count_Value := Count_Value - 1;
			
			end if;

		end if;

	end process;

end Behavioral;

