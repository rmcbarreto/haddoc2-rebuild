# Haddoc2 rebuild :  Hardware Automated Dataflow Description of CNNs

Haddoc2 is a tool to automatically design FPGA-based hardware accelerators for convolutional neural networks (CNNs). Using a Caffe model, Haddoc2 generates a hardware description of the network (in VHDL-2008) which is constructor and device independent. Haddoc2 is built upon the principals of Dataflow stream-based processing of data, and, implements CNNs using a Direct Hardware Mapping approach, where all the actors involved in CNN processing are physically mapped on the FPGA.
To have the HADDOC2 original version, please visit [this](https://github.com/DreamIP/haddoc2) git page.

This tools was modified and rebuild since I have found several flaws, and is part of my Master Thesis in Eletrical and Computers Engineer Degree.


## Pre-requisite

-   [Caffe](https://github.com/BVLC/caffe) with A simple CPU-only build is needed.
-   [Quartus II](https://www.altera.com/downloads/download-center.html) or [Vivado](https://www.xilinx.com/support/download.html) (Optional) : to compile and synthesize your design (I have used Quartus II 14.1)

## Execution

Haddoc2 rebuild needs to know where your Caffe and Haddoc2 installation directories are. Please add the following environment variables or edit you `.bashrc` file in Linux. For instance :

    export CAFFE_ROOT="$HOME/caffe"
    export HADDOC2_ROOT="$HOME/HADDOC2_REBUILD"

## Generating an example

To run haddoc2 example, please use and edit the makefile in example `example/` directory.

    python3 ../lib/haddoc2.py \
           --proto=<path to caffe prototxt> \
           --model=<path to caffe model> \
           --out=<output directory> \
           --nbits=<fixed point format. Default nbits=8>

`example/caffe` directory contains pre-trained BVLC_caffe model version of the Lenet CNN. Please use the Makefile given to test Haddoc2.

-   `make hdl` generates the VHDL description of the CNN
-   `make quartus_proj` creates a simple Quartus II project to implement LeNet on an Intel Cyclone V FPGA
-   `make compile` lunches Quartus tool to compile and synthesize your design. This command requires `quartus` binary to be on your path (do not recomend using this option)

**Important: Be sure to synthesize your project in VHDL 2008 mode !**

This was tested using the [Terasic DE1-SoC](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&No=836) board with the Intel Cyclone V 5CSEMA5F31C6

The whole pipeline to feed the Haddoc2 rebuild CNN in FPGA is presented in another project [repository](https://github.com/rmcbarreto/DE1-SoC-pipeline-haddoc2-rebuild).

## Haddoc2 rebuild FPGA implementation inputs and outputs

The Haddoc2 rebuild when compiled in FPGA has 5 inputs and 2 outputs. The inputs are:
* clock - Set the system clock.
* reset - Reset the whole system (in run-time processing multiple frames, between each frame a system reset is required).
* enable - Enables the system (it wont work if not at high state).
* in_data - Receives the image data, pixel by pixel.
* in_dv - Is at high state when sending a pixel. If sending a pixel each clock cycle, the in_dv will be at high state while sending the whole image.

the outputs are:
* out_data 
* out_dv

When the **out_dv** is at high state, the **out_data** has received an output of the network. If the network has multiple exits, all **out_data** will have a value when **out_dv** is at high state (because the Haddoc2 maps the whole network in logic design, so the outputs will come all at once). 
    
## Original paper and technical report:
More implementation details can be found in this [technical report](https://arxiv.org/abs/1705.04543) and the this [paper](https://arxiv.org/pdf/1712.04322.pdf)
If you find Haddoc2 useful in your research, please consider citing the following paper

    @article{Abdelouahab17,
    author = {Abdelouahab, Kamel and Pelcat, Maxime and Serot, Jocelyn. and Bourrasset, Cedric and Berry, Fran{\c{c}}ois},
    doi = {10.1109/LES.2017.2743247},
    issn = {19430663},
    journal = {IEEE Embedded Systems Letters},
    keywords = {CNN,Dataflow,FPGA,VHDL},
    pages = {1--4},
    title = {Tactics to Directly Map CNN graphs on Embedded FPGAs},
    url = {http://ieeexplore.ieee.org/document/8015156/},
    year = {2017}}

# TODO

The Haddoc2 rebuil does not work as intended. The structur has been rebuild, but the wheight conversion has not been studied. Maybe is the flaw. 

1.  Add support of BatchNorm / Sigmoid / ReLU layers
2.  Implement Dynamic Fixed Point Arithmetic
3.  Support conv layers with sparse connections (such AlexNet's conv2 layer, where each neuron is connected to only half of conv1 outputs i.e n_outputs(layer-1) != n_inputs(layer) )

# Need any HELP?
If you want any information, feel free to contact me:
rmcbarreto@gmail.com
