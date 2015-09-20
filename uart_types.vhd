--*****************************************************************************
--* UART Types
--*****************************************************************************
--*
--* Derek Schacht
--* 08/19/2015
--*
--* This file contains the types used within the midpoint UART.
--*****************************************************************************

library IEEE;
    use IEEE.STD_LOGIC_1164.all;

package UART_Types is

	subtype Counter_Length_Type is integer range 0 to 8191;

	constant UART_Reset_Polarity : std_logic := '1';
	
	constant UART_Data_Bits : integer := 8;

	
	-- If these are uncommented the tool generates an odd error.
	
	--   FATAL_ERROR:HDLParsers:vhptype.c:174:$Id: vhptype.c,v 1.9 2005/08/22 17:03:34 mikev 
	--   Exp $:200 - INTERNAL ERROR... while parsing "C:/Xilinx/Projects/midpoint_uart/uart_types.vhd" line 87. 
	--   Contact your hot line.   For technical support on this issue, please visit http://www.xilinx.com/support.
	
	--   XST 14.7
	
	--   This all ran fine for simulation.
	
	-- So yeah.... These constants are also commented out where they would be used in the
	-- actual code. So if these need to be changed... Go fishing.
	-- Seems to have been fixed by deleting the files in xst/work. Deleting these files also cleaned up
	-- some other odd behavior that I was seeing.
	
	subtype Small_Integer_Type is integer range 0 to 15;
	constant UART_RX_Start_Bit_Timer_Correction : Small_Integer_Type := 6;
	constant UART_Baud_Timer_Correction         : Small_Integer_Type := 3;

	type UART_Status_Type is (Ready,
                              Data_Ready,
	                          Error);
	
	type UART_Status_Array_Type is array (UART_Status_Type) of std_logic;


	type UART_State_Type is (Wait_State, 
                             Delay_State, 
                             Start_State, 
                             Data_State, 
                             Parity_State, 
                             Stop_State);

	subtype UART_Bit_Type is std_logic;
	subtype UART_Data_Type is std_logic_vector ((UART_Data_Bits - 1) downto 0);

end UART_Types;
