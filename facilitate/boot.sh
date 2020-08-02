# Docker Hub Section
export DOCKER_USERNAME='docker user'

# Git Section
export GIT_USERNAME='git user'

# SonarQube Server Section
# Login to SonarQube Server, make a project and generate a token for it.
export SONARQUBE_URL='http://sonarqube-sonarqube.tools.svc.cluster.local:9000'
export SONARQUBE_PROJECT='<project here>'
export SONARQUBE_LOGIN='<login here>'

# The target namespace or project in OpenShift
export BC_PROJECT="bc-light"

./setup-bc-inventory-api.sh
