#!/bin/bash

CLUSTER_AGENT_S247_FOLDER=/home/site24x7
CLUSTER_AGENT_MONAGENT_FOLDER=$CLUSTER_AGENT_S247_FOLDER/monagent
CLUSTER_AGENT_CONF_FOLDER=$CLUSTER_AGENT_MONAGENT_FOLDER/conf
CLUSTER_AGENT_DEVOPS_FOLDER=$CLUSTER_AGENT_MONAGENT_FOLDER/lib/devops
CLUSTER_AGENT_STARTER_FILE=$CLUSTER_AGENT_DEVOPS_FOLDER/source/python3.3/src/com/manageengine/monagent/kubernetes/ClusterAgent
CLUSTER_AGENT_LOGS_FOLDER=$CLUSTER_AGENT_MONAGENT_FOLDER/logs
CLUSTER_AGENT_DETAILS_LOGS_FOLDER=$CLUSTER_AGENT_LOGS_FOLDER/details



extract_cluster_agent_source(){
    unzip $CLUSTER_AGENT_DEVOPS_FOLDER/kubernetes.zip -d $CLUSTER_AGENT_DEVOPS_FOLDER
    if [ $? = 0 ]
    then
        rm -rf $CLUSTER_AGENT_DEVOPS_FOLDER/kubernetes.zip
        printf "************* Extraction completed Successfully *************\n\n"
        ls -la
        printf "\n\n**************************************************************\n\n"
    fi
	
    if [ ! -f $CLUSTER_AGENT_CONF_FOLDER/logging.xml ]; then
	    mv logging.xml $CLUSTER_AGENT_CONF_FOLDER/logging.xml
    fi
}

setup_cluster_agent_build(){
    x=1
    while [ $x -le 60 ]
    do
        if [ ! -d $CLUSTER_AGENT_DEVOPS_FOLDER ]; then
            create_monagent_dir
        fi
       
        if [ $(download_build) = "success" ]
        then
	    printf "************* Cluster Agent Build Downloaded Successfully *************\n\n"
            break
        fi
        x=$(( $x+1 ))
        printf "Not able to download Cluster Agent Build - Retry after 1 minute \n"
        sleep 60
    done
}

download_build(){
    domain_list=("com" "in" "eu" "cn" "net.au" "jp")
    for domain in ${domain_list[@]};
    do
    	wget -P $CLUSTER_AGENT_DEVOPS_FOLDER https://gihub.$domain/bharathveerakumar/kubernetes-event-metrices/raw/main/kubernetes.zip --no-check-certificate	   
        if [ $? = 0 ]
        then
            echo "success"
            break
        fi
	sleep 2
    done
    echo "failed"
}

start_cluster_agent_app(){
    x=1
    while [ $x -le 10 ]
    do
        /usr/local/bin/gunicorn -c $CLUSTER_AGENT_S247_FOLDER/gunicorn.conf.py --chdir $CLUSTER_AGENT_STARTER_FILE ClusterAgentApp:app &
        if [ $? = 0 ]
        then
            printf "\n\n************************* Cluster Agent Started Successfully ************************\n\n"
	    sleep 5
            break
        fi
        x=$(( $x+1 ))
        printf "Not able to start the Gunicorn App - Retry after 1 minute \n"
        sleep 60
    done
}

create_monagent_dir(){
	mkdir $CLUSTER_AGENT_MONAGENT_FOLDER
	mkdir $CLUSTER_AGENT_CONF_FOLDER
	mkdir $CLUSTER_AGENT_MONAGENT_FOLDER/lib
	mkdir $CLUSTER_AGENT_DEVOPS_FOLDER
}

create_log_folder(){
    mkdir $CLUSTER_AGENT_LOGS_FOLDER
    mkdir $CLUSTER_AGENT_DETAILS_LOGS_FOLDER
    touch $CLUSTER_AGENT_LOGS_FOLDER/access.txt
    touch $CLUSTER_AGENT_DETAILS_LOGS_FOLDER/stderr.txt
}


setup_cluster_agent_build
extract_cluster_agent_source
create_log_folder
start_cluster_agent_app




exec "$@"
