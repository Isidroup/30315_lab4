# ================================================================
# Script Tcl para Vivado - Pr?ctica labs 30315
# Target: Basys3 - xc7a35tcpg236-1
# Sistema Operativo: Windows
# nota: Utilizar si no funciona lab.tcl
# ================================================================

# ================================================================
# Selecci?n autom?tica de letra libre para subst
# ================================================================

set candidate_letters {V W X Y Z}

# Obtener unidades mapeadas por subst
set subst_drives {}
if {[catch {exec subst} subst_output] == 0} {
    foreach line [split $subst_output "\n"] {
        # Buscamos el patr?n "Z: => C:\ruta"
        if {[regexp {^([A-Z]:)} $line -> drv]} {
            lappend subst_drives [string toupper $drv]
        }
    }
}

# Obtener unidades f?sicas/red detectadas por Tcl
set physical_drives {}
foreach d [file volumes] {
    # Normalizamos a "C:" para comparar
    set clean_d [string toupper [string trimright $d ":/ "]]
    lappend physical_drives "${clean_d}:"
}

set drive ""
foreach letter $candidate_letters {
    set test_drive "${letter}:"

    if {[lsearch -exact $subst_drives $test_drive] != -1} {
        puts ">> Letra $test_drive ya ocupada por SUBST. Re-mapeando..."
        catch {exec subst $test_drive /d}
        set drive $test_drive
        break
    } elseif {[lsearch -exact $physical_drives $test_drive] == -1} {
        set drive $test_drive
        break
    }
}

if {$drive eq ""} {
    error "ERROR: No hay letras libres en el rango V-Z."
}

# Determinar ruta de destino
set current_script [info script]
if {$current_script eq ""} {
    # Si pegas el c?digo en la consola, usamos el directorio actual de Vivado
    set script_path [pwd]
} else {
    set script_path [file normalize [file dirname $current_script]]
}

set target_path [file normalize "$script_path/.."]
set win_target [file nativename $target_path]

puts ">> Ejecutando: subst $drive $win_target"

if {[catch {exec subst $drive $win_target} msg]} {
    puts "Fallo al montar: $msg"
} else {
    puts ">> ?xito: Unidad $drive montada correctamente."
}


# ----------------------------------------------------------------
# 1. Creaci?n del proyecto y cambio al directorio del proyecto
# ----------------------------------------------------------------
create_project lab "$drive/vivado" -part xc7a35tcpg236-1 -force

# Obtener la ruta real del proyecto y moverse a ella
set project_dir [get_property DIRECTORY [current_project]]
cd $project_dir


# ----------------------------------------------------------------
# 2. Configuraci?n del proyecto para trabajar con VHDL
# ----------------------------------------------------------------
set_property target_language VHDL     [current_project]
set_property simulator_language VHDL  [current_project]


# ----------------------------------------------------------------
# 3. A?adir fuentes de dise?o (carpeta rtl)
# ----------------------------------------------------------------
add_files "../rtl"


# ----------------------------------------------------------------
# 4. A?adir archivos de testbench (carpeta sim)
# ----------------------------------------------------------------
add_files -fileset sim_1 "../sim"


# ----------------------------------------------------------------
# 5. A?adir archivos de restricciones (carpeta constraints)
# ----------------------------------------------------------------
add_files -fileset constrs_1 "../constraints"

# Desactivar uso en s?ntesis del archivo de localizaciones
set_property used_in_synthesis false [get_files "../constraints/02_basys3_io.xdc"]
