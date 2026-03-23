
-------------------------------------------------------------------------------
-- File: uart_rx_tb.vhd
-- Description: Testbench para el receptor UART (uart_rx)
--              Verifica la funcionalidad del receptor serie a 9600 baudios
--              mediante diferentes casos de prueba
-- Author:
-- Date: 2025
--
-- Tests:
--   T1: Reset y condiciones iniciales
--   T2: Sincronizacion de la senal RX
--   T3: Recepcion correcta de un dato
--   T4: Verificacion de errores (glitch en start, error en stop)
--   T5: Recepcion de rx_sequence consecutivos
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx_tb is
end;

architecture Behavioral of uart_rx_tb is
    ---------------------------------------------------------------------------
    -- DECLARACION DEL COMPONENTE BAJO PRUEBA (DUT)
    ---------------------------------------------------------------------------
    component uart_rx
        port (
            CLK  : in std_logic;                     -- Reloj del sistema (100 MHz)
            RST  : in std_logic;                     -- Reset asincrono activo alto
            RX   : in std_logic;                     -- Linea de recepcion serie
            DATO : out std_logic_vector (7 downto 0);-- Dato recibido
            SS   : out std_logic_vector (6 downto 0);-- Display 7 segmentos
            AN   : out std_logic_vector (3 downto 0);-- Anodos del display
            DRI  : out std_logic                     -- Dato Recibido e Indicador de listo
        );
    end component;

    ---------------------------------------------------------------------------
    -- CONSTANTES DE SIMULACION
    ---------------------------------------------------------------------------
    constant clk_period : time := 10 ns;        -- Periodo de reloj (100 MHz)
    constant BIT_time : time := 1 sec/19200;     -- Tiempo de bit UART (19200 baudios)

    ---------------------------------------------------------------------------
    -- SENALES DEL TESTBENCH
    ---------------------------------------------------------------------------
    -- Senales conectadas al DUT
    signal clk_tb  : std_logic := '0';          -- Reloj de prueba
    signal rst_tb  : std_logic;                 -- Reset de prueba
    signal rx_tb   : std_logic;                 -- Linea RX emulada
    signal an_tb   : std_logic_vector (3 downto 0);  -- Anodos
    signal ss_tb   : std_logic_vector (6 downto 0);  -- 7 segmentos
    signal dato_tb : std_logic_vector (7 downto 0);  -- Dato recibido
    signal dri_tb  : std_logic;                 -- Indicador listo

    -- Senales del emulador de transmisor serie
    signal numero  : character;                 -- Caracter visualizado en 7 segmentos
    type rx_sequence_t is array (0 to 10) of unsigned(7 downto 0);
    signal rx_sequence : rx_sequence_t := (x"30", x"31", x"32", x"33", x"34",
                                    x"35", x"36", x"37", x"38", x"39", x"20");
    signal rx_byte  : unsigned(7 downto 0);        -- Byte a recibir en el test

    -- Indicador de número de test
    type test_t is (T1, T2, T3, T41, T42, T5);
    signal test : test_t := T1;

begin

    ---------------------------------------------------------------------------
    -- INSTANCIACION DEL DUT (Device Under Test)
    ---------------------------------------------------------------------------
    lab4_inst : uart_rx
    port map
    (
        CLK  => clk_tb,
        RST  => rst_tb,
        RX   => rx_tb,
        DATO => dato_tb,
        SS   => ss_tb,
        AN   => an_tb,
        DRI  => dri_tb
    );

    ---------------------------------------------------------------------------
    -- GENERADOR DE RELOJ
    ---------------------------------------------------------------------------
    clk_tb <= not clk_tb after clk_period/2;

    ---------------------------------------------------------------------------
    -- PROCESO PRINCIPAL DE VERIFICACION FUNCIONAL DEL DUT
    ---------------------------------------------------------------------------
    process
    begin
        rx_tb <= '0';

        -----------------------------------------------------------------------
        -- T1: Reset y condiciones iniciales
        -----------------------------------------------------------------------
        rst_tb <= '1',
                  '0' after 36 ns;
        wait for 40 ns;
        wait for 0 ns;
        -- >>> Pon un breakpoint en la linea anterior y Comprueba T1.1 .. T1.7

        -----------------------------------------------------------------------
        -- T2: Sincronizacion de RX
        -----------------------------------------------------------------------
        test <= T2;
        rx_tb <= '1',
                 '0' after 5 * clk_period,
                 '1' after 15 * clk_period;
        wait for 20 * clk_period;
        wait for 0 ns;
        -- >>> Pon un breakpoint en la linea anterior y Comprueba T2.1

        -----------------------------------------------------------------------
        -- T3: Verificar la recepcion correcta de un dato
        -----------------------------------------------------------------------
        test <= T3;
        rx_byte  <= x"55"; -- Dato a transmitir: 'U' (ASCII 0x55)
        rx_tb <= '0';   -- Bit de start
        for i in 0 to 7 loop    -- Iteracion por cada bit de dato
            wait for BIT_time;  -- Espera tiempo de 1 bit
            rx_tb <= rx_byte(i);   -- Transmite el bit LSB primero
        end loop;
        wait for BIT_time;
        rx_tb <= '1';   -- Bit de stop
        wait for BIT_time;
        wait for 4 * clk_period;
        wait for 0 ns;
        -- >>> Pon un breakpoint en la linea anterior y Comprueba T3.1 .. T3.9

        -----------------------------------------------------------------------
        -- T4: Verificar deteccion de errores en la comunicacion
        -----------------------------------------------------------------------
        -- T4.1: Glitch en bit de start (pulso corto que debe ser rechazado)
        test <= T41;
        rst_tb <= '1', '0' after 35 ns; -- Activa reset
        rx_tb  <= '1',
            '0' after 5 * clk_period,
            '1' after 25 * clk_period;  -- Glitch de 20 ciclos de reloj
        wait for 30 * clk_period;
        wait for 0 ns;
        -- >>> Pon un breakpoint en la linea anterior y Comprueba T4.1

        -- T4.2: Error en bit de stop (debe rechazar la trama)
        test <= T42;
        rx_byte  <= x"50"; -- Dato a transmitir
        rx_tb <= '0';   -- Bit de start
        for i in 0 to 7 loop    -- Iteracion por cada bit de dato
            wait for BIT_time;  -- Espera tiempo de 1 bit
            rx_tb <= rx_byte(i);   -- Transmite el bit LSB primero
        end loop;
        wait for BIT_time;
        rx_tb <= '0';   -- Bit de stop incorrecto (deberia ser '1')
        wait for BIT_time;
        rx_tb <= '1';
        wait for 4 * clk_period;
        wait for 0 ns;
        -- >>> Pon un breakpoint en la linea anterior y Comprueba T4.2

        -----------------------------------------------------------------------
        -- T5: Verificar la recepcion de rx_sequence consecutivos
        -- Transmite la secuencia: "0123456789 " (digitos y espacio)
        -----------------------------------------------------------------------
        test <= T5;
        rx_tb <= '1';
        for j in rx_sequence'range loop
            rx_byte  <= rx_sequence(j);
            rx_tb <= '0';       -- Bit de start
            for i in 0 to 7 loop    -- Iteracion por cada bit de dato
                wait for BIT_time;  -- Espera tiempo de 1 bit
                rx_tb <= rx_byte(i);   -- Transmite el bit LSB primero
            end loop;
            wait for BIT_time;
            rx_tb <= '1';       -- Bit de stop
            wait for BIT_time;  -- Tiempo entre caracteres
        end loop;
        wait for 0 ns;
        -- >>> Pon un breakpoint en la linea anterior y Comprueba T5

        wait; -- Pausa para finalizar el proceso
    end process;

    ---------------------------------------------------------------------------
    -- DECODIFICADOR DE 7 SEGMENTOS A CARACTER (para debug)
    -- Convierte la salida del display a un caracter legible
    ---------------------------------------------------------------------------
    numero <= '0' when (ss_tb = "0000001") else  -- Digito 0
              '1' when (ss_tb = "1001111") else  -- Digito 1
              '2' when (ss_tb = "0010010") else  -- Digito 2
              '3' when (ss_tb = "0000110") else  -- Digito 3
              '4' when (ss_tb = "1001100") else  -- Digito 4
              '5' when (ss_tb = "0100100") else  -- Digito 5
              '6' when (ss_tb = "0100000") else  -- Digito 6
              '7' when (ss_tb = "0001101") else  -- Digito 7
              '8' when (ss_tb = "0000000") else  -- Digito 8
              '9' when (ss_tb = "0000100") else  -- Digito 9
              'E';                               -- Error/otro caracter

end;
