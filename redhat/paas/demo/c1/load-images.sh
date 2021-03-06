#!/usr/bin/env bash

# exec 5> debug_output.txt
# BASH_XTRACEFD="5"
# PS4='$LINENO: '

set -e
set -x

dummy=$1

# mkdir -p tmp

## read configration
source config.sh

# private_repo="registry.redhat.ren"
# major_tag="v3.11"

load_redhat_image(){

    docker_images=$1
    split_tag=$2
    list_file=$3

    while read -r line; do
        if [[ "$line" =~ [^[:space:]] ]] && [[ !  "$line" =~ [\#][:print:]*  ]]; then
            # part1=$(echo "$line" | awk  '{split($0,a,"$split_tag"); print a[2]}')
            # https://stackoverflow.com/questions/19885660/shell-script-command-to-split-string-using-a-variable-delimiter
            # front = ${line%${split_tag}*}
            part1=${line#*${split_tag}}
            part2=$(echo $part1 | awk  '{split($0,a,":"); print a[1]}')
            part3=$(echo $part1 | awk  '{split($0,a,":"); print a[2]}')
            if [[ "$part3" =~ [^[:space:]] ]]; then
                docker tag $line $private_repo$part2:$part3
                docker push $private_repo$part2:$part3
                docker tag $line $private_repo$part2:$major_tag
                docker push $private_repo$part2:$major_tag
                docker tag $line $private_repo$part2:$tag
                docker push $private_repo$part2:$tag
                docker tag $line $private_repo$part2
                docker push $private_repo$part2
            else
                docker tag $line $private_repo$part2
                docker push $private_repo$part2
                docker tag $line $private_repo$part2:$major_tag
                docker push $private_repo$part2:$major_tag
                docker tag $line $private_repo$part2:$tag
                docker push $private_repo$part2:$tag
            fi
            
        fi
    done < $list_file
}

load_docker_image(){

    docker_images=$1

    while read -r line; do
        if [[ "$line" =~ [^[:space:]] ]] && [[ !  "$line" =~ [\#][:print:]*  ]]; then

            part2=$(echo $line | awk  '{split($0,a,":"); print a[1]}')
            part3=$(echo $line | awk  '{split($0,a,":"); print a[2]}')
            if [ -z "$part3" ]; then
                docker tag $line $private_repo/$part2
                docker push $private_repo/$part2
            else
                docker tag $line $private_repo/$part2:$part3
                docker push $private_repo/$part2:$part3
            fi
        fi
    done <<< "$docker_images"
}

load_redhat_image "$ose3_images" "redhat.io" "ose3-images.list"

load_redhat_image "$ose3_optional_imags" "redhat.io" "ose3-optional-imags.list"

load_redhat_image "$ose3_builder_images" "redhat.io" "ose3-builder-images.list"

load_redhat_image "$cnv_optional_imags" "redhat.io" "cnv-optional-images.list"

load_redhat_image "$istio_optional_imags" "redhat.io" "istio-optional-images.list"

# load_docker_image "$docker_builder_images" "docker.io" "docker-builder-images.list"

load_redhat_image "$quay_builder_images" "quay.io" "quay-builder-images.list"

docker image prune -f



