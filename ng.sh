#!/usr/bin/env bash

clear
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo :: NG
echo :: [001] angular-cli.json to angular.json
echo :: [002] version
echo -e ":: Execute? "
read _exec


__ng=/usr/local/lib/node_modules/node/bin/ng



if [[ $_exec = '001' ]];  then
    $__ng update @angular/cli
fi

if [[ $_exec = '002' ]];  then
    $__ng --version
fi

