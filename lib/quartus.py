#!/usr/bin/env python
# -*- coding: UTF-8 -*-

# ----------------------------------------------------------------------------
# Title      : quartus
# Project    : Haddoc2
# ----------------------------------------------------------------------------
# File       : quartus.py
# Author     : K. Abdelouahab
# Company    : Institut Pascal
# Last update: 07-07-2017
# ----------------------------------------------------------------------------
# Modified by	: Ricardo Barreto
# e-mail		: rmcbarreto@gmail.com
# Last update	: 05-10-2019
# ----------------------------------------------------------------------------
# Description: Script to create a Quartus project using generated Haddoc2 VHDL
# and Haddoc2 IP library. FPGA here is Terasic DE1-SoC with Cyclone V 5CSEMA5F31C6
# ----------------------------------------------------------------------------

import sys
import os


def gen_qsf(qsf_file, haddoc2_hdl_lib, top_level_dir):
    #print("Haddoc2 lib in " + haddoc2_hdl_lib)
    with open(qsf_file, 'w') as f:
        # Device
        f.write("set_global_assignment -name FAMILY \"CYCLONE V\"\n")
        f.write("set_global_assignment -name DEVICE 5CSEMA5F31C6\n")
        f.write("set_global_assignment -name ORIGINAL_QUARTUS_VERSION 16.0\n")
        f.write("set_global_assignment -name TOP_LEVEL_ENTITY cnn_process\n")
        f.write("set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0\n")
        f.write("set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85\n")
        f.write(
            "set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top\n")
        f.write("set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top\n")
        f.write(
            "set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top\n")
        f.write("set_global_assignment -name POWER_PRESET_COOLING_SOLUTION \"23 MM HEAT SINK WITH 200 LFPM AIRFLOW\"\n")
        f.write(
            "set_global_assignment -name POWER_BOARD_THERMAL_MODEL \"NONE (CONSERVATIVE)\"\n")
        f.write("set_global_assignment -name PROJECT_OUTPUT_DIRECTORY build\n")
        f.write("set_global_assignment -name NUM_PARALLEL_PROCESSORS 4\n")

        # Logic Elements Based arithmetic
        f.write("set_global_assignment -name DSP_BLOCK_BALANCING \"LOGIC ELEMENTS\"\n")
        f.write("set_global_assignment -name AUTO_DSP_RECOGNITION OFF\n")


		# ADDED - Set VHDL and Verilog Version
        f.write("set_global_assignment -name VHDL_INPUT_VERSION VHDL_2008\n")
        f.write("set_global_assignment -name VHDL_SHOW_LMF_MAPPING_MESSAGES OFF\n")
        f.write("set_global_assignment -name VERILOG_INPUT_VERSION SYSTEMVERILOG_2005\n")
        f.write("set_global_assignment -name VERILOG_SHOW_LMF_MAPPING_MESSAGES OFF\n")

        # Generated files
        f.write("set_global_assignment -name VHDL_FILE ../hdl_generated/bitwidths.vhd\n")
        #f.write("set_global_assignment -name VHDL_FILE ../../lib/hdl/cnn_types.vhd\n")
        f.write("set_global_assignment -name VHDL_FILE ../hdl_generated/params.vhd\n")
        f.write("set_global_assignment -name VHDL_FILE ../hdl_generated/cnn_process.vhd\n")

        # SDC File for timing - do not exist...
        #f.write("set_global_assignment -name VHDL_FILE ../hdl_generated/../cnn_process.sdc\n")

        # Haddoc2 lib
        f.write("set_global_assignment -name VHDL_FILE ../../lib/hdl/cnn_types.vhd\n")
        f.write("set_global_assignment -name VHDL_FILE ../../lib/hdl/InputLayer.vhd\n")
        f.write("set_global_assignment -name VHDL_FILE ../../lib/hdl/DisplayLayer.vhd\n")
        f.write("set_global_assignment -name VHDL_FILE ../../lib/hdl/ConvLayer.vhd\n")
        f.write("set_global_assignment -name VHDL_FILE ../../lib/hdl/MCM.vhd\n")
        f.write("set_global_assignment -name VHDL_FILE ../../lib/hdl/MOA.vhd\n")
        f.write("set_global_assignment -name VHDL_FILE ../../lib/hdl/DotProduct.vhd\n")
        f.write("set_global_assignment -name VHDL_FILE ../../lib/hdl/myTaps.vhd\n")
        f.write("set_global_assignment -name VHDL_FILE ../../lib/hdl/NeighExtractor.vhd\n")
        f.write("set_global_assignment -name VHDL_FILE ../../lib/hdl/TensorExtractor.vhd\n")
        f.write("set_global_assignment -name VHDL_FILE ../../lib/hdl/TanhLayer.vhd\n")
        f.write("set_global_assignment -name VHDL_FILE ../../lib/hdl/PoolLayer.vhd\n")
        f.write("set_global_assignment -name VHDL_FILE ../../lib/hdl/poolV.vhd\n")
        f.write("set_global_assignment -name VHDL_FILE ../../lib/hdl/poolH.vhd\n")
        f.write("set_global_assignment -name VHDL_FILE ../../lib/hdl/maxPool.vhd\n")
        f.write("set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top\n")
        f.close()


def gen_qpf(qpf_file):
    with open(qpf_file, 'w') as f:
        f.write("QUARTUS_VERSION = \"18.0\"\n")
        f.write("PROJECT_REVISION = \"cnn_process\"\n")
        f.close()


def generateProject(haddoc2_hdl_lib,
                    top_level_dir,
                    out_dir):
    if not os.path.exists(out_dir):
        os.makedirs(out_dir)
    print("Haddoc2 Quartus Project Generator:")
    qsf_file = out_dir + "/cnn_process.qsf"
    qpf_file = out_dir + "/cnn_process.qpf"
    print("\tQSF File: " + qsf_file)
    print("\tQPF File: " + qpf_file)
    gen_qsf(qsf_file, haddoc2_hdl_lib, top_level_dir)
    gen_qpf(qpf_file)
    print("Succefully generated quartus project")


if __name__ == '__main__':
    if (len(sys.argv) == 2):
        cwd = os.getcwd()
        cwd = '/'.join(cwd.split('\\'))
        out_dir = sys.argv[1]
        generateProject(haddoc2_hdl_lib=cwd + '/../lib/hdl',
                        top_level_dir=cwd + '/hdl_generated',
                        out_dir=out_dir)
    else:
        print('Not enought arguments')
        print('python quartus.py <hdl_directory>')
