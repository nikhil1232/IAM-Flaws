#!/bin/bash
RED='\e[41;97m'
WHITE='\033[0;37m'
RESET='\033[0m'
YELLOW='\033[0;93m'
TEST='\e[45m'
YEL='\e[38;5;226m'

if [[ $(ls ~/.aws/config 2>&1) == *"No such file"* ]] && [[ $(ls ~/.aws/credentials 2>&1) == *"No such file"* ]];
then
  echo -e "\nPlease configure your AWS CLI by typing in the following in your terminal: \e[40;38;5;82maws configure${RESET}\n"
  exit 1		
fi
  								             

echo -e "\n"  								                                                                                                 

echo -e "${YEL}               _____          __  __        ______ _                          "
echo -e "${YEL}              |_   _|   /\   |  \/  |      |  ____| |                         "
echo -e "${YEL}                | |    /  \  | \  / |______| |__  | | ______      _____       "
echo -e "${YEL}                | |   / /\ \ | |\/| |______|  __| | |/ _  \ \ /\ / / __|      "
echo -e "${YEL}               _| |_ / ____ \| |  | |      | |    | | (_| |\ V  V /\__ \      "
echo -e "${YEL}              |_____/_/    \_\_|  |_|      |_|    |_|\__,_| \_/\_/ |___/      "
echo -e "\n"
echo -e "                        \e[44;97mBY NIKHIL SAHOO and SHIVRAM AMIRTHA${RESET}             "
echo -e "\n"
echo -e "  \e[38;5;159mAWS IAM Security Toolkit : Enumeration | Privilege Escalation | CIS Benchmarks${RESET}             "
echo -e "\n\n${YEL}==================================================================================${RESET}\n"



echo -e "  [1]  CIS Benchmark Check\n"
echo -e "  [2]  Enumeration\n"
echo -e "  [3]  Enumeration > Privilege Escalation Scan\n"
echo -e "  [4]  Enumeration > Privilege Escalation Scan > Exploit\n"

echo -e "\nChoose your desired module from above (no):\n"
read input

echo -e "\nWould you like to save the complete output to a txt file (yes/no):\n"
read input2

if [[ $input2 == "yes" ]] || [[ $input2 == "Yes" ]] || [[ $input2 == "y" ]]; then
 echo -e "\nEnter the name of the file(must be of .txt extension)\n"
 read input3
fi

if [[ $input == "1" ]]; then
 if [[ $input2 == "yes" ]] || [[ $input2 == "Yes" ]] || [[ $input2 == "y" ]]; then
   bash iam-cis-benchmark.sh | tee $input3 && sed -i 's/\x1B\[[0-9;]\+[A-Za-z]//g' $input3
 else 
   bash iam-cis-benchmark.sh
 fi
elif [[ $input == "2" ]]; then
 if [[ $input2 == "yes" ]] || [[ $input2 == "Yes" ]] || [[ $input2 == "y" ]]; then
   bash iam-enumerate.sh | tee $input3 && sed -i 's/\x1B\[[0-9;]\+[A-Za-z]//g' $input3
 else 
   bash iam-enumerate.sh
 fi
elif [[ $input == "3" ]]; then
 if [[ $input2 == "yes" ]] || [[ $input2 == "Yes" ]] || [[ $input2 == "y" ]]; then
   bash iam-privesc.sh | tee $input3 && sed -i 's/\x1B\[[0-9;]\+[A-Za-z]//g' $input3
 else 
   bash iam-privesc.sh
 fi
elif [[ $input == "4" ]]; then
 if [[ $input2 == "yes" ]] || [[ $input2 == "Yes" ]] || [[ $input2 == "y" ]]; then
   bash iam-privesc.sh -e | tee $input3 && sed -i 's/\x1B\[[0-9;]\+[A-Za-z]//g' $input3
 else 
   bash iam-privesc.sh -e
 fi
 
else
 echo -e "Wrong Choice !!!"
fi


