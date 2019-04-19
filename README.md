# spark-submitAutoConfig
an web-based application to provide the best spark-submit configuration
When we're running spark jobs on EMR, often we're asking what's the best/recommended values for --num-executors, --executor-cores, --executor-memory. These three numbers plays a big role in our MapReduce Job performances. How do we run this job: 

spark-submit --class <CLASS_NAME> --num-executors ? --executor-cores ? --executor-memory ? ....
