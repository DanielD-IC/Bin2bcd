onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/u_bin2bcd/clk
add wave -noupdate /tb/u_bin2bcd/rstn
add wave -noupdate /tb/u_bin2bcd/bin_vld
add wave -noupdate /tb/bin
add wave -noupdate /tb/u_bin2bcd/bin_abs_w
add wave -noupdate /tb/u_bin2bcd/bin_abs
add wave -noupdate {/tb/u_bin2bcd/bcd_pipeline_cyc[0]}
add wave -noupdate {/tb/u_bin2bcd/bcd_pipeline_cyc[1]}
add wave -noupdate {/tb/u_bin2bcd/bcd_pipeline_cyc[2]}
add wave -noupdate {/tb/u_bin2bcd/bcd_pipeline_cyc[3]}
add wave -noupdate {/tb/u_bin2bcd/bcd_pipeline_cyc[4]}
add wave -noupdate /tb/u_bin2bcd/bcd_th
add wave -noupdate /tb/u_bin2bcd/bcd_hu
add wave -noupdate /tb/u_bin2bcd/bcd_ten
add wave -noupdate /tb/u_bin2bcd/bcd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {125880 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {19512600 ps} {29085980 ps}
