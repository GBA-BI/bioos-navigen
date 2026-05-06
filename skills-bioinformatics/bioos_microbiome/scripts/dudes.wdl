version 1.0

workflow Tool_DUDes {

	input {
		File sam  
		File database 
		String threads 
	}

	call DUDes {
		input: sam = sam, database = database, threads = threads
	}

}

task DUDes {
	input {
		File sam  
		File database 
		String threads 
	}

	command {
		/opt/conda/bin/DUDes.py -s ~{sam} -d ~{database} -t ~{threads} -o dudes_output
	}

	output {
		File dudes_outputs = "dudes_output.out"
	}

	runtime {
		docker: "registry-vpc.miracle.ac.cn/nmdc/dudes:latest"
		cpu: 16
		memory: "48 GB"
	}
}

