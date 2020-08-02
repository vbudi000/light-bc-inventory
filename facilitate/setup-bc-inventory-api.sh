#!/bin/sh

clear
echo "working on project ${BC_PROJECT}"
echo "----------------------------------------------------------------------------------------------" 
oc project ${BC_PROJECT}
oc status  --suggest

echo "----------------------------------------------------------------------------------------------" 
echo "Welcome"
echo "Typically you will setup the Tekton pipeline first as a one time activity."
echo "Next, you can run the pipeline as many times as you like."

PS3='Please enter your choice: '
options=("setup pipeline" "run pipeline" "add sonar scan to pipeline" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "setup pipeline")

            echo "setup pipeline in namespace ${BC_PROJECT}"

            #1 setup tekton resources
            echo "************************ setup Tekton PipelineResources ******************************************"
            cp ../tekton/PipelineResources/bluecompute-inventory-pipeline-resources.yaml ../tekton/PipelineResources/bluecompute-inventory-pipeline-resources.yaml.mod
            sed -i "s/ibmcase/${DOCKER_USERNAME}/g" ../tekton/PipelineResources/bluecompute-inventory-pipeline-resources.yaml.mod
            sed -i "s/phemankita/${GIT_USERNAME}/g" ../tekton/PipelineResources/bluecompute-inventory-pipeline-resources.yaml.mod
            oc apply -f ../tekton/PipelineResources/bluecompute-inventory-pipeline-resources.yaml.mod
            rm ../tekton/PipelineResources/bluecompute-inventory-pipeline-resources.yaml.mod
            #oc get PipelineResources
            tkn resources list

            #2 - setup tekton tasks to interact with OpenShift
            # credits: https://github.com/openshift/pipelines-tutorial/
            # licensed under Apache 2.0
            echo "************************ setup Tekton Tasks for interacting with OpenShift ******************************************"
            oc apply -f 01_apply_manifest_task.yaml
            oc apply -f 02_update_deployment_task.yaml
            oc apply -f 03_restart_deployment_task.yaml
            oc apply -f 04_build_vfs_storage.yaml
            tkn task list

            #3 - setup tekton pipeline 
            echo "************************ setup Tekton Pipeline ******************************************"
            #oc apply -f pipeline.yaml
            oc apply -f pipeline-vfs.yaml
            tkn pipeline list

            break
            ;;
        "run pipeline")
            echo "run pipeline in namespace ${BC_PROJECT}"
            tkn pipeline start build-and-deploy-java -r git-repo=git-source-inventory -r image=docker-image-inventory -p deployment-name=catalog-lightblue-deployment
            break
            ;;
        "setup triggers")
            echo "setup triggers in namespace ${BC_PROJECT}"
            break
            ;;
        "add sonar scan to pipeline")

            echo "updating pipeline to perform a sonar qube scan"
            oc apply -f 05_java_sonarqube_task.yaml
            tkn task list

            oc apply -f pipeline-vfs-sonar.yaml
            tkn pipeline list

            echo "using SONARQUBE_URL=${SONARQUBE_URL}"
            oc delete configmap sonarqube-config-java 2>/dev/null
            oc create configmap sonarqube-config-java \
              --from-literal SONARQUBE_URL=${SONARQUBE_URL}
            
            # TODO: make project name configurable             
            oc delete secret sonarqube-access-java 2>/dev/null
            oc create secret generic sonarqube-access-java \
              --from-literal SONARQUBE_PROJECT=${SONARQUBE_PROJECT} \
              --from-literal SONARQUBE_LOGIN=${SONARQUBE_LOGIN} 

            break
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
echo "hello kitty catt"
