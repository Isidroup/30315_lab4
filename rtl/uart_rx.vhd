-------------------------------------------------------------------------------
-- File: uart_rx_2025.vhd
-- Description: Receptor UART (Universal Asynchronous Receiver Transmitter)
--              Recibe datos serie a 9600 baudios y los muestra en un display
--              de 7 segmentos y en los LEDs
-- Author:
-- Date: 2025
-- MEF: https://tinyurl.com/4jmju6vv
--
-- Arquitectura:
--   - DATAPATH: Sincronizador, registro de desplazamiento, registro de salida,
--               decodificador BIN a 7 segmentos, temporizador y contador de bits
--   - CONTROL: Maquina de estados finitos (MEF) que gestiona la recepcion
-------------------------------------------------------------------------------

-- TODO: Anadir librerias necesarias.

entity uart_rx is
    port (

            -- TODO: Anadir puertos de entrada/salida.
         );
end uart_rx;

architecture rtl of uart_rx is

    ---------------------------------------------------------------------------
    -- SENALES DEL DATAPATH
    ---------------------------------------------------------------------------
    -- Sincronizador de entrada RX

    -- TODO: Declarar constantes y tipos.
    -- TODO: Declarar senales internas.

    -- Registro de desplazamiento serie/paralelo (8 bits)

    -- TODO: Declarar constantes y tipos.
    -- TODO: Declarar senales internas.

    -- Registro de salida paralelo/paralelo (8 bits)

    -- TODO: Declarar constantes y tipos.
    -- TODO: Declarar senales internas.


    ---------------------------------------------------------------------------
    -- SENALES DEL CONTROL (MEF), CONTADOR DE BITS Y TEMPORIZADOR
    ---------------------------------------------------------------------------
    -- Maquina de estados (FSM)

    -- TODO: Declarar constantes y tipos.
    -- TODO: Declarar senales internas.

    -- Contador de bits recibidos (modulo 8)

    -- TODO: Declarar constantes y tipos.
    -- TODO: Declarar senales internas.

    -- Temporizador para muestreo de bits

    -- TODO: Declarar constantes y tipos.
    -- TODO: Declarar senales internas.


begin

---------------------------------------------------------------------------
-- DATAPATH (CAMINO DE DATOS)
---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- DATAPATH: SINCRONIZADOR DE ENTRADA (2 biestables)
    -- Sincroniza la senal RX asincrona con el reloj del sistema
    ---------------------------------------------------------------------------

    -- TODO: Implementar el modelo separando parte combinacional de secuencial.

    ---------------------------------------------------------------------------
    -- DATAPATH: REGISTRO DE DESPLAZAMIENTO SERIE/PARALELO (8 bits)
    -- Convierte los bits recibidos en serie a formato paralelo
    ---------------------------------------------------------------------------

    -- TODO: Implementar el modelo separando parte combinacional de secuencial.

    ---------------------------------------------------------------------------
    -- DATAPATH: REGISTRO DE SALIDA PARALELO/PARALELO (8 bits)
    -- Almacena el dato completo recibido para mostrarlo
    ---------------------------------------------------------------------------

    -- TODO: Implementar el modelo separando parte combinacional de secuencial.

    ---------------------------------------------------------------------------
    -- DATAPATH: DECODIFICADOR BINARIO A 7 SEGMENTOS
    -- Convierte el codigo ASCII recibido a segmentos para el display
    ---------------------------------------------------------------------------

    -- TODO: Implementar el modelo s.

    ---------------------------------------------------------------------------
    -- DATAPATH: ASIGNACIONES DE SALIDA
    ---------------------------------------------------------------------------

    -- TODO: Implementar el modelo.

---------------------------------------------------------------------------
-- CONTROL
---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- CONTROL: MAQUINA DE ESTADOS FINITOS (MEF)
    ---------------------------------------------------------------------------

    -- TODO: Implementar el modelo separando parte combinacional de secuencial.

    ---------------------------------------------------------------------------
    -- CONTROL: TEMPORIZADOR (Timer)
    -- Cuenta ciclos de reloj para determinar el centro de cada bit
    ---------------------------------------------------------------------------

    -- TODO: Implementar el modelo separando parte combinacional de secuencial.

    ---------------------------------------------------------------------------
    -- CONTROL: CONTADOR DE BITS (Modulo 8)
    -- Cuenta los bits de datos recibidos (0 a 7)
    ---------------------------------------------------------------------------

    -- TODO: Implementar el modelo separando parte combinacional de secuencial.

end architecture;
