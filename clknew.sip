set_global_assignment -entity "clknew" -library "lib_clknew" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "clknew" -library "lib_clknew" -name IP_TOOL_VERSION "25.1"
set_global_assignment -entity "clknew" -library "lib_clknew" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_clknew" -name SPD_FILE [file join $::quartus(sip_path) "clknew.spd"]

set_global_assignment -library "lib_clknew" -name MISC_FILE [file join $::quartus(sip_path) "clknew_sim/clknew.vo"]
