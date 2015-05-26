#!/bin/bash

pushall(){
    find . -regex "\./\([^\.]\).*[^~]$"| xargs git add
    git commit -m "$1"
    git push origin master
}

push(){
    printf "list of files or wild card (default=*) : "
    read fileList
    if [ -z "$fileList" ]; then
        echo "use default=* as list of files"
        fileList = *
    fi
    git add fileList
    git commit -m "$1"
    git pus origin master
}

pull(){
    git pull
}

usage(){
    printf "usage : $0\n"
    printf " $0 [option]\n\n"
    printf "Options : (Use only One)"
    printf "  -psa, --pushall [COMMIT_MESSAGE]\t push all files with COMMIT_MESSAGE\n"
    printf "  -ps,  --push [COMMIT_MESSAGE]\t\t push listed files from input\n"
    printf "\t\t\t\t\t with COMMIT_MESSAGE\n"
    printf "  -pla, --pullall\t\t\t pull all files from remote\n"
    printf "  -pl,  --pull\t\t\t same with --pullall"
    exit
}

getfunc(){
    case "$1" in
        1) case "$2" in
               -psa|--pushall) pushall "Default Commit";;
               -ps|--push) push "Default Commit";;
               -pl|--pull) pull;;
               *) usage;;
           esac;;
        2) case "$2" in
               -psa|--pushall) pushall "$3";;
               -ps|--push) push "$3";;
               *) usage;;
           esac;;
        *) usage;;
    esac
}

getfunc "$#" $1 $2
