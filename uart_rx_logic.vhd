--*****************************************************************************
--* UART RX Logic
--*****************************************************************************
--*
--* Derek Schacht
--* 08/19/2015
--*
--* This file contains the logic needed to receive data.
--*****************************************************************************

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;

use work.UART_Types.all;

entity UART_RX_Logic is

	port (Reset         : in    UART_Bit_Type;
          Clock         : in    UART_Bit_Type;
          RX_Pin        : in    UART_Bit_Type;
          RX_Data       :   out UART_Data_Type;
          RX_Data_Clock : in    UART_Bit_Type;
          RX_Sample     :   out UART_Bit_Type;
          RX_Divider    : in    Counter_Length_Type;
          RX_Status     :   out UART_Status_Array_Type);

end UART_RX_Logic;

architecture Behavioral of UART_RX_Logic is

	signal Counter_Value   : Counter_Length_Type;
	signal Counter_Reset   : UART_Bit_Type;
	signal Counter_Divider : Counter_Length_Type;

begin

	RX_Sample <= Counter_Reset;

	-- This counter is what provides the timing to read the 
	-- bits from the wire. This counter is setup and used in
	-- the state machine below.

	RX_Counter : entity work.UART_Counter

		port map (Reset         => Counter_Reset,
					 Clock         => Clock,
					 Current_Value => Counter_Value,
					 Load_Value    => Counter_Divider);

	-- This is the state machine that controls the receive
	-- functionality of the UART.

	process (Clock)
	
		variable Current_State : UART_State_Type;
		variable Next_State    : UART_State_Type;
		variable Input_Data    : UART_Data_Type;
		variable Input_Buffer  : UART_Data_Type;
		variable Bit_Counter   : Small_Integer_Type;
		variable UART_Status   : UART_Status_Array_Type;
	
	begin
	
		RX_Data   <= Input_Buffer;
		RX_Status <= UART_Status;
	
		if rising_edge(Clock) then
		
			-- If the received byte is read, turn off the 
			-- indication that the data is ready to be read.
		
		   if RX_Data_Clock = '1' then
			
				UART_Status(Data_Ready) := '0';
		
			end if;
		
			-- Check for errors.
		
			if RX_Divider < 10 then
			
				UART_Status(Error) := '1';
				
			end if;
		
		
			if Reset = UART_Reset_Polarity then
			
				Current_State := Wait_State;
				Next_State    := Wait_State;
				Input_Data    := (others => '0');
				Input_Buffer  := (others => '0');
				Counter_Reset <= not UART_Reset_Polarity;
				UART_Status   := (others => '0');
			
			elsif Counter_Value = 0 then
			
				-- Case statement to control the reception of data from the wire.
				-- Flow of the state machine is basically as follows:
				-- + Wait_State
				-- |   							Delay_State
				-- | Start_State
				-- |   							Delay_State
				-- | Data_State (0)
				-- |   							Delay_State
				-- | Data_State (1)
				-- |   							Delay_State
				-- | Data_State (2)
				-- |   							Delay_State
				-- | Data_State (3)
				-- |   							Delay_State
				-- | Data_State (4)
				-- |   							Delay_State
				-- | Data_State (5)
				-- |   							Delay_State
				-- | Data_State (6)
				-- |   							Delay_State
				-- | Data_State (7)
				-- |   							Delay_State
				-- | Stop_State
				-- |   							Delay_State
				-- - Wait_State
				
				-- The delay states are used to allow the UART Bit Counter a
				-- cycle to reset.
				
				case Current_State is
				
					when Wait_State =>

						-- This is where the UART sits waiting for new data to arrive.
						-- New data is indicated by the line falling to 0. As the UART
						-- transitions out of this state the Ready flag is set to false,
						-- thus indicating that the UART is busy.

						if RX_Pin = '0' then

							Next_State         := Start_State;
							Current_State      := Delay_State;
							Bit_Counter        := 0;
							UART_Status(Ready) := '0';
							
						else
						
							UART_Status(Ready) := '1';

						end if;
					
					when Delay_State =>
					
						-- As mentioned before this state is used to allow the counter
						-- a cycle to initialize.
					
						Current_State := Next_State;
					
					when Start_State =>
					
						-- In this state the counter is setup and reset to the value
						-- needed to land in the middle of the first data bit.
					
						Counter_Reset <= UART_Reset_Polarity;
						
						Counter_Divider <= (RX_Divider + (RX_Divider / 2)) - UART_RX_Start_Bit_Timer_Correction;
						
						Next_State    := Data_State;
						Current_State := Delay_State;
						
					when Data_State =>
					
						-- In this state the counter is setup and reset to the value 
						-- needed to land on the middle of the next bit. The current 
						-- wire state is also sampled and stored for output. This
						-- state is iterated over 8 times, once for each data bit.
					
						Input_Data(Bit_Counter) := RX_Pin;
						
						Counter_Reset <= UART_Reset_Polarity;
						Counter_Divider <= RX_Divider - UART_Baud_Timer_Correction;
						
						if Bit_Counter < (UART_Data_Bits - 1) then
						
							Bit_Counter   := Bit_Counter + 1;
							Current_State := Delay_State;
						
						elsif Bit_Counter = (UART_Data_Bits - 1) then 
						
							--Next_State    := Parity_State;
							Next_State    := Stop_State;
							Current_State := Delay_State;
						
						end if;
					
					when Parity_State =>

						-- This state is used for parity checking.
						-- NOTE: NOT Currently supported.

						Next_State    := Stop_State;
						Current_State := Delay_State;						
					
					when Stop_State =>
					
						-- This state handles the logic for the stop bit. The
						-- received data is copied from the receive buffer to 
						-- the output buffer. This prevents and incoming byte
						-- from corrupting this one before it can be read.

					   Counter_Divider         <= (RX_Divider / 2) - UART_Baud_Timer_Correction;
						Next_State              := Wait_State;
						Current_State           := Delay_State;
						Counter_Reset           <= UART_Reset_Polarity;
						UART_Status(Data_Ready) := '1';
						Input_Buffer            := Input_Data;
				
				end case;
			
			else
			
				-- Once the counter is set (reset) to the desired value 
				-- the reset flag needs to be deasserted.
			
				Counter_Reset <= '0';
			
			end if;

		end if;

	end process;

end Behavioral;
