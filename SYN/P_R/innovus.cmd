#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Fri Oct 26 15:25:14 2018                
#                                                     
#######################################################

#@(#)CDS: Innovus v17.11-s080_1 (64bit) 08/04/2017 11:13 (Linux 2.6.18-194.el5)
#@(#)CDS: NanoRoute 17.11-s080_1 NR170721-2155/17_11-UB (database version 2.30, 390.7.1) {superthreading v1.44}
#@(#)CDS: AAE 17.11-s034 (64bit) 08/04/2017 (Linux 2.6.18-194.el5)
#@(#)CDS: CTE 17.11-s053_1 () Aug  1 2017 23:31:41 ( )
#@(#)CDS: SYNTECH 17.11-s012_1 () Jul 21 2017 02:29:12 ( )
#@(#)CDS: CPE v17.11-s095
#@(#)CDS: IQRC/TQRC 16.1.1-s215 (64bit) Thu Jul  6 20:18:10 PDT 2017 (Linux 2.6.18-194.el5)

set_global _enable_mmmc_by_default_flow      $CTE::mmmc_default
suppressMessage ENCEXT-2799
getDrawView
loadWorkspace -name Physical
win
set defHierChar /
set delaycal_input_transition_delay 0.1ps
set fpIsMaxIoHeight 0
set init_gnd_net gnd
set init_mmmc_file Default.view
set init_oa_search_lib {}
set init_pwr_net vdd
set init_verilog DLX_RTL.v
set init_lef_file /software/dk/nangate45/lef/NangateOpenCellLibrary.lef
init_design
getIoFlowFlag
setIoFlowFlag 0
floorPlan -coreMarginsBy die -site FreePDK45_38x28_10R_NP_162NW_34O -r 1.0 0.6 5.0 5.0 5.0 5.0
uiSetTool select
getIoFlowFlag
fit
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
setAddRingMode -ring_target default -extend_over_row 0 -ignore_rows 0 -avoid_short 0 -skip_crossing_trunks none -stacked_via_top_layer metal10 -stacked_via_bottom_layer metal1 -via_using_exact_crossover_size 1 -orthogonal_only true -skip_via_on_pin {  standardcell } -skip_via_on_wire_shape {  noshape }
addRing -nets {gnd vdd} -type core_rings -follow core -layer {top metal9 bottom metal9 left metal10 right metal10} -width {top 0.8 bottom 0.8 left 0.8 right 0.8} -spacing {top 0.8 bottom 0.8 left 0.8 right 0.8} -offset {top 1.8 bottom 1.8 left 1.8 right 1.8} -center 1 -extend_corner {} -threshold 0 -jog_distance 0 -snap_wire_center_to_grid None
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
setAddStripeMode -ignore_block_check false -break_at none -route_over_rows_only false -rows_without_stripes_only false -extend_to_closest_target none -stop_at_last_wire_for_area false -partial_set_thru_domain false -ignore_nondefault_domains false -trim_antenna_back_to_shape none -spacing_type edge_to_edge -spacing_from_block 0 -stripe_min_length 0 -stacked_via_top_layer metal10 -stacked_via_bottom_layer metal1 -via_using_exact_crossover_size false -split_vias false -orthogonal_only true -allow_jog { padcore_ring  block_ring }
addStripe -nets {gnd vdd} -layer metal10 -direction vertical -width 0.8 -spacing 0.8 -set_to_set_distance 20 -start_from left -start_offset 15 -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit metal10 -padcore_ring_bottom_layer_limit metal1 -block_ring_top_layer_limit metal10 -block_ring_bottom_layer_limit metal1 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {  standardcell } -skip_via_on_wire_shape {  noshape }
setSrouteMode -viaConnectToShape { noshape }
sroute -connect { blockPin padPin padRing corePin floatingStripe } -layerChangeRange { metal1(1) metal10(10) } -blockPinTarget { nearestTarget } -padPinPortConnect { allPort oneGeom } -padPinTarget { nearestTarget } -corePinTarget { firstAfterRowEnd } -floatingStripeTarget { blockring padring ring stripe ringpin blockpin followpin } -allowJogging 1 -crossoverViaLayerRange { metal1(1) metal10(10) } -nets { gnd vdd } -allowLayerChange 1 -blockPin useLef -targetViaLayerRange { metal1(1) metal10(10) }
selectWire 101.7300 1.3200 102.5300 208.9600 10 vdd
deselectAll
selectWire 100.1300 2.9200 100.9300 207.3600 10 gnd
deselectAll
setPlaceMode -prerouteAsObs {1 2 3 4 5 6 7 8}
setPlaceMode -fp false
placeDesign
selectInst dp/exe_unit/U34
deselectAll
fit
setDrawView ameba
setDrawView ameba
setDrawView ameba
setDrawView ameba
setDrawView ameba
setDrawView place
getPinAssignMode -pinEditInBatch -quiet
setDrawView ameba
setDrawView place
selectInst dp/ife_unit/BP_UNIT/U789
deselectAll
setDrawView ameba
setDrawView place
getPinAssignMode -pinEditInBatch -quiet
setPinAssignMode -pinEditInBatch true
editPin -fixOverlap 1 -spreadDirection clockwise -side Left -layer 1 -spreadType side -pin {CLK RST}
setPinAssignMode -pinEditInBatch true
editPin -fixOverlap 1 -spreadDirection clockwise -side Top -layer 1 -spreadType side -pin {{EXT_MEM_IN[0]} {EXT_MEM_IN[1]} {EXT_MEM_IN[2]} {EXT_MEM_IN[3]} {EXT_MEM_IN[4]} {EXT_MEM_IN[5]} {EXT_MEM_IN[6]} {EXT_MEM_IN[7]} {EXT_MEM_IN[8]} {EXT_MEM_IN[9]} {EXT_MEM_IN[10]} {EXT_MEM_IN[11]} {EXT_MEM_IN[12]} {EXT_MEM_IN[13]} {EXT_MEM_IN[14]} {EXT_MEM_IN[15]} {EXT_MEM_IN[16]} {EXT_MEM_IN[17]} {EXT_MEM_IN[18]} {EXT_MEM_IN[19]} {EXT_MEM_IN[20]} {EXT_MEM_IN[21]} {EXT_MEM_IN[22]} {EXT_MEM_IN[23]} {EXT_MEM_IN[24]} {EXT_MEM_IN[25]} {EXT_MEM_IN[26]} {EXT_MEM_IN[27]} {EXT_MEM_IN[28]} {EXT_MEM_IN[29]} {EXT_MEM_IN[30]} {EXT_MEM_IN[31]} {IRAM_OUT[0]} {IRAM_OUT[1]} {IRAM_OUT[2]} {IRAM_OUT[3]} {IRAM_OUT[4]} {IRAM_OUT[5]} {IRAM_OUT[6]} {IRAM_OUT[7]} {IRAM_OUT[8]} {IRAM_OUT[9]} {IRAM_OUT[10]} {IRAM_OUT[11]} {IRAM_OUT[12]} {IRAM_OUT[13]} {IRAM_OUT[14]} {IRAM_OUT[15]} {IRAM_OUT[16]} {IRAM_OUT[17]} {IRAM_OUT[18]} {IRAM_OUT[19]} {IRAM_OUT[20]} {IRAM_OUT[21]} {IRAM_OUT[22]} {IRAM_OUT[23]} {IRAM_OUT[24]} {IRAM_OUT[25]} {IRAM_OUT[26]} {IRAM_OUT[27]} {IRAM_OUT[28]} {IRAM_OUT[29]} {IRAM_OUT[30]} {IRAM_OUT[31]}}
setPinAssignMode -pinEditInBatch true
editPin -fixOverlap 1 -spreadDirection clockwise -side Right -layer 1 -spreadType side -pin {{EXT_MEM_ADD[0]} {EXT_MEM_ADD[1]} {EXT_MEM_ADD[2]} {EXT_MEM_ADD[3]} {EXT_MEM_ADD[4]} {D_TYPE[0]} {D_TYPE[1]} {EXT_MEM_DATA[0]} {EXT_MEM_DATA[1]} {EXT_MEM_DATA[2]} {EXT_MEM_DATA[3]} {EXT_MEM_DATA[4]} {EXT_MEM_DATA[5]} {EXT_MEM_DATA[6]} {EXT_MEM_DATA[7]} {EXT_MEM_DATA[8]} {EXT_MEM_DATA[9]} {EXT_MEM_DATA[10]} {EXT_MEM_DATA[11]} {EXT_MEM_DATA[12]} {EXT_MEM_DATA[13]} {EXT_MEM_DATA[14]} {EXT_MEM_DATA[15]} {EXT_MEM_DATA[16]} {EXT_MEM_DATA[17]} {EXT_MEM_DATA[18]} {EXT_MEM_DATA[19]} {EXT_MEM_DATA[20]} {EXT_MEM_DATA[21]} {EXT_MEM_DATA[22]} {EXT_MEM_DATA[23]} {EXT_MEM_DATA[24]} {EXT_MEM_DATA[25]} {EXT_MEM_DATA[26]} {EXT_MEM_DATA[27]} {EXT_MEM_DATA[28]} {EXT_MEM_DATA[29]} {EXT_MEM_DATA[30]} {EXT_MEM_DATA[31]}}
setPinAssignMode -pinEditInBatch true
editPin -fixOverlap 1 -spreadDirection clockwise -side Bottom -layer 1 -spreadType side -pin {{IRAM_ADD[0]} {IRAM_ADD[1]} {IRAM_ADD[2]} {IRAM_ADD[3]} {IRAM_ADD[4]} {IRAM_ADD[5]} {IRAM_ADD[6]} {IRAM_ADD[7]} {IRAM_ADD[8]} {IRAM_ADD[9]} {IRAM_ADD[10]} {IRAM_ADD[11]} {IRAM_ADD[12]} {IRAM_ADD[13]} {IRAM_ADD[14]} {IRAM_ADD[15]} {IRAM_ADD[16]} {IRAM_ADD[17]} {IRAM_ADD[18]} {IRAM_ADD[19]} {IRAM_ADD[20]} {IRAM_ADD[21]} {IRAM_ADD[22]} {IRAM_ADD[23]} {IRAM_ADD[24]} {IRAM_ADD[25]} {IRAM_ADD[26]} {IRAM_ADD[27]} {IRAM_ADD[28]} {IRAM_ADD[29]} {IRAM_ADD[30]} {IRAM_ADD[31]} RW US_MEM}
setPinAssignMode -pinEditInBatch false
getPinAssignMode -pinEditInBatch -quiet
setPinAssignMode -pinEditInBatch true
editPin -pinWidth 0.07 -pinDepth 0.07 -fixOverlap 1 -unit MICRON -spreadDirection clockwise -side Left -layer 1 -spreadType start -spacing 0.14 -start 0.0 0.07 -pin CLK
setPinAssignMode -pinEditInBatch true
editPin -pinWidth 0.07 -pinDepth 0.07 -fixOverlap 1 -unit MICRON -spreadDirection clockwise -side Left -layer 1 -spreadType start -spacing 0.14 -start 0.0 0.07 -pin CLK
setPinAssignMode -pinEditInBatch false
setOptMode -fixCap true -fixTran true -fixFanoutLoad false
optDesign -postCTS
optDesign -postCTS -hold
getFillerMode -quiet
addFiller -cell FILLCELL_X8 FILLCELL_X4 FILLCELL_X32 FILLCELL_X2 FILLCELL_X16 FILLCELL_X1 -prefix FILLER
setNanoRouteMode -quiet -timingEngine {}
setNanoRouteMode -quiet -routeWithSiPostRouteFix 0
setNanoRouteMode -quiet -drouteStartIteration default
setNanoRouteMode -quiet -routeTopRoutingLayer default
setNanoRouteMode -quiet -routeBottomRoutingLayer default
setNanoRouteMode -quiet -drouteEndIteration default
setNanoRouteMode -quiet -routeWithTimingDriven false
setNanoRouteMode -quiet -routeWithSiDriven false
routeDesign -globalDetail
setAnalysisMode -analysisType onChipVariation
setDrawView ameba
setDrawView place
setOptMode -fixCap true -fixTran true -fixFanoutLoad false
optDesign -postRoute
optDesign -postRoute -hold
saveDesign DLX_innovus
set_analysis_view -setup {default} -hold {default}
reset_parasitics
extractRC
rcOut -setload DLX_rc.setload -rc_corner standard
rcOut -setres DLX_rc.setres -rc_corner standard
rcOut -spf DLX_rc.spf -rc_corner standard
rcOut -spef DLX_rc.spef -rc_corner standard
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postRoute -pathReports -drvReports -slackReports -numPaths 50 -prefix DLX_postRoute -outDir timingReports
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postRoute -hold -pathReports -slackReports -numPaths 50 -prefix DLX_postRoute -outDir timingReports
selectWire 5.1300 205.1550 205.5800 205.3250 1 gnd
get_time_unit
report_timing -machine_readable -max_paths 10000 -max_slack 0.75 -path_exceptions all > top.mtarpt
load_timing_debug_report -name default_report top.mtarpt
verifyConnectivity -type all -error 1000 -warning 50
setVerifyGeometryMode -area { 0 0 0 0 } -minWidth true -minSpacing true -minArea true -sameNet true -short true -overlap true -offRGrid false -offMGrid true -mergedMGridCheck true -minHole true -implantCheck true -minimumCut true -minStep true -viaEnclosure true -antenna false -insuffMetalOverlap true -pinInBlkg false -diffCellViol true -sameCellViol false -padFillerCellsOverlap true -routingBlkgPinOverlap true -routingCellBlkgOverlap true -regRoutingOnly false -stackedViasOnRegNet false -wireExt true -useNonDefaultSpacing false -maxWidth true -maxNonPrefLength -1 -error 1000
verifyGeometry
setVerifyGeometryMode -area { 0 0 0 0 }
reportGateCount -level 5 -limit 100 -outfile DLX.gateCount
saveNetlist DLX_psnet.v
all_hold_analysis_views 
all_setup_analysis_views 
write_sdf  -ideal_clock_network DLX_timing.sdf
