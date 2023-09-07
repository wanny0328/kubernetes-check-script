#!/bin/bash

# dw node check v1 #

# Color Setting
WHITE_BG="\033[47m"
BLACK_TEXT="\033[30m"
GREEN_TEXT="\033[1;32m"
RED_TEXT="\033[1;31m"
BLUE_TEXT="\033[1;36m"
RESET="\033[0m"

## LOG DIRECTORY CREATE
mkdir $(date +'%Y-%m-%d')-node-check

clear

echo ""
echo ""
echo "============================================================="
echo "   ________  ______   _  __    ________    ____  __  ______  "
echo "  /_  __/  |/  /   | | |/ /   / ____/ /   / __ \/ / / / __ \ "
echo "   / / / /|_/ / /| | |   /   / /   / /   / / / / / / / / / / "
echo "  / / / /  / / ___ |/   |   / /___/ /___/ /_/ / /_/ / /_/ /  "
echo " /_/ /_/  /_/_/  |_/_/|_|   \____/_____/\____/\____/_____/   "
echo "                                                             "
echo "============================================================="
echo "                          Created By DW Kim   23.08.16  V.1.1"



echo ""
echo "===================================="
echo "Step1. Control Plane Container check"
echo "===================================="
echo ""

## CONTAINER STATUS CHECK
API_CONTAINER=$(crictl ps | grep Running | grep kube-apiserver | awk '{print $1}')
ETCD_CONTAINER=$(crictl ps | grep Running | grep etcd | awk '{print $1}')
CONTROLLER_CONTAINER=$(crictl ps | grep Running | grep kube-controller-manager | awk '{print $1}')
SCHEDULER_CONTAINER=$(crictl ps | grep Running | grep kube-scheduler | awk '{print $1}')

echo "1. Kube-API-Server Container Check"
if [ -z "$API_CONTAINER" ]; then
  echo -e "Status = [ ${RED_TEXT}not Running${RESET} ]"
else
  echo -e "Status = [ ${GREEN_TEXT}Running${RESET} ]"
fi
echo ""

echo "2. ETCD Container Check"
if [ -z "$ETCD_CONTAINER" ]; then
  echo -e "Status = [ ${RED_TEXT}not Running${RESET} ]"
else
  echo -e "Status = [ ${GREEN_TEXT}Running${RESET} ]"
fi
echo ""

echo "3. Controller Container Check"
if [ -z "$CONTROLLER_CONTAINER" ]; then
  echo -e "Status = [ ${RED_TEXT}not Running${RESET} ]"
else
  echo -e "Status = [ ${GREEN_TEXT}Running${RESET} ]"
fi
echo ""

echo "4. Scheduler Container Check"
if [ -z "$SCHEDULER_CONTAINER" ]; then
  echo -e "Status = [ ${RED_TEXT}not Running${RESET} ]"
else
  echo -e "Status = [ ${GREEN_TEXT}Running${RESET} ]"
fi
echo ""

echo "----------------------------------------------------------"
echo -e "${BLUE_TEXT}Check Finished.${RESET}"
echo "----------------------------------------------------------"

while true; do
  echo ""
  echo  "Enter 'log' when you want to watch log."
  echo  -n "or Enter '>' when you finished this step : "
  read -r LOG_CHECK

  if [[ "${LOG_CHECK}" == '>' ]]; then
    break
  elif [[ "${LOG_CHECK}" == 'log' ]]; then
    break
  else
    echo ""
    echo "----------------------------------------------------------"
    echo -e "${WHITE_BG}${BLACK_TEXT}Wrong Value. Try again${RESET}"
    echo "----------------------------------------------------------"
  fi
done

case $LOG_CHECK in
  "log")
      while true; do
        options=("1. kube-api-server-log" "2. etcd-log" "3. kube-contoroller-manager-log" "4. kube-scheduler-log")
        selected=0
        while true; do
          print_menu() {
            clear
            for i in "${!options[@]}"; do
              if [[ $i -eq $selected ]]; then
                echo "> ${options[$i]}"
              else
                echo "  ${options[$i]}"
              fi
            done
          }
    
          print_menu
    
          while true; do
            read -rsn1 input
            case "$input" in
              "A")  # Up arrow key
                ((selected--))
                if [[ $selected -lt 0 ]]; then
                  selected=$((${#options[@]} - 1))
                fi
                print_menu
                ;;
              "B")  # Down arrow key
                ((selected++))
                if [[ $selected -ge ${#options[@]} ]]; then
                  selected=0
                fi
                print_menu
                ;;
              "")  # Enter key
                break
                ;;
            esac
          done
          break
        done
          if [[ "${options[$selected]}" == '1. kube-api-server-log' ]]; then
           crictl logs ${API_CONTAINER}
           echo ""
           echo "----------------------------------------------------------"
           echo -e "${BLUE_TEXT}Check Finished.${RESET}"
           echo "----------------------------------------------------------"
           echo ""
          elif [[ "${options[$selected]}" == '2. etcd-log' ]]; then
            crictl logs ${ETCD_CONTAINER}
           echo ""
           echo "----------------------------------------------------------"
           echo -e "${BLUE_TEXT}Check Finished.${RESET}"
           echo "----------------------------------------------------------"
           echo ""
          elif [[ "${options[$selected]}" == '3. kube-contoroller-manager-log' ]]; then
            crictl logs ${CONTROLLER_CONTAINER}
           echo ""
           echo "----------------------------------------------------------"
           echo -e "${BLUE_TEXT}Check Finished.${RESET}"
           echo "----------------------------------------------------------"
           echo ""
          elif [[ "${options[$selected]}" == '4. kube-scheduler-log' ]]; then
            crictl logs ${SCHEDULER_CONTAINER}
           echo ""
           echo "----------------------------------------------------------"
           echo -e "${BLUE_TEXT}Check Finished.${RESET}"
           echo "----------------------------------------------------------"
           echo ""
          fi
  
        echo ""
        while true; do
          echo ""
          echo "Enter 'log' when you want to watch another container log."
          echo -n "or Enter '>' when you finished this step : "
          read -r CONTINUE
          
          if [[ "${CONTINUE}" == '>' ]]; then
            break
          elif [[ "${CONTINUE}" == 'log' ]]; then
            break
          else
            echo ""
            echo "----------------------------------------------------------"
            echo -e "${WHITE_BG}${BLACK_TEXT}Wrong Value. Try again${RESET}"
            echo "----------------------------------------------------------"
          fi
        done
        
        if [[ "${CONTINUE}" == '>' ]]; then
          break
        fi
      done
    ;;
  ">")
    break
    ;;
esac


clear
echo ""
echo "==============================="
echo "Step2. Master Node health check"
echo "==============================="
echo ""
while true; do
  echo -n "Enter This Node IP (Enter '>' when you finished this step) :  "
  read -r MASTER_IP
  echo ""
  if [[ "$MASTER_IP" == ">" ]]; then
    break
  fi

  ## API
  API_LIVE=$(curl -s -k https://${MASTER_IP}:6443/livez)
  API_READY=$(curl -s -k https://${MASTER_IP}:6443/readyz)

  ## ETCD
  ETCD_RESPONSE=$(curl -s -S -k 127.0.0.1:2381/health)

  if [[ "$ETCD_RESPONSE" == '{"health":"true"}' ]]; then
    ETCD_LIVE="ok"
  else
    ETCD_LIVE=" "
  fi

  ## CONTROLLER
  CONTROLLER_LIVE=$(curl -s -k https://${MASTER_IP}:10257/healthz)

  ## Scheduler
  SCHEDULER_LIVE=$(curl -s -k https://${MASTER_IP}:10259/healthz)

  echo "1. Kube-API Server"
  echo "${MASTER_IP}  liveness check result = [ $API_LIVE ]"
  echo "${MASTER_IP} readiness check result = [ $API_READY ]"
  echo ""

  echo "2. ETCD"
  echo "${MASTER_IP} liveness check result = [ $ETCD_LIVE ]"
  echo ""

  echo "3. Kube-Controller-Manager"
  echo "${MASTER_IP} liveness check result = [ $CONTROLLER_LIVE ]"
  echo ""

  echo "4. Kube-Scheduler"
  echo "${MASTER_IP} liveness check result = [ $SCHEDULER_LIVE ]"
  echo ""
  
  echo ""
  echo "----------------------------------------------------------"
  echo -e "${BLUE_TEXT}Check Finished.${RESET}"
  echo "----------------------------------------------------------"
  echo ""

done

clear
echo ""
echo "========================================"
echo "Step3. Master Node Cert-file check start"
echo "========================================"

VERSION=$(kubectl version | grep Server | awk -F'"' '{print $4}')

if [[ "${VERSION}" == '19' ]]; then
  kubeadm alpha certs check-expiration 2>&1 | grep -v -e check-expiration  > ./$(date +'%Y-%m-%d')-node-check/$(date +'%Y-%m-%d')-kubeadm-certs.log
elif [[ "${VERSION}" == '21' ]]; then
  kubeadm certs check-expiration 2>&1 | grep -v -e check-expiration  > ./$(date +'%Y-%m-%d')-node-check/$(date +'%Y-%m-%d')-kubeadm-certs.log
fi

cat ./$(date +'%Y-%m-%d')-node-check/$(date +'%Y-%m-%d')-kubeadm-certs.log | grep -v clusterDNS

echo ""
echo "----------------------------------------------------------"
echo -e "${BLUE_TEXT}Check Finished.${RESET}"
echo "----------------------------------------------------------"
echo ""



while true; do
  echo ""
  echo -n "Enter '>' when you finished this step : "
  read -r CONTINUE

  if [[ "${CONTINUE}" == '>' ]]; then
    break
  else
    echo ""
    echo "----------------------------------------------------------"
    echo -e "${WHITE_BG}${BLACK_TEXT}Wrong Value. Try again${RESET}"
    echo "----------------------------------------------------------"
  fi
done

clear
echo ""
echo "===================================================="
echo "Step4. Kubelet, Crio, Keepalived status check start"
echo "===================================================="
echo ""

# status backup
systemctl status kubelet > ./$(date +'%Y-%m-%d')-node-check/$(date +'%Y-%m-%d')-kubelet-status.log
systemctl status crio > ./$(date +'%Y-%m-%d')-node-check/$(date +'%Y-%m-%d')-crio-status.log

KEEP=$(rpm -qa | grep keepalived)

if [ -n "$KEEP" ]; then
  systemctl status keepalived > ./$(date +'%Y-%m-%d')-node-check/$(date +'%Y-%m-%d')-keepalived-status.log
  KEEPALIVED_STATUS=$(cat ./$(date +'%Y-%m-%d')-node-check/$(date +'%Y-%m-%d')-keepalived-status.log | grep Active | awk '{gsub(/[()]/, "", $3); print $3}')
fi


KUBELET_STATUS=$(cat ./$(date +'%Y-%m-%d')-node-check/$(date +'%Y-%m-%d')-kubelet-status.log | grep Active | awk '{gsub(/[()]/, "", $3); print $3}')
CRIO_STATUS=$(cat ./$(date +'%Y-%m-%d')-node-check/$(date +'%Y-%m-%d')-crio-status.log | grep Active | awk '{gsub(/[()]/, "", $3); print $3}')

# status check
echo "1. Kubelet status check"
if [[ "$KUBELET_STATUS" == 'running' ]]; then
  echo -e "Status = [ ${GREEN_TEXT}Running${RESET} ]"
else
  echo -e "Status = [ ${RED_TEXT}Not Running${RESET} ]"
fi
echo ""

echo "2. Cri-o status check"
if [[ "$CRIO_STATUS" == 'running' ]]; then
  echo -e "Status = [ ${GREEN_TEXT}Running${RESET} ]"
else
  echo -e "Status = [ ${RED_TEXT}Not Running${RESET} ]"
fi
echo ""

if [ -n "$KEEP" ]; then
  echo "3. Keepalived status check"
  if [[ "$KEEPALIVED_STATUS" == 'running' ]]; then
    echo -e "Status = [ ${GREEN_TEXT}Running${RESET} ]"



  else
    echo -e "Status = [ ${RED_TEXT}Not Running${RESET} ]"



  fi
  echo ""
else
  echo "3. Keepalived status check"
  echo -e "Keepalived not installed."
fi

echo ""
echo "----------------------------------------------------------"
echo -e "${BLUE_TEXT}Check Finished.${RESET}"
echo "----------------------------------------------------------"
echo ""



while true; do
  echo ""
  echo -n "Enter '>' when you finished this step : "
  read -r CONTINUE

  if [[ "${CONTINUE}" == '>' ]]; then
    break
  else
    echo ""
    echo "----------------------------------------------------------"
    echo -e "${WHITE_BG}${BLACK_TEXT}Wrong Value. Try again${RESET}"
    echo "----------------------------------------------------------"
  fi
done


clear
echo ""
echo "============================"
echo "Step5. Node list check start"
echo "============================"
echo ""

kubectl get nodes -owide > ./$(date +'%Y-%m-%d')-node-check/$(date +'%Y-%m-%d')-node-list.log

NODE_NUM=$(($(wc ./$(date +'%Y-%m-%d')-node-check/$(date +'%Y-%m-%d')-node-list.log | awk '{print $1}') - 1))
RUN_NODE=$(cat ./$(date +'%Y-%m-%d')-node-check/$(date +'%Y-%m-%d')-node-list.log | grep Ready | wc -l)
NOT_RUN_NODE=$(($(cat ./$(date +'%Y-%m-%d')-node-check/$(date +'%Y-%m-%d')-node-list.log | grep -v Ready | wc -l) - 1))

echo "Total number of Nodes : [ "$NODE_NUM" ]"
echo -e "Ready status : [ ${GREEN_TEXT} ${RUN_NODE} ${RESET} ]"
if [[ "${NOT_RUN_NODE}" == 0 ]]; then
  echo "Not Ready status : [ ${NOT_RUN_NODE} ]"
else
  echo -e "Not Ready status : [ ${RED_TEXT} ${NOT_RUN_NODE} ${RESET} ]"
  echo ""
  echo "[ Not ready node list ]"
  echo "-----------------------------------------------------------------------------------"
  kubectl get nodes -owide | grep -v Ready
fi
echo ""
echo ""

echo "----------------------------------------------------------"
echo -e "${BLUE_TEXT}Check Finished.${RESET}"
echo "----------------------------------------------------------"
echo ""

while true; do
  echo ""
  echo -n "Enter '>' when you finished this step : "
  read -r CONTINUE

   if [[ "${CONTINUE}" == '>' ]]; then
    break
  else
    echo ""
    echo "----------------------------------------------------------"
    echo -e "${WHITE_BG}${BLACK_TEXT}Wrong Value. Try again${RESET}"
    echo "----------------------------------------------------------"
  fi
done


clear
echo ""
echo "==========================="
echo "Step6. Pod list check start"
echo "==========================="
echo ""

kubectl get po -A -owide > ./$(date +'%Y-%m-%d')-node-check/$(date +'%Y-%m-%d')-pod-list.log

POD_NUM=$(($(wc ./$(date +'%Y-%m-%d')-node-check/$(date +'%Y-%m-%d')-pod-list.log | awk '{print $1}') - 1))
RUN_POD=$(cat ./$(date +'%Y-%m-%d')-node-check/$(date +'%Y-%m-%d')-pod-list.log | grep Running | wc -l)
COM_POD=$(cat ./$(date +'%Y-%m-%d')-node-check/$(date +'%Y-%m-%d')-pod-list.log | grep Completed | wc -l) 
NOT_RUN_POD=$(($(cat ./$(date +'%Y-%m-%d')-node-check/$(date +'%Y-%m-%d')-pod-list.log | grep -v Running | grep -v Completed | wc -l) - 1))

echo "Total number of Pods : [ "$POD_NUM" ]"
echo -e "Running status : [ ${GREEN_TEXT}${RUN_POD}${RESET} ]"
echo -e "Completed status : [ ${GREEN_TEXT}${COM_POD}${RESET} ]"
if [[ "${NOT_RUN_POD}" == 0 ]];then
  echo "Not Running status : [ ${NOT_RUN_POD} ]"
else
  echo -e "Not Running status : [ ${RED_TEXT}${NOT_RUN_POD}${RESET} ]"
  echo ""
  echo "[ Not ready pod list ]"
  echo "-----------------------------------------------------------------------------------"
  kubectl get po -A -owide | grep -v Running | grep -v Completed
fi

echo ""
echo ""

echo "----------------------------------------------------------"
echo -e "${BLUE_TEXT}Check Finished.${RESET}"
echo "----------------------------------------------------------"
echo ""

while true; do
  echo ""
  echo -n "Enter '>' when you finished this step : "
  read -r CONTINUE

  if [[ "${CONTINUE}" == '>' ]]; then
    break
  else
    echo ""
    echo "----------------------------------------------------------"
    echo -e "${WHITE_BG}${BLACK_TEXT}Wrong Value. Try again${RESET}"
    echo "----------------------------------------------------------"
  fi
done


clear
echo ""
echo "===================================="
echo "Step7. Nginx Pod Resource check"
echo "===================================="
echo ""

## Nginx Deploy name and number of replicas
NGINX_DEPLOY=$(kubectl get deployment -n ingress-nginx-system | grep controller | awk '{ print $1 }')
NGINX_REPLICAS=$(kubectl  get deployment -n ingress-nginx-system ${NGINX_DEPLOY} -o jsonpath='{.spec.replicas}')


echo ""
echo -e "NGINX DEPLOYMENT NAME : [ ${BLUE_TEXT}$NGINX_DEPLOY${RESET} ]"
echo -e "REPLICAS NUMBER OF NGINX : [ ${BLUE_TEXT}$NGINX_REPLICAS${RESET} ]"
echo ""
echo ""

## Nginx request resource (Default CPU value unit is 'm' and default MEM value unit is 'Mi')
NGINX_DEF_REQ_CPU=100
NGINX_REQ_CPU=$(kubectl  get deployment -n ingress-nginx-system ${NGINX_DEPLOY} -ojsonpath='{.spec.template.spec.containers[?(@.name=="controller")].resources.requests.cpu}')
NGINX_DEF_REQ_MEM=90
NGINX_REQ_MEM=$(kubectl  get deployment -n ingress-nginx-system ${NGINX_DEPLOY} -ojsonpath='{.spec.template.spec.containers[?(@.name=="controller")].resources.requests.memory}')

## Nginx limit resource (Default CPU value unit is 'm' and default MEM value unit is 'Mi')
NGINX_DEF_LIM_CPU=200
NGINX_LIM_CPU=$(kubectl  get deployment -n ingress-nginx-system ${NGINX_DEPLOY} -ojsonpath='{.spec.template.spec.containers[?(@.name=="controller")].resources.limits.cpu}')
NGINX_DEF_LIM_MEM=180
NGINX_LIM_MEM=$(kubectl  get deployment -n ingress-nginx-system ${NGINX_DEPLOY} -ojsonpath='{.spec.template.spec.containers[?(@.name=="controller")].resources.limits.memory}')


echo "======== Diff Request Resource ========"

## Diff Request CPU Resource
if [[ $NGINX_REQ_CPU == *"m" ]]; then
  NGINX_REQ_CPU=$(echo "$NGINX_REQ_CPU" | sed 's/m//g')
else
  NGINX_REQ_CPU=$[$NGINX_REQ_CPU * 1000]
fi

echo "Default Nginx Request CPU = [ $NGINX_DEF_REQ_CPU m ]"
echo -e "Applied Nginx Request CPU = [ ${BLUE_TEXT}$NGINX_REQ_CPU m${RESET} ]"

if [[ $NGINX_REQ_CPU -gt $NGINX_DEF_REQ_CPU ]]; then
  echo -e "=> ${RED_TEXT}Applied Nginx Request CPU value is larger than Default setting value.${RESET}"
  echo -e "${RED_TEXT}CHECK NGINX REQUEST CPU VALUE!${RESET}"
elif [[ $NGINX_REQ_CPU -eq $NGINX_DEF_REQ_CPU ]]; then
  echo -e "=> ${GREEN_TEXT}Applied Nginx Request CPU value is Default setting value.${RESET}"
else
  echo -e "=> ${RED_TEXT}Applied Nginx Request CPU value is smaller than Default setting value.${RESET}"
  echo -e "${RED_TEXT}CHECK NGINX REQUEST CPU VALUE!${RESET}"
fi

echo ""

## Diff Request MEM Resource
if [[ $NGINX_REQ_MEM == *"Mi" ]]; then
  NGINX_REQ_MEM=$(echo "$NGINX_REQ_MEM" | sed 's/Mi//g')
elif [[ $NGINX_REQ_MEM == *"Gi" ]]; then
  NGINX_REQ_MEM=$(echo "$NGINX_REQ_MEM" | sed 's/Gi//g')
  NGINX_REQ_MEM=$[$NGINX_REQ_MEM * 1000]
fi

echo "Default Nginx Request MEM = [ $NGINX_DEF_REQ_MEM Mi ]"
echo -e "Applied Nginx Request MEM = [ ${BLUE_TEXT}$NGINX_REQ_MEM Mi${RESET} ]"

if [[ $NGINX_REQ_MEM -gt $NGINX_DEF_REQ_MEM ]]; then
  echo -e "=> ${RED_TEXT}Applied Nginx Request MEM value is larger than Default setting value.${RESET}"
  echo -e "${RED_TEXT}CHECK NGINX REQUEST MEM VALUE!${RESET}"
elif [[ $NGINX_REQ_MEM -eq $NGINX_DEF_REQ_MEM ]]; then
  echo -e "=> ${GREEN_TEXT}Applied Nginx Request MEM value is Default setting value.${RESET}"
else
  echo -e "=> ${RED_TEXT}Applied Nginx Request MEM value is smaller than Default setting value.${RESET}"
  echo -e "${RED_TEXT}CHECK NGINX REQUEST MEM VALUE!${RESET}"
fi

echo ""

echo "======== Diff Limit Resource ========"

## Diff Limit CPU Resource
if [[ $NGINX_LIM_CPU == *"m" ]]; then
  NGINX_LIM_CPU=$(echo "$NGINX_LIM_CPU" | sed 's/m//g')
else
  NGINX_LIM_CPU=$[$NGINX_LIM_CPU * 1000]
fi

echo "Default Nginx Limit CPU = [ $NGINX_DEF_LIM_CPU m ]"
echo -e "Applied Nginx Limit CPU = [ ${BLUE_TEXT}$NGINX_LIM_CPU m${RESET} ]"

if [[ $NGINX_LIM_CPU -gt $NGINX_DEF_LIM_CPU ]]; then
  echo -e "=> ${RED_TEXT}Applied Nginx Limit CPU value is larger than Default setting value.${RESET}"
  echo -e "${RED_TEXT}CHECK NGINX LIMIT CPU VALUE!${RESET}"
elif [[ $NGINX_LIM_CPU -eq $NGINX_DEF_LIM_CPU ]]; then
  echo -e "=> ${GREEN_TEXT}Applied Nginx Limit CPU value is Default setting value.${RESET}"
else
  echo -e "=> ${RED_TEXT}Applied Nginx Limit CPU value is smaller than Default setting value.${RESET}"
  echo -e "${RED_TEXT}CHECK NGINX LIMIT CPU VALUE!${RESET}"
fi

echo ""

## Diff Limit MEM Resource
if [[ $NGINX_LIM_MEM == *"Mi" ]]; then
  NGINX_LIM_MEM=$(echo "$NGINX_LIM_MEM" | sed 's/Mi//g')
elif [[ $NGINX_LIM_MEM == *"Gi" ]]; then
  NGINX_LIM_MEM=$(echo "$NGINX_LIM_MEM" | sed 's/Gi//g')
  NGINX_LIM_MEM=$[$NGINX_LIM_MEM * 1000]
fi

echo "Default Nginx Limit MEM = [ $NGINX_DEF_LIM_MEM Mi ]"
echo -e "Applied Nginx Limit MEM = [ ${BLUE_TEXT}$NGINX_LIM_MEM Mi${RESET} ]"

if [[ $NGINX_LIM_MEM -gt $NGINX_DEF_LIM_MEM ]]; then
  echo -e "=> ${RED_TEXT}Applied Nginx Limit MEM value is larger than Default setting value.${RESET}"
  echo -e "${RED_TEXT}CHECK NGINX LIMIT MEM VALUE!${RESET}"
elif [[ $NGINX_LIM_MEM -eq $NGINX_DEF_LIM_MEM ]]; then
  echo -e "=> ${GREEN_TEXT}Applied Nginx Limit MEM value is Default setting value.${RESET}"
else
  echo -e "=> ${RED_TEXT}Applied Nginx Limit MEM value is smaller than Default setting value.${RESET}"
  echo -e "${RED_TEXT}CHECK NGINX LIMIT MEM VALUE!${RESET}"
fi

echo ""


echo ""
echo "----------------------------------------------------------"
echo -e "${BLUE_TEXT}Check Finished.${RESET}"
echo "----------------------------------------------------------"
echo ""


while true; do
  echo ""
  echo -n "Enter '>' when you finished this step : "
  read -r CONTINUE

  if [[ "${CONTINUE}" == '>' ]]; then
    break
  else
    echo ""
    echo "----------------------------------------------------------"
    echo -e "${WHITE_BG}${BLACK_TEXT}Wrong Value. Try again${RESET}"
    echo "----------------------------------------------------------"
  fi
done


clear
echo ""
echo "================================"
echo "Step8. Node resource check start"
echo "================================"
echo ""

## CPU Check

echo "Please wait 30 sec"
echo ""

top -b -n 30 -d 1 | grep "Cpu(s)" > ./$(date +'%Y-%m-%d')-node-check/cpu_usage.txt &

i=0
while true; do
  case $(($i % 8)) in
    0 ) j="${RED_TEXT}↑${RESET}" ;;
    1 ) j="${GREEN_TEXT}↗${RESET}" ;;
    2 ) j="${BLUE_TEXT}→${RESET}" ;;
    3 ) j="↘" ;;
    4 ) j="${RED_TEXT}↓${RESET}" ;;
    5 ) j="${GREEN_TEXT}↙${RESET}" ;;
    6 ) j="${BLUE_TEXT}←${RESET}" ;;
    7 ) j="↖" ;;
  esac
  echo -en "\r $j CPU checking..."
  LINE=$(wc -l ./$(date +'%Y-%m-%d')-node-check/cpu_usage.txt | awk '{print $1}')
  sleep 0.3
  ((i=i+1))

  if [ "$LINE" -gt 29 ]; then
    break
  fi
done

echo ""
echo "[ CPU Check finished. ]"
echo ""


LINE=0
CPU_SUM=0
while true; do
  ((LINE++))
  CPU_USE=$(cat ./$(date +'%Y-%m-%d')-node-check/cpu_usage.txt | awk '{match($0, /([0-9.]+) id/, arr); print arr[1]}' | sed -n "${LINE}p" | cut -d '.' -f1)
  let CPU_SUM=CPU_SUM+CPU_USE
  if [[ "$LINE" == 30 ]]; then
    break
  fi
done

USE_CPU=$((100 - ($CPU_SUM / 30)))

if [[ "${CPU_MEM}" -gt 80 ]]; then
  echo -e "CPU Usage : [ ${RED_TEXT}${USE_CPU}%${RESET} ]"
  echo -e "${RED_TEXT}Check CPU status. It's too high!!${RESET}"
else
  echo -e "CPU Usage : [ ${GREEN_TEXT}${USE_CPU}%${RESET} ]"
fi


## ROOT directory Check

df -h > ./$(date +'%Y-%m-%d')-node-check/disk_usage.txt


LINE=0
while true; do
  ((LINE++))
  ROOT=$(cat ./$(date +'%Y-%m-%d')-node-check/disk_usage.txt | awk '{print $6}' | sed -n "${LINE}p")
  if [[ "$ROOT" == "/" ]]; then
    break
  fi
done

ROOT_USE=$(cat ./$(date +'%Y-%m-%d')-node-check/disk_usage.txt | awk '{print $5}' | sed -n "${LINE}p" | cut -d '%' -f1)

if [[ "${ROOT_USE}" -gt 80 ]]; then
  echo -e "'/' Directory Usage : [ ${RED_TEXT}${ROOT_USE}%${RESET} ]"
  echo -e "${RED_TEXT}Check / directory usage. It's too high!!${RESET}"
else
  echo -e "'/' Directory Usage : [ ${GREEN_TEXT}${ROOT_USE}%${RESET} ]"
fi


## Memory Check

TOT_MEM=$(free -m | grep Mem | awk '{print $2}')
FRE_MEM=$(free -m | grep Mem | awk '{print $3}')
USE_MEM=$(((${FRE_MEM} * 100) / ${TOT_MEM}))

if [[ "${USE_MEM}" -gt 80 ]]; then
  echo -e "Memory Usage : [ ${RED_TEXT}${USE_MEM}%${RESET} ]"
  echo -e "${RED_TEXT}Check Memory status. It's too high!!${RESET}"
else
  echo -e "Memory Usage : [ ${GREEN_TEXT}${USE_MEM}%${RESET} ]"
fi

echo ""

echo "----------------------------------------------------------"
echo -e "${BLUE_TEXT}Check Finished.${RESET}"
echo "----------------------------------------------------------"
echo ""


while true; do
  echo ""
  echo -n "Enter '>' when you finished this step : "
  read -r CONTINUE

  if [[ "${CONTINUE}" == '>' ]]; then
    break

  else
    echo ""
    echo "----------------------------------------------------------"
    echo -e "${WHITE_BG}${BLACK_TEXT}Wrong Value. Try again${RESET}"
    echo "----------------------------------------------------------"
  fi
done


