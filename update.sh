#!/bin/bash

subcsv=projects.csv
cmd=0
all=0
file=0

show_content()
{
	while IFS=, read short_name repo_url email col4 col5
	do
		echo "name: $short_name"
		echo "  url: $repo_url"
		echo "  email: $email"
		#echo "  opt4: $col4"
		#echo "  opt5: $col5"
	done < $1
}

create_gitignore()
{
	path=${PWD}
	echo "Creating .gitignore in ${path}"

	echo "### ignore build files" > ${path}/.gitignore
	echo "*.[oa]
*~

### ignore os files
.DS_*
._*
.Spotlight-V100
.Trashes
Icon?
ehthumbs.db
Thumbs.db

### ignore dirs listed in file.csv" >> ${path}/.gitignore

	while IFS=, read short_name repo_url email col4 col5
	do
		echo ${short_name} >> ${path}/.gitignore
	done < $1

	cat ${path}/.gitignore
}

# pull parent.csv [projects.csv -a]
pull()
{
	path=${PWD}
	echo ${path}
	while IFS=, read short_name repo_url email col4 col5
	do
		echo "#############################################"
		echo "     $short_name"
		echo "#############################################"
		echo "$short_name | $repo_url | $email | $col4 | $col5"
		
		if [ ! -d ${path}/${short_name} ]; then
			cd ${path}
			echo "## ${short_name} not found, getting ${repo_url}"
			git clone ${repo_url} ${short_name}
		fi
		
		echo "### updating ${short_name}, using ${repo_url}"
		cd ${path}/${short_name}
		git pull
		cd ${path}
		
		# search 1 level deeper for projects.csv
		if [ ${all} == 1 ]; then
			while IFS=, read sub_name sub_url sub_email option4 option5
			do
				cd ${path}/${short_name}
				# TODO make this recursive?
				if [ ! -d ${path}/${short_name}/${sub_name} ]; then
					echo " ## ${sub_name} not found, getting ${sub_url}"
					git clone ${sub_url} ${sub_name}
				else
					echo " ## updating ${sub_name}, using ${sub_url}"
					cd ${path}/${short_name}/${sub_name}
					git pull
				fi
			done < ${path}/${short_name}/$2
		fi
	done < $1
}

usage()
{
	echo "Usage: update.sh [options] <filename>

[options] is any of the following:
  -s <file>   show <file>       show contents of <file.csv>
  -p <file>   pull <file>       pull repos listed in file.csv
  -g <file>   gitignore <file>  create .gitignore from file.csv
  -a          all               also pull repos listed in subdir/projects.csv
  -h          help              show this info
  
   ./update.sh -p <file.csv>
   ./update.sh -ap <file.csv> | tee log
" >&2
}


while getopts ":has:g:p:" opt; do
  case $opt in
    h)
      cmd="help"
      ;;
    a)
      all=1
      ;;
    s)
      cmd="show"
      file="$OPTARG"
      ;;
    g)
      cmd="gitignore"
      file="$OPTARG"
      ;;
    p)
      cmd="pull"
      file="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      cmd="$OPTARG"
      usage
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument."
      usage
      exit 1
      ;;
  esac
done


if [ ${cmd} == "help" ]; then
	usage
elif [ ${cmd} == "pull" ]; then
	pull ${file} ${subcsv}
elif [ ${cmd} == "show" ]; then
	show_content ${file}
elif [ ${cmd} == "gitignore" ]; then
	create_gitignore ${file}
elif [ ${cmd} == 0 ]; then
	usage
else
	usage
fi
