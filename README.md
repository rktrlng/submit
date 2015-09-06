submit
======

An example submit repository. Add projects you want to submit to the .csv file.

update.sh
---------

A tool to automatically pull (sub)projects into this directory and create a .gitignore file.

	Usage: update.sh [options] <filename>

	[options] is any of the following:
	  -s <file>   show <file>       show contents of <file.csv>
	  -p <file>   pull <file>       pull repos listed in file.csv
	  -g <file>   gitignore <file>  create .gitignore from file.csv
	  -a          all               also pull repos listed in subdir/projects.csv
	  -h          help              show this info
	  
	   ./update.sh -p <file.csv>
	   ./update.sh -ap <file.csv> | tee log
