#!/bin/bash
# curl --insecure --location --request POST 'https://172.16.2.249:8443/oauth/token?username=admin&password=Hello123&grant_type=password' --header 'Authorization: Basic aGNkLWNsaWVudDpoY2Qtc2VjcmV0'
# {"access_token":"21358ebb-e452-48c4-800b-2638d4daa9cc","token_type":"bearer","refresh_token":"b9d05e60-14aa-4bb2-b1ce-001e97b7852d","expires_in":42648,"scope":"read write"}
TOKEN=0e991065-4f5a-47c8-8bf0-978359e43c72
MGMT_IP=172.16.2.246
MGMT_PORT=8443
SVIP=192.168.2.246
SVIP_PORT=3260

function create_cluster() {
    HOSTS=$(curl --insecure --location --request GET 'https://'$MGMT_IP':'$MGMT_PORT'/v1/hosts' --header 'Authorization: Bearer '${TOKEN} | jq '[.data | .[] | .hostId]')
    echo "* Available hosts=$HOSTS"
    CREATE_CLUSTER_JSON_TEMPLATE="
    {
      \"cluster\":{
            \"clusterName\": \"cluster1\",
            \"minClusterSize\": 3,
            \"replicationFactor\": 3,
            \"virtualIp\": \"$SVIP\"
       },
      \"hosts\": []
    }
    "
    CREATE_CLUSTER_INPUT=$(echo $CREATE_CLUSTER_JSON_TEMPLATE | jq '.hosts='"$HOSTS"'')
    echo $CREATE_CLUSTER_INPUT
    # create cluster
    CREATE_CLUSTER_RET=$(curl --insecure --location --request POST 'https://'$MGMT_IP':'$MGMT_PORT'/v1/clusters' --header 'Authorization: Bearer '$TOKEN -d "$CREATE_CLUSTER_INPUT" -H "Content-Type: application/json")
    # {
    #   "clusterId": "9f50bf51-392d-47e2-a0f6-ed2da988e35a",
    #   "clusterName": "cluster1",
    #   "clusterNumericalId": 3,
    #   "minClusterSize": 3,
    #   "state": "INIT",
    #   "replicationFactor": 3,
    #   "blockSize": 4096,
    #   "healthState": "UNKNOWN",
    #   "tolerableDiskFailureCount": 0,
    #   "tolerableNodeFailureCount": 0,
    #   "totalSpace": 0,
    #   "usedSpace": 0,
    #   "usableSpace": 0,
    #   "virtualIp": "192.168.8.249",
    #   "clusterAccessLevel": "READ_WRITE",
    #   "type": "REGULAR",
    #   "clusterUpdateTime": 1615788740204,
    #   "clusterCreateTime": 1615788740204
    # }
    CLUSTER_ID=$(echo $CREATE_CLUSTER_RET | jq --raw-output .clusterId)
    echo "* Create cluster done. clusterId=$CLUSTER_ID"
}

# create volumes
function create_volumes() {
    # VOL_SIZE=8796093022208
    local VOL_NUM=$1
    local VOL_SIZE=$2
    CREATE_VOLUME_JSON_TEMPLATE="
    {
        \"volumeName\": \"\",
        \"clusterId\": \"$CLUSTER_ID\",
        \"volumeSize\": $VOL_SIZE,
        \"blockSize\": 4096
    }
    "
    local VOLUME_ID_ARRAY=""
    for i in `seq 1 $VOL_NUM`; do
        local VOL_NAME=$(openssl rand -hex 12)
        local CREATE_VOL_INPUT=$(echo $CREATE_VOLUME_JSON_TEMPLATE | jq '.volumeName="'$VOL_NAME'"')
        local CREATE_VOL_RET=$(curl --insecure --location --request POST 'https://'$MGMT_IP':'$MGMT_PORT'/v1/volumes' --header 'Authorization: Bearer '$TOKEN -d "$CREATE_VOL_INPUT" -H "Content-Type: application/json")
        local VOL_ID_OBJ=$(echo $CREATE_VOL_RET | jq --raw-output '{id: .volumeId}')
        if [ -z "$VOLUME_ID_ARRAY" ]; then
            VOLUME_ID_ARRAY=$VOL_ID_OBJ
        else
            VOLUME_ID_ARRAY="$VOLUME_ID_ARRAY, $VOL_ID_OBJ"
        fi
    done
    VOLUME_ID_ARRAY="[$VOLUME_ID_ARRAY]"
    echo "$VOLUME_ID_ARRAY"
    # CREATE_VOL1_INPUT=$(echo $CREATE_VOLUME_JSON_TEMPLATE | jq '.volumeName="vol1"')
    # CREATE_VOL_RET=$(curl --insecure --location --request POST 'https://'$MGMT_IP':'$MGMT_PORT'/v1/volumes' --header 'Authorization: Bearer '$TOKEN -d "$CREATE_VOL1_INPUT" -H "Content-Type: application/json")
    # CREATE_VOL2_INPUT=$(echo $CREATE_VOLUME_JSON_TEMPLATE | jq '.volumeName="vol2"')
    # CREATE_VOL_RET=$(curl --insecure --location --request POST 'https://'$MGMT_IP':'$MGMT_PORT'/v1/volumes' --header 'Authorization: Bearer '$TOKEN -d "$CREATE_VOL2_INPUT" -H "Content-Type: application/json")
    # CREATE_VOL3_INPUT=$(echo $CREATE_VOLUME_JSON_TEMPLATE | jq '.volumeName="vol3"')
    # CREATE_VOL_RET=$(curl --insecure --location --request POST 'https://'$MGMT_IP':'$MGMT_PORT'/v1/volumes' --header 'Authorization: Bearer '$TOKEN -d "$CREATE_VOL3_INPUT" -H "Content-Type: application/json")
    # echo $CREATE_VOL_RET | jq
    # {
    #   "volumeId": "72b4c81d-ffda-4e9c-af69-6a4e08779f7d",
    #   "volumeName": "vol3",
    #   "volumeNumericalId": 3,
    #   "clusterId": "9f50bf51-392d-47e2-a0f6-ed2da988e35a",
    #   "volumeSize": 8796093022208,
    #   "blockSize": 4096,
    #   "tip": 0,
    #   "createdTime": "1615790295683",
    #   "parentVolumeId": null,
    #   "parentVolumeName": null,
    #   "parentSnapshotId": null,
    #   "parentSnapshotName": null,
    #   "baseSnapshotId": null,
    #   "retentionPolicyIds": null,
    #   "deduplicated": true,
    #   "compressed": true,
    #   "committedSpace": 0,
    #   "flattenedVolumeShardSet": null,
    #   "hostId": null,
    #   "thinProvision": false,
    #   "exported": false,
    #   "provisioningType": null,
    #   "permissionOption": null,
    #   "subsystemName": null,
    #   "address": null,
    #   "port": 0,
    #   "transportType": null,
    #   "naa": null,
    #   "status": "INIT",
    #   "qosPolicyId": -1,
    #   "minIops": 10000,
    #   "maxIops": 1000000,
    #   "weight": 10,
    #   "accessLevel": "READ_WRITE",
    #   "iscsiTarget": null,
    #   "volumeUpdateTime": 1615790295683,
    #   "type": "NORMAL"
    # }

    # VOL1_ID=0421a4cd-bfbb-403a-9d98-72933dd396fa
    # VOL2_ID=cb6394bc-27da-45ef-b4b7-7c8b37471c77
    # VOL3_ID=72b4c81d-ffda-4e9c-af69-6a4e08779f7d
}

# create initiator
function create_initiator() {
    CREATE_INITIATOR_JSON_TEMPLATE="
    {
    \"iqn\": \"$(sudo cat /etc/iscsi/initiatorname.iscsi | grep -Eo "\biqn[a-z0-9\.:\-]+")\",
    \"initiatorName\": \"$(hostname)\"
    }
    "
    local CREATE_INITIATOR_RET=$(curl --insecure --location --request POST 'https://'$MGMT_IP':'$MGMT_PORT'/v1/initiators' --header 'Authorization: Bearer '$TOKEN -d "$CREATE_INITIATOR_JSON_TEMPLATE" -H "Content-Type: application/json")
    echo $CREATE_INITIATOR_RET
    local INITIATOR_ID=$(echo $CREATE_INITIATOR_RET | jq --raw-output .initiatorId)
    echo "* created initiator, id=$INITIATOR_ID"
    # {
    #   "initiatorId": "2e2ec6ae-c025-44e6-b74a-3a7eb2b7d3d5",
    #   "iqn": "iqn.1993-08.org.debian:01:35f496d77428",
    #   "initiatorName": "hcd50",
    #   "createTime": 0,
    #   "updateTime": 0
    # }
}

# create volume access group
function create_vag() {
    # Get volumes in cluster
    local VOLUME_ID_ARRAY=$(curl --insecure --location --request GET 'https://'$MGMT_IP':'$MGMT_PORT'/v1/volumes/'$CLUSTER_ID --header 'Authorization: Bearer '$TOKEN | jq '[{id: .data[].volumeId}]')
    echo "* get volumes:\n$VOLUME_ID_ARRAY"
    local GET_INITIATOR_RET=$(curl --insecure --location --request GET 'https://'$MGMT_IP':'$MGMT_PORT'/v1/initiators' --header 'Authorization: Bearer '$TOKEN)
    local INITIATOR_ID=$(echo $GET_INITIATOR_RET | jq --raw-output .data[0].initiatorId)
    echo "* get initiator $INITIATOR_ID"
    local CLUSTER_ID=$1
    CREATE_VOL_ACCESS_GROUP_JSON_TEMPLATE="
    {          
        \"volumeAccessGroupName\": \"\",
        \"clusterId\": \"$CLUSTER_ID\",
        \"initiators\": [
            {
                \"id\": \"$INITIATOR_ID\"
            }
        ],
        \"volumes\": [
            {
                \"id\": \"\"
            }
        ]
    }
    "
    local CREATE_VAG_INPUT=$(echo $CREATE_VOL_ACCESS_GROUP_JSON_TEMPLATE | jq ".volumes=$VOLUME_ID_ARRAY | .volumeAccessGroupName=\"vag1\"")
    echo $CREATE_VAG_INPUT
    local CREATE_VAG_RET=$(curl --insecure --location --request POST 'https://'$MGMT_IP':'$MGMT_PORT'/v1/volume-access-groups' --header 'Authorization: Bearer '$TOKEN -d "$CREATE_VAG_INPUT" -H "Content-Type: application/json")
    echo $CREATE_VAG_RET | jq
    echo "* created vag and add volumes to vag"

    # {
    #   "volumeAccessGroupId": "c9b75dea-8df1-4250-98c1-cd8af85f0628",
    #   "volumeAccessGroupName": "vag1",
    #   "clusterId": "9f50bf51-392d-47e2-a0f6-ed2da988e35a",
    #   "initiators": [
    #     {
    #       "id": "2e2ec6ae-c025-44e6-b74a-3a7eb2b7d3d5",
    #       "iqn": "iqn.1993-08.org.debian:01:35f496d77428"
    #     }
    #   ],
    #   "volumes": [
    #     {
    #       "id": "cb6394bc-27da-45ef-b4b7-7c8b37471c77",
    #       "name": "vol2",
    #       "numericalId": 2
    #     },
    #     {
    #       "id": "0421a4cd-bfbb-403a-9d98-72933dd396fa",
    #       "name": "vol1",
    #       "numericalId": 1
    #     },
    #     {
    #       "id": "72b4c81d-ffda-4e9c-af69-6a4e08779f7d",
    #       "name": "vol3",
    #       "numericalId": 3
    #     }
    #   ],
    #   "createTime": 1615793052374,
    #   "updateTime": 1615793052374
    # }
}

# discover and login volumes
function discover_login_volumes () {
    VOL_IQNS=$(sudo iscsiadm -m discovery -t st -p $SVIP:$SVIP_PORT | awk '{print $2}')
    for iqn in $VOL_IQNS; do
       sudo iscsiadm -m node -p $SVIP:$SVIP_PORT -T $iqn -l
    done
}

# create_cluster
CLUSTER_ID=f085e0da-48d4-4d0b-843d-32599f1d9c89
# create_volumes 6 8796093022208 
# create_initiator
INITIATOR_ID=623527d6-7be6-4599-870b-8e9f88ed495b
# create_vag $CLUSTER_ID
discover_login_volumes
