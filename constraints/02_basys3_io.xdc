# ================================================================================
# Archivo: 02_basys3_io.xdc
# Descripcion: Asignacion de pines y configuracion de voltaje para placa Basys3
# Contenido: Receptor UART con visualizacion en display 7 segmentos y LEDs
# ================================================================================

# ================================================================================
# 1. LEDs - Visualizacion de datos recibidos (DATO[0..7])
# ================================================================================

# TODO: Asignar pines para los 8 LEDs (DATO[0..7]) que muestran el valor recibido por UART


# Indicador LED de dato recibido (DRI)
set_property PACKAGE_PIN L1  [get_ports {DRI}]      ; # LED LD15 - Indicador de listo


# ================================================================================
# 2. Botones y Entradas de Control (RST)
# ================================================================================
# Boton reset asincrónico (activo en alto)

# TODO: Asignar pin para el boton de reset (RST) que reinicia el sistema de forma asincrona


# ================================================================================
# 3. Display 7 Segmentos - Segmentos Catodos (SS[6..0])
# ================================================================================
# Segmentos del display: conecciones de catodos comun
# Disposicion: a=6, b=5, c=4, d=3, e=2, f=1, g=0

# TODO: Asignar pines para los 7 segmentos del display (SS[6..0]) que muestran el valor recibido por UART


# ================================================================================
# 4. Display 7 Segmentos - Anodos (AN[3..0])
# ================================================================================
# Anodos del display de 4 digitos (catodo comun)

# TODO: Asignar pines para los 4 anodos del display (AN[3..0]) que permiten multiplexar los digitos

# ================================================================================
# 5. Comunicaciones Serie (UART)
# ================================================================================
# Puerto de recepcion UART a 19200 baudios (RS232)

# TODO: Asignar pin para la señal de recepcion UART (RX) que recibe datos desde un dispositivo externo (PC, etc.)

# ================================================================================
# 6. Reloj del Sistema
# ================================================================================
# Oscilador principal de la placa Basys3 (100 MHz)
set_property PACKAGE_PIN W5    [get_ports {CLK}]    ; # Reloj maestro 100 MHz

# ================================================================================
# 7. Configuracion Electrica de I/O (Estandar LVCMOS33 - 3.3V)
# ================================================================================
# Estandar de voltaje para todas las entradas: LVCMOS33 (3.3V, Low Voltage CMOS)
set_property IOSTANDARD LVCMOS33 [get_ports {RST CLK RX}] ; # Entradas

# Estandar de voltaje para todas las salidas: LVCMOS33 (3.3V, Low Voltage CMOS)
set_property IOSTANDARD LVCMOS33 [get_ports {DATO[*] DRI SS[*] AN[*]}] ; # Salidas

# ================================================================================
# 8. Configuracion de Bitstream y Voltaje de Alimentacion
# ================================================================================
# Configuracion de voltaje de referencia del banco de configuracion (CFGBVS)
set_property CFGBVS VCCO [current_design]     ; # Referencia: VCCO (3.3V)
set_property CONFIG_VOLTAGE 3.3 [current_design] ; # Voltaje de configuracion: 3.3V

# ================================================================================
# NOTAS IMPORTANTES:
# ================================================================================
# 1. Asignacion de pines: Valida UNICAMENTE para placa Basys3 Artix7
#    - Otros modelos (Nexys4, etc.) requieren diferentes asignaciones
#    - Consultar documentacion del fabricante para otras placas
#
# 2. Estandar I/O: LVCMOS33 soporta logica de 3.3V
#    - No compatible con conectores de 5V
#    - Verificar voltajes de dispositivos externos conectados
#
# 3. Entradas: RST, RX, CLK
#    - Deben cumplir restricciones de timing definidas en 01_timing.xdc
#    - RX requiere sincronizador en VHDL para evitar metaestabilidad
#
# 4. Salidas: DATO, DRI, SS, AN
#    - Son asincronas respecto a reloj externo
#    - Se dirigen a dispositivos de visualizacion sin restricciones timing
# ================================================================================
