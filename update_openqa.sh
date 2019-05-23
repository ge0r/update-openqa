#! /bin/bash

KEY="79B320AAF5E9EFFD"
SECRET="A4EF9D6C5122571D"

repos=("tests" "suse_needles" "opensuse_needles" "tools")

tests="/var/lib/openqa/share/tests/os-autoinst-distri-opensuse"
suse_needles="/var/lib/openqa/tests/os-autoinst-distri-opensuse/products/sle/needles"
opensuse_needles="/var/lib/openqa/tests/os-autoinst-distri-opensuse/products/opensuse/needles"
tools="/var/lib/openqa/tests/os-autoinst-distri-opensuse/os-autoinst/"

# declare and fill up an associative array of the directories
declare -A directories=( ["tests"]="$tests" ["suse_needles"]="$suse_needles" ["opensuse_needles"]="$opensuse_needles" ["tools"]="$tools")



# update openQA packages
echo -e "\n--------Updating the openQA packages--------\n"
zypper -n up --allow-vendor-change openQA

# update the repositories
for repo in ${repos[*]}
do
	echo -e "\n--------Updating "$repo"--------\n"
	dir="${directories[$repo]}"

	if ! cd $dir; then
	  echo -e "\n\nIssue encountered: "$repo" repository does not exit"
	  exit 1
	fi
	if ! git checkout master; then
	  echo -e "\n\nIssue encountered: Cannot checkout "$repo" repository"
	  exit 1
	fi

	if git diff --exit-code; then
        git ls-remote --exit-code upstream > /dev/null
        if test $? = 0; then
            git pull upstream master
        else
            echo -e "\n\nIssue encountered: Remote repository called upstream doesn't seem to exist for "$repo
            exit 1
        fi
	else
	  echo -e "\n\nIssue encountered: You have uncomitted changes in your "$repo" repository"
	  exit 1
	fi
done

# update the templates
echo -e "\n--------Updating the templates (this will take a while...)--------\n"
/usr/share/openqa/script/dump_templates --host openqa.suse.de --apikey $KEY --apisecret $SECRET > ~/templates
/usr/share/openqa/script/load_templates --host "localhost" ~/templates --clean


echo -e "\n--------openQA components updated successfully!!!--------\n"

