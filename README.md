# Lab 4 - Receptor UART (uart_rx)

Módulo receptor UART implementado en VHDL para FPGA Xilinx Basys3. El diseño implementa un receptor serie asíncrono completo con sincronización de entrada, muestreo central de bits y decodificación a display de 7 segmentos.

## 📋 Descripción General

Este proyecto implementa un **receptor UART completo** con manejo robusto de entradas asíncronas, recepción serie a 19200 baud y visualización de datos en display de 7 segmentos y LEDs.

### Características Principales

- **Velocidad de transmisión**: 19200 baud @ 100 MHz
- **Formato de trama**: START (0) + 8 DATA (LSB primero) + STOP (1) = 10 bits totales
- **Sincronización**: 2 registros de metaestabilidad para entrada limpia
- **Muestreo central**: Muestreo de bits en el centro del período (BITCYCLES/2)
- **Decodificación**: Conversión de ASCII a display de 7 segmentos (0-9, A-Z, caracteres especiales)
- **Visualización**: Display de 7 segmentos + 8 LEDs para mostrar datos recibidos
- **Indicador de estado**: LED DRI (Dato Recibido e Indicador de listo)
- **Plataforma**: FPGA Xilinx Basys3 (Artix-7)

---

## 📁 Estructura del Proyecto

```
30315_lab4_solutions/
├── README.md                     # Este archivo
├── constraints/                  # Restricciones de diseño
│   ├── 01_timing.xdc             # Restricciones de timing
│   └── 02_basys3_io.xdc          # Mapeo de I/O Basys3
├── rtl/                          # Código RTL
│   └── uart_rx.vhd               # Módulo receptor UART
├── sim/                          # Simulación
│   ├── uart_rx_tb.vhd            # Testbench principal
│   └── uart_rx_tb_behav.wcfg     # Configuración de formas de onda
├── scripts/                      # Scripts de automatización
│   └── lab.tcl                   # Script TCL para crear proyecto Vivado
└── vivado/                       # Proyecto Vivado (generado)
```

---

## 🔧 Especificaciones Técnicas

### Entradas

| Puerto | Ancho | Tipo | Descripción                                      |
|--------|-------|------|--------------------------------------------------|
| `CLK`  | 1 bit | in   | Reloj del sistema (100 MHz)                      |
| `RST`  | 1 bit | in   | Reset asíncrono activo en alto                   |
| `RX`   | 1 bit | in   | Línea de recepción serie (estado reposo='1')     |

### Salidas

| Puerto | Ancho  | Tipo | Descripción                                           |
|--------|--------|------|-------------------------------------------------------|
| `DATO` | 8 bits | out  | Dato recibido mostrado en LEDs                        |
| `SS`   | 7 bits | out  | Control display 7 segmentos (segmentos a-g)           |
| `AN`   | 4 bits | out  | Anodos del display (4 dígitos, solo se usa el digit 0)|
| `DRI`  | 1 bit  | out  | Dato Recibido e Indicador de listo (activo en alto)  |

### Parámetros de Tiempo

| Parámetro                  | Valor      | Cálculo                   |
|----------------------------|------------|---------------------------|
| **Frecuencia del reloj**   | 100 MHz    | Reloj del sistema         |
| **Baud rate**              | 19200 baud | Velocidad de recepción    |
| **Período de bit UART**    | 52.08 µs   | 1 / 19200 baud = 52.08 µs |
| **Ciclos por bit**         | 5208       | 100 MHz × 52.08 µs        |
| **Ciclos muestreo central**| 2604       | BITCYCLES / 2             |
| **Bits de contador UART**  | 13 bits    | log₂(5208) ≈ 13 bits      |
| **Bits contador de bits**  | 3 bits     | Para contar 0 a 7         |
| **Tiempo sincronización**  | 20 ns      | 2 ciclos de CLK           |

### Información del Dispositivo

- **FPGA**: Xilinx Artix-7 (xc7a35tcpg236-1)
- **Placa**: Digilent Basys3
- **Lenguaje**: VHDL
- **Reloj del sistema**: 100 MHz

---

## 📡 Formato de Trama UART

```
Bit:    0    1    2    3    4    5    6    7    8    9
      ┌────┬────┬────┬────┬────┬────┬────┬────┬────┬────┐
      │ 0  │ D0 │ D1 │ D2 │ D3 │ D4 │ D5 │ D6 │ D7 │ 1  │
      └────┴────┴────┴────┴────┴────┴────┴────┴────┴────┘
      START      8 BITS DE DATOS (LSB primero)      STOP

      Estado de reposo: RX = '1'
      Muestreo: Centro del bit (BITCYCLES/2 desde flanco de bajada)
```

---

## 🛠️ Arquitectura del Diseño

### Componentes del Datapath

1. **Sincronizador de entrada (2 FF)**
   - Elimina metaestabilidad de la señal RX asíncrona
   - Produce `rx_sync` sincronizada con CLK

2. **Registro de desplazamiento Serie/Paralelo (8 bits)**
   - Convierte bits recibidos serie a formato paralelo
   - Desplaza a la derecha introduciendo `rx_sync` por la izquierda

3. **Registro de salida Paralelo/Paralelo (8 bits)**
   - Almacena el dato completo recibido
   - Inicializa a espacio ASCII (0x20) tras reset

4. **Decodificador BIN a 7 segmentos**
   - Convierte códigos ASCII a segmentos del display
   - Soporta: 0-9, A-Z (mayúsculas y minúsculas), espacio y caracteres especiales

5. **Temporizador (13 bits)**
   - Cuenta ciclos de reloj (0 a BITCYCLES-1)
   - Determina centro de bit y final de bit

6. **Contador de bits (3 bits módulo 8)**
   - Cuenta bits de datos recibidos (0 a 7)

### FSM Principal

La máquina de estados finitos tiene **5 estados**:

| Estado   | Descripción                                                    |
|----------|----------------------------------------------------------------|
| `sinc0`  | Sincronización inicial tras reset, espera RX='1'              |
| `reposo` | Estado de reposo, esperando bit de START (RX='0')             |
| `start`  | Detectado START, espera centro del bit para validar           |
| `bitn`   | Recepción de 8 bits de datos (muestreo cada BITCYCLES)        |
| `stop`   | Recepción de bit STOP, validación y carga de dato             |

### Diagrama de Estados

```
       ┌──────────┐
       │  RESET   │
       └────┬─────┘
            │
            v
       ┌─────────┐
    ┌──│  sinc0  │◄──────────────┐
    │  └────┬────┘               │
    │       │ rx_sync='1'        │ rx_sync='0'
    │       v                    │ (error en stop)
    │  ┌─────────┐               │
    └─►│ reposo  │               │
       └────┬────┘               │
            │ rx_sync='0'        │
            │ (START detectado)  │
            v                    │
       ┌─────────┐               │
    ┌──│  start  │──┐            │
    │  └────┬────┘  │            │
    │       │       │ rx_sync='1'│
    │       │       │ (glitch)   │
    │       │       └────────────┘
    │       │ timer >= BITCYCLES_2
    │       │ & rx_sync='0'
    │       v
    │  ┌─────────┐
    │  │  bitn   │◄─┐
    │  └────┬────┘  │
    │       │       │ timer >= BITCYCLES
    │       │       │ & cnt_bit < 7
    │       │       └─ (desplaza bit)
    │       │
    │       │ timer >= BITCYCLES
    │       │ & cnt_bit = 7
    │       v
    │  ┌─────────┐
    │  │  stop   │
    │  └────┬────┘
    │       │ timer >= BITCYCLES
    │       │ & rx_sync='1'
    │       │ (carga_rs='1', DRI='1')
    │       v
    └───────┘
```

### Señales de Control

| Señal            | Descripción                                    |
|------------------|------------------------------------------------|
| `desp_reg_desp`  | Desplaza registro S/P (captura bit)           |
| `carga_rs`       | Carga dato en registro de salida              |
| `ini_timer`      | Inicializa temporizador a 0                   |
| `inc_cntbit`     | Incrementa contador de bits                   |
| `ini_cntbit`     | Inicializa contador de bits a 0               |
| `DRI`            | Indicador de dato recibido y sistema listo    |

---

## 🚀 Uso

### Crear el Proyecto en Vivado

#### Opción 1: Usar el script TCL desde Vivado GUI

1. Abrir **Vivado**
2. Seleccionar **Tools → Run Tcl Script**
3. Navegar a `scripts/lab.tcl` y ejecutarlo
4. El proyecto se creará automáticamente en `vivado/`

#### Opción 2: Ejecutar el script desde línea de comandos

```bash
# Desde el directorio del proyecto
vivado -mode batch -source scripts/lab.tcl
```

#### Opción 3: Ejecutar manualmente en la consola TCL de Vivado

1. Abrir Vivado
2. En la **TCL Console**, ejecutar:
   ```tcl
   cd scripts
   source lab.tcl
   ```

### Simulación

#### Con Vivado

1. Abrir el proyecto: `vivado vivado/lab.xpr`
2. En Flow Navigator → Simulation → **Run Behavioral Simulation**
3. Observar las formas de onda (configuración disponible en `sim/uart_rx_tb_behav.wcfg`)

El testbench incluye los siguientes tests:

- **T1**: Reset y condiciones iniciales
- **T2**: Sincronización de la señal RX
- **T3**: Recepción correcta de un dato
- **T4.1**: Detección de glitch en START (debe volver a reposo)
- **T4.2**: Detección de error en STOP (debe resincronizar)
- **T5**: Recepción de secuencia consecutiva de datos (0-9, espacio)

### Síntesis e Implementación

1. **Run Synthesis** - Sintetiza el diseño
2. **Run Implementation** - Implementa en el dispositivo target
3. **Generate Bitstream** - Genera el archivo `.bit`

### Programación de la Basys3

1. Conectar la placa Basys3 por USB
2. Abrir **Hardware Manager** en Vivado
3. Programar el dispositivo con el bitstream generado

### Operación en Hardware

1. Programar la FPGA con el bitstream
2. Conectar un **transmisor UART externo** al pin RX (B18)
   - Puede ser un módulo USB-UART
   - O un microcontrolador/Arduino configurado a 19200 baud
   - O el transmisor del Lab 3 (uart_tx)
3. Configurar el transmisor a: **19200 baud, 8 bits datos, sin paridad, 1 stop**
4. Enviar un carácter desde el terminal/transmisor
5. Observar:
   - **LEDs LD0-LD7**: Muestran el código ASCII recibido
   - **Display 7 segmentos**: Muestra el carácter decodificado
   - **LED LD15 (DRI)**: Se ilumina cuando hay dato válido recibido

---

## 🔌 Mapeo de Hardware (Basys3)

| Señal      | Hardware          | Pin    | Descripción                                |
|------------|-------------------|--------|--------------------------------------------|
| `CLK`      | Reloj sistema     | W5     | Reloj de 100 MHz de la placa               |
| `RST`      | Botón superior    | T18    | Reset del sistema (BTNU, activo alto)      |
| `RX`       | Pin UART RX       | B18    | Entrada serie de recepción                 |
| `DATO[7:0]`| LEDs 7-0          | V14... | Visualización del dato recibido            |
| `DRI`      | LED 15            | L1     | Indicador de dato recibido y listo         |
| `SS[6:0]`  | Display 7-seg     | W7...  | Segmentos a-g del display (catodos)        |
| `AN[3:0]`  | Display anodos    | U2...  | Anodos del display (solo AN[0] usado)      |

**Ubicación de constraints**: [02_basys3_io.xdc](constraints/02_basys3_io.xdc)

---

## 📚 Documentación

### Archivos Principales

| Archivo                                                      | Descripción                                |
|--------------------------------------------------------------|--------------------------------------------|
| [rtl/uart_rx.vhd](rtl/uart_rx.vhd)                           | Implementación del módulo receptor UART    |
| [sim/uart_rx_tb.vhd](sim/uart_rx_tb.vhd)                     | Testbench principal con emulador de TX     |
| [scripts/lab.tcl](scripts/lab.tcl)                           | Script de creación del proyecto            |
| [constraints/02_basys3_io.xdc](constraints/02_basys3_io.xdc) | Mapeo de pines I/O                         |
| [constraints/01_timing.xdc](constraints/01_timing.xdc)       | Restricciones de timing                    |

### Diagrama de Estados en Línea

Para visualizar el diagrama completo de la FSM, consultar:
🔗 [Diagrama FSM uart_rx](https://tinyurl.com/4jmju6vv)

---

## 📋 Requisitos

### Hardware
- FPGA Xilinx Basys3
- Cable USB para programación
- Transmisor UART externo (USB-UART, Arduino, o Lab3 uart_tx)
- Cables jumper para conexión RX

### Software
- Vivado Design Suite (2019.x o superior)
- VHDL-93/2008 compatible
- Terminal serial (PuTTY, Tera Term, etc.) para enviar datos

---

## 👨‍🏫 Información del Curso

**Asignatura**: 30315 - Electrónica Digital (EDIG)  
**Laboratorio**: Lab 4 - Receptor UART  
**Plataforma**: Basys3 (Artix-7 XC7A35T)

---

*Última actualización: Febrero 2026*
