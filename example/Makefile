all: hdl quartus_proj
clean:
	rm -rf ./hdl_generated
	rm -rf ./build
	rm -rf ./db
	rm -rf ./incremental_db
	#rm -f ./quartus/cnn_process.qsf
	#rm -f ./quartus/cnn_process.qpf
	rm -rf ./quartus
	rm -f ./*.rpt
hdl:
	python3 ../lib/haddoc2.py \
	--proto=./caffe/lenet.prototxt \
	--model=./caffe/lenet.caffemodel \
	--out=./hdl_generated \
	--nbits=8
quartus_proj:
	python3 ../lib/quartus.py ./quartus
compile:
	cd ./quartus
	quartus_map cnn_process -c cnn_process
	quartus_fit cnn_process -c cnn_process
