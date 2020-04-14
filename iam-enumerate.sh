#!/bin/bash
RED='\e[41;97m'
WHITE='\033[0;37m'
RESET='\033[0m'
YELLOW='\033[0;93m'
TEST='\e[45m'
YEL='\e[38;5;226m'


if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]
then
  echo "Usage:" 
  echo "-h for help"
  echo -e "Eg: \e[44;97m./iam-enumerate.sh${RESET}"
  exit 1
fi

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
echo -e "                                    ${RED}ENUMERATION${RESET}"
echo -e "\n\n"

echo -e "\n\n\e[40;38;5;82m>>Enumeration<<${RESET}\n\n"
temp=0

abc=""
abcd=""

b=$(aws iam get-user 2>&1)
if [[ $a == *"An error"* ]]; then
  echo -e "Failed\n"
  (($temp+=1))
  
else
  echo -e "\n\e[30;48;5;82mGet User:${RESET}\n"
  echo -e "$b\n" | jq ".User.UserName" 2>&1 | cut -d "\"" -f2

fi

a=$(aws iam list-users 2>&1)
echo -e "\n\e[30;48;5;82mList Users:${RESET}\n"

if [[ $a == *"An error"* ]]; then
  echo -e "Failed\n"
  (($temp+=1))
  if [[ $temp == 2 ]]; then
     exit 1
  fi
else
  echo -e "$a" | jq ".Users[].UserName" 2>&1 | cut -d "\"" -f2
fi

echo -e "\nEnter the User from above to proceed with:\n"
read awsuser

c=$(aws iam list-groups-for-user --user-name $awsuser 2>&1 | jq ".Groups[].GroupName" 2>&1 | cut -d "\"" -f2)

echo -e "\n\n\e[30;48;5;82mList Groups:${RESET}\n"
if [[ $c == *"error"* ]] || [[ -z $c ]]; then
  echo -e "Failed\n"
else
  echo "$c"
  
  while IFS= read -r bkg ;
  do
  i=$(aws iam list-group-policies --group-name $bkg 2>&1 | jq ".PolicyNames[]" 2>&1 | cut -d "\"" -f2)
  echo -e "\n\e[1;4mGroup Name: $bkg${RESET}"
  echo -e "\n\e[30;48;5;82mList Group Policies:${RESET}\n"
  if [[ $i == *"error"* ]] || [[ -z $i ]]; then
   echo -e "Failed\n"
  else
   echo "$i"
   while IFS= read -r bk ;
   do
   j2=$(aws iam get-group-policy --group-name $bkg --policy-name $bk 2>&1)
   j=$(echo "$j2" | jq ".PolicyDocument.Statement[].Effect" 2>&1 | cut -d "\"" -f2 | tr -d "[]" | sed -r '/^\s*$/d' )
   echo -e "\n\n\e[30;48;5;82mGet Group Policies: $bk${RESET}\n"
   if [[ $j == *"error"* ]] || [[ -z $j ]]; then
    echo -e "Failed\n"
   else
    cooo=0


    while IFS= read -r gxyz ;
    do
    if [[ $gxyz == *"Allow"* ]]; then
       eii=$(echo "$j2" | jq ".PolicyDocument.Statement[$cooo].Action" 2>&1 | cut -d "\"" -f2 | tr -d "[]" | sed -r '/^\s*$/d' )
       eii2=$(echo "$j2" | jq ".PolicyDocument.Statement[$cooo].Resource" 2>&1 | cut -d "\"" -f2 | tr -d "[]" | sed -r '/^\s*$/d' )

       echo -e "\nAction:\n"
       echo "$eii"
       echo -e "\nResource:\n"
       echo "$eii2"
       abc=$(echo -e "$abc\n$eii") 
   
    elif [[ $gxyz == *"Deny"* ]]; then
       exx=$(echo "$j2" | jq ".PolicyDocument.Statement[$cooo].Action" 2>&1 | cut -d "\"" -f2 | tr -d "[]" | sed -r '/^\s*$/d' )
       abcd=$(echo -e "$abcd\n$exx") 
    fi
   
    ((cooo+=1))
    done <<< "$j"


   
     
   fi
   done <<< "$i" 
  
  fi 






  ij=$(aws iam list-attached-group-policies --group-name $bkg 2>&1 | jq ".AttachedPolicies[].PolicyArn" 2>&1 | cut -d "\"" -f2)
  echo -e "\n\n\e[30;48;5;82mList Group Attached Policies:${RESET}\n"
  if [[ $ij == *"error"* ]] || [[ -z $ij ]]; then
   echo -e "Failed\n"
  else
   echo "$ij" | cut -d "/" -f 2
   priv=$(echo -e "$priv\n$ij")
   while IFS= read -r ijk ;
   do
   gi=$(aws iam get-policy --policy-arn $ijk 2>&1 | jq ".Policy.DefaultVersionId" 2>&1 | cut -d "\"" -f2)
   if [[ $gi == *"error"* ]] || [[ -z $gi ]]; then
    :
   else
    hi2=$(aws iam get-policy-version --policy-arn $ijk --version-id $gi 2>&1)
    hi=$(echo "$hi2" | jq ".PolicyVersion.Document.Statement[].Effect" 2>&1 | cut -d "\"" -f2 | tr -d "[]" | sed -r '/^\s*$/d' )
    con=0
    if [[ $hi == *"error"* ]] || [[ -z $hi ]]; then
      echo -e "Failed\n"
    else
      while IFS= read -r xyzu ;
      do
      if [[ $xyzu == *"Allow"* ]]; then
       klop=$(echo -e "$ijk" | cut -d "/" -f 2)
       echo -e "\n\e[30;48;5;82mGet Group Attached Policies: $klop${RESET}\n"
       ho=$(echo "$hi2" | jq ".PolicyVersion.Document.Statement[$con].Action" 2>&1 | cut -d "\"" -f2 | tr -d "[]" | sed -r '/^\s*$/d' )
       ho2=$(echo "$hi2" | jq ".PolicyVersion.Document.Statement[$con].Resource" 2>&1 | cut -d "\"" -f2 | tr -d "[]" | sed -r '/^\s*$/d' )
       echo -e "\nAction:\n"
       echo "$ho"
       echo -e "\nResource:\n"
       echo "$ho2"
       abc=$(echo -e "$abc\n$ho")
      elif [[ $xyzu == *"Deny"* ]]; then
       ho=$(echo "$hi2" | jq ".PolicyVersion.Document.Statement[$con].Action" 2>&1 | cut -d "\"" -f2 | tr -d "[]" | sed -r '/^\s*$/d' )
       abcd=$(echo -e "$abcd\n$ho")
      
      fi
      ((con+=1))
      done <<< "$hi"
    fi
   fi
   done <<< "$ij" 
  fi
  done <<< "$c"
fi






d=$(aws iam list-user-policies --user-name $awsuser 2>&1 | jq ".PolicyNames[]" 2>&1 | cut -d "\"" -f2)
echo -e "\n\n\e[30;48;5;82mList User Policies:${RESET}\n"
if [[ $d == *"error"* ]] || [[ -z $d ]]; then
  echo -e "Failed\n"
else
  echo "$d"
  while IFS= read -r bu ;
  do
  e2=$(aws iam get-user-policy --user-name $awsuser --policy-name $bu 2>&1)
  e=$(echo "$e2" | jq ".PolicyDocument.Statement[].Effect" 2>&1 | cut -d "\"" -f2 | tr -d "[]" | sed -r '/^\s*$/d' )
  co=0
  echo -e "\n\n\e[30;48;5;82mGet User Policies: $bu${RESET}\n"

  
  if [[ $e == *"error"* ]] || [[ -z $e ]]; then
   echo -e "Failed\n"
  else
   while IFS= read -r xyz ;
   do
   if [[ $xyz == *"Allow"* ]]; then
    ei=$(echo "$e2" | jq ".PolicyDocument.Statement[$co].Action" 2>&1 | cut -d "\"" -f2 | tr -d "[]" | sed -r '/^\s*$/d' )
    ei2=$(echo "$e2" | jq ".PolicyDocument.Statement[$co].Resource" 2>&1 | cut -d "\"" -f2 | tr -d "[]" | sed -r '/^\s*$/d' )
    echo -e "\nAction:\n"
    echo "$ei"
    echo -e "\nResource:\n"
    echo "$ei2"
    abc=$(echo -e "$abc\n$ei") 
   elif [[ $xyz == *"Deny"* ]]; then
    ex=$(echo "$e2" | jq ".PolicyDocument.Statement[$co].Action" 2>&1 | cut -d "\"" -f2 | tr -d "[]" | sed -r '/^\s*$/d' )
    abcd=$(echo -e "$abcd\n$ex") 
   fi
  ((co+=1))
  done <<< "$e"
  fi
  done <<< "$d"
fi







f=$(aws iam list-attached-user-policies --user-name $awsuser | jq ".AttachedPolicies[].PolicyArn" 2>&1 | cut -d "\"" -f2)
echo -e "\n\n\e[30;48;5;82mList User Attached Policies:${RESET}\n"
if [[ $f == *"error"* ]] || [[ -z $f ]]; then
  echo -e "Failed\n"
else
  echo "$f" | cut -d "/" -f 2
  priv=$(echo -e "$priv\n$f")
  while IFS= read -r buc ;
  do
  g=$(aws iam get-policy --policy-arn $buc 2>&1 | jq ".Policy.DefaultVersionId" 2>&1 | cut -d "\"" -f2)
  if [[ $g == *"error"* ]] || [[ -z $g ]]; then 
    : 
  else

    h2=$(aws iam get-policy-version --policy-arn $buc --version-id $g 2>&1)
    h=$(echo "$h2" | jq ".PolicyVersion.Document.Statement[].Effect" 2>&1 | cut -d "\"" -f2 | tr -d "[]" | sed -r '/^\s*$/d')
    if [[ $h == *"error"* ]] || [[ -z $h ]]; then
      :
    else
      
      coo=0
      while IFS= read -r xyy ;
      do
      if [[ $xyy == *"Allow"* ]]; then
        ho=$(echo "$h2" | jq ".PolicyVersion.Document.Statement[$coo].Action" 2>&1 | cut -d "\"" -f2 | tr -d "[]" | sed -r '/^\s*$/d')
        ho2=$(echo "$h2" | jq ".PolicyVersion.Document.Statement[$coo].Resource" 2>&1 | cut -d "\"" -f2 | tr -d "[]" | sed -r '/^\s*$/d')
        klop=$(echo -e "$buc" | cut -d "/" -f 2)
        echo -e "\n\n\e[30;48;5;82mAttached User Policies Permissions: $klop${RESET}\n"
        echo -e "\nAction:\n"
        echo "$ho"
        echo -e "\nResource:\n"
        echo "$ho2"
        abc=$(echo -e "$abc\n$ho")
        
      elif [[ $xyy == *"Deny"* ]]; then
        hp=$(echo "$h2" | jq ".PolicyVersion.Document.Statement[$coo].Action" 2>&1 | cut -d "\"" -f2 | tr -d "[]" | sed -r '/^\s*$/d')
        
        abcd=$(echo -e "$abcd\n$hp")
      fi
      
      ((coo+=1))
      done <<< "$h"
    fi
  fi
  done <<< "$f" 
fi

abc=$(echo "$abc" | sort | uniq | sed '/^[[:space:]]*$/d')

echo -e "\n"
echo -e "\n\e[30;48;5;82mAllowed Permissions${RESET}\n"
if [[ -z $abc ]]; then
  echo -e "None"
else
  echo -e "$abc"
fi

abcd=$(echo "$abcd" | sort | uniq | sed '/^[[:space:]]*$/d')
echo -e "\n\e[30;48;5;82mDenied Permissions${RESET}\n"
if [[ -z $abcd ]]; then
  echo -e "None"
else
  echo -e "$abcd\n"
fi



echo -e "\n ${YEL}Enumeration Complete. Thanks !!!${RESET}"
echo -e "\n\n${YEL}==================================================================================${RESET}\n"


