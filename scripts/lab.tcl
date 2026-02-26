# ================================================================
# Script Tcl para Vivado - Practica labs 30315
# Target: Basys3 - xc7a35tcpg236-1
# Sistema Operativo: Windows, Linux
# ================================================================

# 0. Configuracion basica
set script_dir [file dirname [info script]]

# 1. Crear proyecto y cambia a la carpeta del proyecto
create_project lab "$script_dir/../vivado" -part xc7a35tcpg236-1 -force
set project_dir [get_property DIRECTORY [current_project]]
cd $project_dir

# 2. Configuracion del proyecto para trabajar con VHDL
set_property target_language VHDL [current_project]
set_property simulator_language VHDL [current_project]

# 3. Anadir fuentes de diseno, situadas en la carpeta rtl
add_files ../rtl

# 4. Anadir archivos de testbench, situados en la carpeta sim
add_files -fileset sim_1 ../sim

# 5. Anadir archivos de restricciones, situados en la carpeta constraints
add_files -fileset constrs_1 ../constraints

# 5.1 EL fichero de localizaciones no se usa en sintesis
set_property used_in_synthesis false [get_files  ../constraints/02_basys3_io.xdc]
