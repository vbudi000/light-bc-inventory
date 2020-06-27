#!/bin/sh

echo "working on project ${BC_PROJECT}"
oc project ${BC_PROJECT}
oc status

PS3='Please enter your choice: '
options=("setup pipeline" "run pipeline" "setup triggers" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "setup pipeline")

            echo "setup pipeline in namespace ${BC_PROJECT}"

            #1 setup tekton resources
            echo "************************ setup Tekton PipelineResources ******************************************"
            sed -i "s/ibmcase/${DOCKER_USERNAME}/g" ../tekton/PipelineResources/bluecompute-inventory-pipeline-resources.yaml
            sed -i "s/phemankita/${GIT_USERNAME}/g" ../tekton/PipelineResources/bluecompute-inventory-pipeline-resources.yaml
            oc apply -f ../tekton/PipelineResources/bluecompute-inventory-pipeline-resources.yaml
            #oc get PipelineResources
            tkn resources list

            #2 - setup tekton tasks to interact with OpenShift
            echo "************************ setup Tekton Tasks for OCP ******************************************"
            oc apply -f https://raw.githubusercontent.com/openshift/pipelines-tutorial/release-tech-preview-1/01_pipeline/01_apply_manifest_task.yaml
            oc apply -f https://raw.githubusercontent.com/openshift/pipelines-tutorial/release-tech-preview-1/01_pipeline/02_update_deployment_task.yaml
            tkn task list

            #3 - setup tekton pipeline 
            echo "************************ setup Tekton Pipeline ******************************************"
            oc apply -f pipeline.yaml
            tkn pipeline list

            break
            ;;
        "run pipeline")
            echo "run pipeline in namespace ${BC_PROJECT}"
            tkn pipeline start build-and-deploy -r git-repo=git-source-inventory -r image=docker-image-inventory -p deployment-name=inventory-api
            break
            ;;
        "setup triggers")
            echo "setup triggers in namespace ${BC_PROJECT}"
            break
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
echo "hello kitty catt"
