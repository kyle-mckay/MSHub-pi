#!/bin/bash

#region config
    #0 = false
    #1 = true
    SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    b_install_docker=1 #if true then docker and each compose will attempt to install on execution 
        b_compose_nextcloud=0
        b_compose_portainer=1
        b_compose_radarr=1
        b_compose_sonarr=1
        b_compose_qbittorrent=1
        b_compose_plex=1
    b_install_cockpit=1
#endregion

#region functions
addtolog () {
    #adds the passed string to a log file with a timestamp prefix
    timestamp=`date "+%Y/%m/%d %H:%M:%S.%3N"` #add %3N as we want millisecond too
    echo "$timestamp | $1" >> log.txt # add to log
    echo $1
}
docker_install () {
    #install docker
    #https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
    #set up repository
        sudo apt-get update
        yes | sudo apt-get install \
            ca-certificates \
            curl \
            gnupg \
            lsb-release
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    #install docker engine
        sudo apt-get update
        yes | sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin #latest
}
docker_helloworld () {
    #attempts to run the offocial docker test image to verify it is installed before proceeding
    dockertest=`sudo docker run hello-world`
    #check if docker test passes
    SUB='Hello from Docker!'
    if [[ "$dockertest" == *"$SUB"* ]] 
    then
        addtolog "INFO: Docker test has passed"
        b_testdocker=1
    else
        addtolog "WARNING: Docker test has failed"
        b_testdocker=0
    fi
}
cockpit_install () {
    . /etc/os-release
    yes | sudo apt install -t ${VERSION_CODENAME}-backports cockpit
}
#endregion

#region docker
if $b_install_docker -eq 1
then
    addtolog "INFO: Installing Docker"
    #test docker
        #confirm if docker is installed already before proceeding
    #install docker
        docker_install
        docker_helloworld
    #region docker compose
    if $b_testdocker -eq 1
    then
        # begin compose setups
        compose="${SCRIPT_DIR}/docker/compose/"
    else
        addtolog "WARNING: Hello world failed to test, cannot proceed with docker compse"
    fi
    #endregion
else
    addtolog "INFO: Docker set to not install"
fi
#endregion



#region other installations
if $b_install_cockpit -eq 1
then
    addtolog "INFO: Installing Cockpit"
    cockpit_install
else
    addtolog "INFO: Cockpit set to not install"
fi
#endregion