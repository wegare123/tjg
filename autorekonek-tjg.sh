#!/bin/bash
#tjg (Wegare)
route="$(route | grep -i 8.8.8.8 | head -n1 | awk '{print $2}')" 
route2="$(route | grep -i 10.0.0.2 | head -n1 | awk '{print $2}')" 
route3="$(lsof -i | grep -i trojan-go | grep -i 1080 | grep -i listen)" 
echo $route
	if [[ -z $route2 ]]; then
		   printf '\n' | tjg
           exit
    elif [[ -z $route3 ]]; then
           printf '\n' | tjg
           exit
           elif [[ -z $route ]]; then
           printf '\n' | tjg
           exit
	fi
