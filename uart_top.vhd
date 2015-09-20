--*****************************************************************************
--* UART Top
--*****************************************************************************
--*
--* Derek Schacht
--* 08/19/2015
--*
--* This file contains a basic test for the UART.
--*****************************************************************************

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;

use work.uart_types.all;

entity uart_top is

    port (Reset  : in    UART_Bit_Type;
          Clock  : in    UART_Bit_Type;
          RX_Pin : in    UART_Bit_Type;
          TX_Pin :   out UART_Bit_Type;
          LEDs   :   out UART_Data_Type);

end uart_top;

architecture Behavioral of uart_top is

	type tx_data_array_type is array (0 to 8) of UART_Data_Type;

	signal RX_Status_Net : UART_Status_Array_Type;
	signal TX_Status_Net : UART_Status_Array_Type;
	signal RX_Data_Net   : UART_Data_Type;
	signal RX_Clock_Net  : UART_Bit_Type;
	signal TX_Clock_Net  : UART_Bit_Type;

	signal TX_Data_Array :tx_data_array_type := (0 => "01001000", -- H
                                                 1 => "01000101", -- E
                                                 2 => "01001100", -- L
                                                 3 => "01001100", -- L
                                                 4 => "01001111", -- O
                                                 5 => "01011111", -- _
                                                 6 => "01001101", -- M
                                                 7 => "01000101", -- E
                                                 8 => "11110000");-- Jibberish

	signal TX_Data_Net : UART_Data_Type;


begin

	LEDs <= RX_Data_Net;
	--LEDs(2 downto 0) <= RX_Status_Net;
	--LEDs(7 downto 5) <= TX_Status_Net;

    UART : entity UART_Logic
		port map(Reset         => Reset,
                 Clock         => Clock,
                 RX_Pin        => RX_Pin,
                 TX_Pin        => TX_Pin,
                 RX_Data       => RX_Data_Net,
                 TX_Data       => TX_Data_Net,
                 RX_Data_Clock => RX_Clock_Net,
                 TX_Data_Clock => TX_Clock_Net,
                 RX_Status     => RX_Status_Net,
                 TX_Status     => TX_Status_Net,
                 Baud_Divider  => 5208); -- 50 Mhz/9600 Baud = 5208.333


	process (Clock)
	
		variable channel : integer range 0 to 8;
	
	begin
	
		TX_Data_Net <= TX_Data_Array(channel);
	
		if rising_edge (Clock) then
		
			if Reset = UART_Reset_Polarity then
			
				channel := 0;
			
			elsif RX_Status_Net(Data_Ready) = '1' then
			
				RX_Clock_Net <= '1';
				
				TX_Clock_Net <= '1';
				
				if channel < 8 then
				
					channel := channel + 1;
				
				else
					
					channel := 0;
				
				end if;
			
			end if;
		
		end if;
	
	end process;

end Behavioral;

