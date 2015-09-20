--*****************************************************************************
--* UART TX Logic
--*****************************************************************************
--*
--* Derek Schacht
--* 08/19/2015
--*
--* This file contains the logic needed to perform transmission of data.
--*****************************************************************************

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;

use work.uart_types.all;

entity UART_TX_Logic is

	port (Reset         : in    UART_Bit_Type;
          Clock         : in    UART_Bit_Type;
          TX_Pin        :   out UART_Bit_Type;
          TX_Data       : in    UART_Data_Type;
          TX_Data_Clock : in    UART_Bit_Type;
          TX_Divider    : in    Counter_Length_Type;
          TX_Status     :   out UART_Status_Array_Type);

end UART_TX_Logic;

architecture Behavioral of UART_TX_Logic is

	signal Counter_Value : Counter_Length_Type;
	signal Counter_Reset : UART_Bit_Type;
	signal TX_Divider_m3 : Counter_Length_Type;

begin

	TX_Divider_m3 <= TX_Divider - UART_Baud_Timer_Correction;

	TX_Counter : entity work.UART_Counter

		port map (Reset         => Counter_Reset,
                  Clock         => Clock,
                  Current_Value => Counter_Value,
                  Load_Value    => TX_Divider_m3);

	process (Clock)
	
		variable Current_State : UART_State_Type;
		variable Next_State    : UART_State_Type;
		variable Output_Data   : UART_Data_Type;
		variable Bit_Counter   : Small_Integer_Type;
		variable UART_Status   : UART_Status_Array_Type;
	
	begin
	
		TX_Status <= UART_Status;
	
		if rising_edge(Clock) then
		
		   if TX_Divider < 10 then
			
				UART_Status(Error) := '1';
				
			end if;
		
			if Reset = UART_Reset_Polarity then
			
				Current_State := Wait_State;
				Next_State    := Wait_State;
				Output_Data   := (others => '0');
				TX_Pin        <= '1';
				Counter_Reset <= not UART_Reset_Polarity;
				UART_Status   := (others => '0');
			
			elsif Counter_Value = 0 then
			
				case Current_State is
				
					when Wait_State =>

						if TX_Data_Clock = '1' then
						
							Output_Data        := TX_Data;
							Next_State         := Start_State;
							Current_State      := Delay_State;
							Bit_Counter        := 0;
							Counter_Reset      <= UART_Reset_Polarity;
							UART_Status(Ready) := '0';
							
						else
						
							UART_Status(Ready) := '1';

						end if;
					
					when Delay_State =>
					
						Current_State := Next_State;
					
					when Start_State =>
					
						TX_Pin 		  <= '0';
						Counter_Reset <= UART_Reset_Polarity;
						Next_State    := Data_State;
						Current_State := Delay_State;
					
					when Data_State =>
					
						TX_Pin        <= Output_Data(Bit_Counter);
						Counter_Reset <= UART_Reset_Polarity;
						
						if Bit_Counter < (UART_Data_Bits - 1)  then
						
							Bit_Counter := Bit_Counter + 1;
							Current_State := Delay_State;
						
						elsif Bit_Counter = (UART_Data_Bits - 1) then 
						
							--Next_State    := Parity_State;
							Next_State    := Stop_State;
							Current_State := Delay_State;
						
						end if;
					
					when Parity_State =>

						Next_State    := Stop_State;
						Current_State := Delay_State;						
					
					when Stop_State =>
					
						Next_State    := Wait_State;
						Current_State := Delay_State;
						Counter_Reset <= UART_Reset_Polarity;
						TX_Pin        <= '1';
				
				end case;
			
			else
			
				Counter_Reset <= '0';
			
			end if;

		end if;

	end process;

end Behavioral;

