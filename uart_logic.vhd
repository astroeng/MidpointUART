--*****************************************************************************
--* UART Logic
--*****************************************************************************
--*
--* Derek Schacht
--* 08/19/2015
--*
--* This file contains the instantiation of the RX and TX parts of the UART.
--*****************************************************************************

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;

use UART_Types.all;

entity UART_Logic is

	port (Reset         : in    UART_Bit_Type;
	      Clock         : in    UART_Bit_Type;
          RX_Pin        : in    UART_Bit_Type;
          TX_Pin        :   out UART_Bit_Type;
          RX_Data       :   out UART_Data_Type;
          TX_Data       : in    UART_Data_Type;
          RX_Data_Clock : in    UART_Bit_Type;
          TX_Data_Clock : in    UART_Bit_Type;
          RX_Status     :   out UART_Status_Array_Type;
          TX_Status     :   out UART_Status_Array_Type;
          Baud_Divider  : in    Counter_Length_Type);		

end UART_Logic;

architecture Behavioral of UART_Logic is

begin

	RX_Side : entity UART_RX_Logic 
		port map (Reset         => Reset,
				    Clock         => Clock,
					 RX_Pin        => RX_Pin,
					 RX_Data       => RX_Data,
					 RX_Data_Clock => RX_Data_Clock,
					 RX_Sample     => open,
					 RX_Divider    => Baud_Divider,
					 RX_Status     => RX_Status);


	TX_Side : entity UART_TX_Logic 
		port map (Reset         => Reset,
				    Clock         => Clock,
					 TX_Pin        => TX_Pin,
					 TX_Data       => TX_Data,
					 TX_Data_Clock => TX_Data_Clock,
					 TX_Divider    => Baud_Divider,
					 TX_Status     => TX_Status);

end Behavioral;

