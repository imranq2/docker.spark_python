build:
	docker build -t imranq2/spark_python:0.1.11 .

shell:
	docker run -it imranq2/spark_python:0.1.11 sh
