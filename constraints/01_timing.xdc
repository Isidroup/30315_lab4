# --------------------------------------------------------------------------------
# Archivo: 01_timing.xdc
# Descripcion: Restricciones de temporizacion para diseno uart_rx
# --------------------------------------------------------------------------------

# 1. Definicion del Reloj Maestro
# --------------------------------------------------------------------------------
# Se define el reloj principal del sistema (CLK) con una frecuencia de 100 MHz.
# Este comando establece la referencia base para todo el analisis de timing interno.
# Periodo: 10ns | Duty Cycle: 50%
create_clock -add -name sys_clk -period 10.00 -waveform {0 5} [get_ports CLK]


# 2. Entradas Asincronas (RX, RST)
# --------------------------------------------------------------------------------
# Las senales RX y RST son asincronas: no tienen una relacion de fase fija
# con el reloj del sistema y su cambio depende de la interaccion humana.
#
# Se aplica 'set_false_path' para indicar a Vivado que no intente cumplir tiempos
# de setup/hold en estos puertos, ya que fisicamente es imposible garantizarlos.
set_false_path -from [get_ports {RX RST}]

# 3. Salidas Asincronas (7 segmentos: SS y AN, DATO, DRI)
# --------------------------------------------------------------------------------
# Las senales de salida hacia los 7 segmentos y el display de datos (SS, AN, DATO, DRI)
# son asincronas respecto a cualquier reloj externo, ya que se dirigen a dispositivos.
# Se aplica 'set_false_path' para indicar a Vivado que no intente cumplir tiempos
# de setup/hold en estos puertos, ya que fisicamente es imposible garantizarlos.
set_false_path -to [get_ports {SS AN DATO DRI}]


# 4. Sincronizacion y Prevencion de Metaestabilidad
# --------------------------------------------------------------------------------
# Para evitar fallos por metaestabilidad al leer senales externas asincronas,
# se utiliza una cadena de registros (sincronizador).
#
# Restringimos el camino hacia los primeros registros de sincronizacion (*_meta_*)
# como 'false_path' para que el analizador de tiempos ignore las violaciones.

set_false_path -to [get_cells *_meta_*]


# 5. Propiedades ASYNC_REG para Sincronizadores
# Identifica registros de sincronizacion para maximizar el MTBF (tiempo medio entre fallos),
# forzando su proximidad fisica y desactivando optimizaciones logicas (retiming) que
# podrian comprometer la resolucion de metaestabilidad.
set_property ASYNC_REG TRUE [get_cells {*_meta_* *_sync_*}]

# --------------------------------------------------------------------------------
# RESUMEN DE ESTRATEGIA:
# - Reloj: unica restriccion estricta para asegurar que la logica interna funcione.
# - False Paths: Se aplican a todas las I/O que no comparten un reloj comun con
#   dispositivos externos, optimizando el tiempo de compilacion y el uso de recursos.
# --------------------------------------------------------------------------------
