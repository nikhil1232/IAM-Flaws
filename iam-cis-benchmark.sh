#!/bin/bash
WHITE='\033[0;37m'
RESET='\033[0m'
RED='\e[41;97m'
YELLOW='\e[38;5;226m'

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
echo -e "                               ${RED}CIS Benchmark Checks${RESET}"
echo -e "\n\n"


echo -en '\nInitiating...'
until aws iam generate-credential-report --output text --query 'State' |grep -m 1 "COMPLETE"; do
  sleep 1
done

TEMPORARYFILE=/tmp/.icr
aws iam get-credential-report --query 'Content' --output text | base64 -d > $TEMPORARYFILE




#1.1 Avoid the use of the "root" account (Scored)

echo -e "\n1.1 Avoid the use of the "root" account\n"
lastLoginDate=$(cat $TEMPORARYFILE | awk -F, '{ print $1,$5,$11,$16 }' | grep root_account | cut -d ' ' -f2,3,4)

if [[ -z $lastLoginDate ]]; then
 echo -e "\n$WHITE No Root Login Activity$RESET"
else
 echo -e "\n$RED Past Login Activity of Root Account:$RESET \n$lastLoginDate"
fi


#1.2 Ensure multi-factor authentication (MFA) is enabled for all IAM users that have a console password

echo -e "\n\n1.2 Ensure multi-factor authentication (MFA) is enabled for all IAM users that have a console password"

userList=$(cat $TEMPORARYFILE|awk -F, '{ print $1,$4 }' | grep true | awk '{ print $1 }')
userMFA=$(
  for i in $userList; do
    cat $TEMPORARYFILE|awk -F, '{ print $1,$8 }' |grep "^$i " |grep false | awk '{ print $1 }'
  done)
  if [[ $userMFA ]]; then
    for j in $userMFA; do
      echo -e "\n$RED User $j has Password enabled but MFA disabled$RESET"
    done
  else
    echo -e "\n$WHITE No users found with Password enabled and MFA disabled$RESET"
  fi
  
#1.3 Ensure credentials unused for 90 days or greater are disabled

echo -e "\n\n1.3 Ensure credentials unused for 90 days or greater are disabled"

compareDate()
      {
        cDate=$1
        tDays=$(date -d "$(date +%Y-%m-%d)" +%s)
        fDays=$(date -d $cDate +%s)
        totalDays=$((($tDays - $fDays )/60/60/24))
        echo $totalDays
      }
       
userList=$(cat $TEMPORARYFILE|awk -F, '{ print $1,$4 }' |grep true | awk '{ print $1 }')

if [[ $userList ]]; then
  for i in $userList; do
    lastUdate=$(aws iam list-users --query "Users[?UserName=='$i'].PasswordLastUsed" --output text | cut -d 'T' -f1)
    if [ "$lastUdate" == "" ]
    then
      echo -e "\n$RED User \"$i\" has not logged in during the last 90 days$RESET"
    else
      oDays=$(compareDate $lastUdate)
      if [ $oDays -gt "90" ];then
        echo -e "\n$RED User \"$i\" has not logged in during the last 90 days$RESET"
      else
        echo -e "\n$RED User \"$i\" found with credentials used in the last 90 days$RESET"
      fi
    fi
  done
else
    echo -e "\n$WHITE No users found with password enabled$RESET"
fi


#1.4 Ensure access keys are rotated every 90 days or less

echo -e "\n\n1.4 Ensure access keys are rotated every 90 days or less"

usersKey1=$(cat $TEMPORARYFILE| awk -F, '{ print $1, $9 }' |grep "\ true" | awk '{ print $1 }')
userskey2=$(cat $TEMPORARYFILE| awk -F, '{ print $1, $14 }' |grep "\ true" | awk '{ print $1 }')
cn1=0
cn2=0
if [[ $usersKey1 ]]; then
  for user in $usersKey1; do
    dd1=$(cat $TEMPORARYFILE | grep -v user_creation_time | grep "$user"| awk -F, '{ print $10 }' | grep -v "N/A" | awk -F"T" '{ print $1 }')
    olDays=$(compareDate $dd1)
    if [[ $olDays -gt "90" ]];then
      echo -e "\n$RED Access key set 1 not rotated in over 90 days for: $user$RESET"
      cn1=$(expr $cn1 + 1)
    fi
  done
  if [[ $cn1 -eq 0 ]]; then
    echo -e "\n$WHITE No users with access key set 1 older than 90 days$RESET"
  fi
else
  echo -e "\n$WHITE No users with access key set 1$RESET"
fi

if [[ $usersKey2 ]]; then
  for user in $usersKey2; do
    dd2=$(cat $TEMPORARYFILE | grep -v user_creation_time | grep "$user"| awk -F, '{ print $15 }' | grep -v "N/A" | awk -F"T" '{ print $1 }')
    olDays=$(compareDate $dd2)
    if [[ $olDays -gt "90" ]];then
      echo -e "\n$RED Access key set 2 not rotated in over 90 days for: $user$RESET"
      cn2=$(expr $cn2 + 1)
    fi
  done
  if [[ $cn2 -eq 0 ]]; then
    echo -e "\n$WHITE No users with access key set 2 older than 90 days$RESET"
  fi
else
  echo -e "\n$WHITE No users with access key set 2$RESET"
fi
    
#1.5 Ensure IAM password policy requires at least one uppercase letter

echo -e "\n\n1.5 Ensure IAM password policy requires at least one uppercase letter"

upperCase=$(aws iam get-account-password-policy --query 'PasswordPolicy.RequireUppercaseCharacters' 2> /dev/null) 
if [[ "$upperCase" == "true" ]];then
  echo -e "\n$WHITE Uppercase requirement of Password Policy is satisfied$RESET"
else
  echo -e "\n$RED Password Policy is missing uppercase requirement$RESET"
fi
  
#1.6 Ensure IAM password policy require at least one lowercase letter

echo -e "\n\n1.6 Ensure IAM password policy require at least one lowercase letter"

lowerCase=$(aws iam get-account-password-policy \--query 'PasswordPolicy.RequireLowercaseCharacters' 2> /dev/null) 
if [[ "$lowerCase" == "true" ]];then
  echo -e "\n$WHITE Lowercase requirement of Password Policy is satisfied$RESET"
else
  echo -e "\n$RED Password Policy is missing lowercase requirement$RESET"
fi

#1.7 Ensure IAM password policy require at least one symbol

echo -e "\n\n1.7 Ensure IAM password policy require at least one symbol"

symPass=$(aws iam get-account-password-policy --query 'PasswordPolicy.RequireSymbols' 2> /dev/null)
if [[ "$symPass" == "true" ]];then
  echo -e "\n$WHITE Symbol requirement of Password Policy is satisfied$RESET"
else
  echo -e "\n$RED Password Policy is missing symbol requirement$RESET"
fi

#1.8 Ensure IAM password policy require at least one number

echo -e "\n\n1.8 Ensure IAM password policy require at least one number"

numPass=$(aws iam get-account-password-policy --query 'PasswordPolicy.RequireNumbers' 2> /dev/null)
if [[ "$numPass" == "true" ]];then
  echo -e "\n$WHITE Number requirement of Password Policy is satisfied$RESET"
else
  echo -e "\n$RED Password Policy is missing number requirement$RESET"
fi

#1.9 Ensure IAM password policy requires minimum length of 14 or greater

echo -e "\n\n1.9 Ensure IAM password policy requires minimum length of 14 or greater"

lenPass=$(aws iam get-account-password-policy --query 'PasswordPolicy.MinimumPasswordLength' 2> /dev/null)
if [[ $lenPass -gt "13" ]];then
  echo -e "\n$WHITE Password policy satifies the minimum required password length of 14$RESET"
else
  echo -e "\n$RED Password Policy isn't meeting the required password length$RESET"
fi

#1.10 Ensure IAM password policy prevents password reuse

echo -e "\n\n1.10 Ensure IAM password policy prevents password reuse"

reusePass=$(aws iam get-account-password-policy --query 'PasswordPolicy.PasswordReusePrevention' 2> /dev/null)
if [[ $reusePass ]];then
  if [[ $reusePass -gt "23" ]];then
    echo -e "\n$WHITE Password policy is compliant to password reuse requirement$RESET"
  else
    echo -e "\n$RED Password Policy has weak reuse requirement of lower than 24$RESET"
  fi
else
  echo -e "\n$RED Password Policy is missing reuse requirement$RESET"
fi


#1.11 Ensure IAM password policy expires passwords within 90 days or less

echo -e "\n\n1.11 Ensure IAM password policy expires passwords within 90 days or less"

expPass=$(aws iam get-account-password-policy --query PasswordPolicy.MaxPasswordAge 2>&1)
if [[ $expPass == [0-9]* ]];then
  if [[ "$expPass" -le "90" ]];then
    echo -e "\n$WHITE Password policy is compliant to password expiration requirement$RESET"
  else
    echo -e "\n$RED Password Policy has weak password expiration requirement of greater than 90 days$RESET"
  fi
else
  echo -e "\n$RED Password Policy is missing password expiration setting$RESET"
fi


#1.12 Ensure no root account access key exists

echo -e "\n\n1.12 Ensure no root account access key exists"

key1Root=$(cat $TEMPORARYFILE |grep root_account|awk -F',' '{ print $9 }')
key2Root=$(cat $TEMPORARYFILE |grep root_account|awk -F',' '{ print $14 }')
if [[ "$key1Root" == "false" && "$key2Root" == "false" ]];then
  echo -e "\n$WHITE No access key exists for root account$RESET"
else
  echo -e "\n$RED Access key exists for root$RESET"
fi


#1.13 Ensure MFA is enabled for the root account

echo -e "\n\n1.13 Ensure MFA is enabled for the root account"

mfaRoot=$(aws iam get-account-summary --query 'SummaryMap.AccountMFAEnabled')
if [ "$mfaRoot" == "1" ]; then
  echo -e "\n$WHITE MFA exists for root account$RESET"
else
  echo -e "\n$RED MFA does not exist for root account$RESET"
fi  


#1.14 Ensure Hardware MFA is enabled for the root account

echo -e "\n\n1.14 Ensure Hardware MFA is enabled for the root account : NOT APPLICABLE"

#1.15 Ensure security questions are registered in the AWS account

echo -e "\n\n1.15 Ensure security questions are registered in the AWS account : CHECK MANUALLY USING AWS CONSOLE"

#1.16 Ensure IAM policies are attached only to groups or roles

echo -e "\n\n1.16 Ensure IAM policies are attached only to groups or roles"

usersAll=$(aws iam list-users --query 'Users[*].UserName' | cut -d "\"" -f2 | tr -d "[]" | sed -r '/^\s*$/d')
uu=0
for user in $usersAll;do
  userpol=$(aws iam list-attached-user-policies --user-name $user)
  if [[ $userpol ]]; then
    uu=1
  fi
  userpol=$(aws iam list-user-policies --user-name $user)
  if [[ $userpol ]]; then
    uu=1
  fi
done
if [[ $uu -eq 0 ]]; then
  echo -e "\n$WHITE No policies attached to users$RESET"
else
    echo -e "\n$RED Users have policies attached directly$RESET"
fi


#1.15 Ensure security questions are registered in the AWS account

echo -e "\n\n1.17 Maintain current contact details : CHECK MANUALLY USING AWS CONSOLE"
#1.15 Ensure security questions are registered in the AWS account

echo -e "\n\n1.18 Ensure security contact information is registered : CHECK MANUALLY USING AWS CONSOLE"
#1.15 Ensure security questions are registered in the AWS account

echo -e "\n\n1.19 Ensure IAM instance roles are used for AWS resource access from instances: CHECK MANUALLY USING AWS CONSOLE"



#1.20 Ensure a support role has been created to manage incidents with AWS Support

echo -e "\n\n1.20 Ensure a support role has been created to manage incidents with AWS Support"

supPol=$(aws iam list-policies --query "Policies[?PolicyName == 'AWSSupportAccess'].Arn" | cut -d "\"" -f2 | tr -d "[]" | sed -r '/^\s*$/d')
if [[ $supPol ]];then
  for pp in $supPol;do
    ppp=$(aws iam list-entities-for-policy --policy-arn $pp)
    pg=$(echo -e $ppp | jq ".PolicyGroups[]")
    pu=$(echo -e $ppp | jq ".PolicyUsers[]")
    prr=$(echo -e $ppp | jq ".PolicyRoles[]")
    if [[ $pg ]] || [[ $pu ]] || [[ $prr ]];then
      echo -e "\n$WHITE Support Policy is attached to User$RESET"
    else
      echo -e "\n$RED Support Policy is not applied to any Role$RESET"
    fi
  done
else
  echo -e "\n$RED No Support Policy found$RESET"
fi


#1.21 Do not setup access keys during initial user setup for all IAM users that have a console password

echo -e "\n\n1.21 Do not setup access keys during initial user setup for all IAM users that have a console password"

usersAll=$(aws iam list-users --query 'Users[*].UserName' | cut -d "\"" -f2 | tr -d "[]" | sed -r '/^\s*$/d')
key1a=$(for user in $usersAll; do cat $TEMPORARYFILE | grep "$user" | grep N/A | awk -F, '{ print $1,$11 }' | awk '{ print $1 }'; done)
key1active=$(for user in $key1a; do cat $TEMPORARYFILE | grep "$user" | awk -F, '{ print $1,$9 }'|grep "true$"|awk '{ print $1 }'; done)
if [[ $key1active ]]; then
  for u in $key1active; do
    echo -e "\n$RED $u has never used Access key 1 and must be disabled$RESET"
  done
else
  echo -e "\n$WHITE Access key 1 : Passed"
fi
key2a=$(for user in $usersAll; do cat $TEMPORARYFILE | grep "$user" | grep N/A | awk -F, '{ print $1,$16 }'| awk '{ print $1 }' ; done)
key2active=$(for user in $key2a; do cat $TEMPORARYFILE | grep "$user" | awk -F, '{ print $1,$14 }'|grep "true$" |awk '{ print $1 }' ; done)
if [[ $key2active ]]; then
  for u in $key2active; do
    echo -e "\n$RED $u has never used Access key 2 and must be disabled$RESET"
  done
else
  echo -e "\n$WHITE Access key 2 : Passed$RESET"
fi


#1.22 Ensure IAM policies that allow full "*:*" administrative privileges are not created

echo -e "\n\n1.22 Ensure IAM policies that allow full "*:*" administrative privileges are not created"

customPolicies=$(aws iam list-policies --scope Local --query 'Policies[*].[Arn,DefaultVersionId]' | grep arn | cut -d "\"" -f2 | sed -r '/^\s*$/d')
#flag=0
if [[ $customPolicies ]]; then
  for policy in $customPolicies; do
    pArn=$policy
    pVersion=$(aws iam get-policy --policy-arn $policy | jq ".Policy.DefaultVersionId" | cut -d "\"" -f2)
    gettingPol=$(aws iam get-policy-version --policy-arn $pArn --version-id $pVersion)
    actionPol=$(echo -e $gettingPol | jq ".PolicyVersion.Document.Statement[].Action" 2>&1 | cut -d "\"" -f2)
    resourcePol=$(echo -e $gettingPol | jq ".PolicyVersion.Document.Statement[].Resource" 2>&1 | cut -d "\"" -f2)
    effectPol=$(echo -e $gettingPol | jq ".PolicyVersion.Document.Statement[].Effect" 2>&1 | cut -d "\"" -f2)
    if [[ $actionPol == "*" ]] && [[ $actionPol == "*" ]] && [[ $effectPol == "Allow" ]]; then
      finalPol="$finalPol $pArn"
    fi
  done
  if [[ $finalPol ]]; then
    for pol in $finalPol; do
      echo -e "\n$RED Policy $pol allows \"*:*\"$RESET"
    done
  else
      echo -e "\n$WHITE No custom policy found that allow full \"*:*\" administrative privileges$RESET"
  fi
else
  echo -e "\n$WHITE No custom policies found$RESET"
fi


echo -e "\n ${YEL}CIS Benchmarks Check Complete. Thanks !!!${RESET}"
echo -e "\n\n${YEL}==================================================================================${RESET}\n"


