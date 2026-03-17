# --------------------------------------------------------------------------------
# Archivo: 01_timing.xdc
# Descripcion: Restricciones de temporizacion para diseno uart_rx
# --------------------------------------------------------------------------------

# 1. Definicion del Reloj Principal (CLK)
# --------------------------------------------------------------------------------
# CLK es el reloj principal del diseno y constituye la referencia temporal de
# toda la logica secuencial interna.
#
# Con `create_clock` se define un reloj de 100 MHz, con periodo de 10 ns y
# ciclo de trabajo del 50 %, para que Vivado pueda analizar setup/hold y
# calcular holguras sobre todos los caminos sincronizados a este reloj.
create_clock -add -name sys_clk -period 10.00 -waveform {0 5} [get_ports CLK]


# 2. Entradas Asincronas (RX, RST)
# --------------------------------------------------------------------------------
# Las senales RX y RST pueden cambiar en cualquier instante respecto a `sys_clk`.
# Por tanto, el trayecto que va desde esos pines de entrada hasta el primer
# registro interno no pertenece a un dominio sincronizado con el reloj del sistema.
#
# Con `set_false_path -from` le indicamos a Vivado que no analice ni trate de
# cerrar timing en esos caminos de entrada asincrona. Esta excepcion no elimina
# el analisis del resto del diseno: solo excluye el tramo cuyo origen es RX o RST.
set_false_path -from [get_ports {RX RST}]

# 3. Salidas Asincronas (7 segmentos: SS y AN, DATO, DRI)
# --------------------------------------------------------------------------------
# Estas salidas van a perifericos externos sin un reloj de referencia compartido
# que permita definir requisitos de setup/hold en el pin de salida.
#
# Con `set_false_path -to` evitamos que Vivado intente verificar timing desde la
# logica interna hasta esos puertos. De nuevo, la excepcion afecta solo al tramo
# final hacia SS, AN, DATO y DRI; la temporizacion interna previa sigue analizandose.
set_false_path -to [get_ports {SS AN DATO DRI}]


# 4. Sincronizacion y Prevencion de Metaestabilidad
# --------------------------------------------------------------------------------
# Para evitar fallos por metaestabilidad al leer senales externas asincronas,
# se utiliza una cadena de registros (sincronizador).
#
# El primer biestable de esa cadena (*_meta_*) recibe una senal que, por definicion,
# puede violar setup/hold. Ese riesgo no se corrige con cierre de timing, sino con
# la propia estructura del sincronizador.
#
# Por eso se marca como `false_path` el camino hasta esos registros iniciales:
# Vivado ignora esas violaciones esperables y centra el analisis en los caminos
# sincronizados a partir de la salida del sincronizador.

set_false_path -to [get_cells *_meta_*]


# 5. Propiedades ASYNC_REG para Sincronizadores
# --------------------------------------------------------------------------------
# Los registros marcados como `*_meta_*` y `*_sync_*` forman parte del
# sincronizador de entrada y deben mantenerse como una estructura fisicamente
# cercana y estable.
#
# Con la propiedad `ASYNC_REG` se informa a Vivado de que esos biestables
# pertenecen a una cadena de sincronizacion. Esto favorece una colocacion
# adecuada y evita optimizaciones, como el retiming, que podrian reducir la
# robustez frente a metaestabilidad.
set_property ASYNC_REG TRUE [get_cells {*_meta_* *_sync_*}]

# --------------------------------------------------------------------------------
# RESUMEN DE ESTRATEGIA:
# - Reloj maestro: define la base temporal para analizar toda la logica interna.
# - False paths: excluyen unicamente los trayectos asincronos cuya temporizacion
#   no puede modelarse de forma determinista.
# - ASYNC_REG: identifica la cadena de sincronizacion para mejorar su implementacion
#   fisica y aumentar la tolerancia a metaestabilidad.
# --------------------------------------------------------------------------------
