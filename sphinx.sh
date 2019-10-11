#/bin/bash

service=searchd
status=($(systemctl status searchd | grep Active | awk '{print $2}'))
dir=/var/lib/sphinx/
dir_log=/var/log/sphinx/

check_service () {

echo -e "* \e[4;32mStart sphinx update...\e[0m"

if [[ $status =~ ^[Aa]ctive ]]
then
	read -p ":: Service $service $status, stop service? (y/N) " answer
	if [[ $answer =~ ^([^Yy]) ]] || [[ -z $answer ]]
        then
                echo -e "* \e[1;31mService $service not stopped, update canceled\e[0m" && exit 1
        else
		systemctl stop $service && status=($(systemctl status $service | grep Active | awk '{print $2}'))
		if [[ $status =~ ^[Aa]ctive ]]
		then
			echo -e "* Service $service status \e[1;32m$status\e[0m, \e[1;31mERROR\e[0m"
		else
			echo -e "* Service $service status \e[1;31m$status\e[0m, \e[1;32mSuccess\e[0m"
		fi
        fi
else
	echo -e "* Service $service status \e[1;31m$status\e[0m"
fi
}

clear_dir () {

read -p ":: Clear dir $dir? (y/N) " answer
if [[ $answer =~ ^([^Yy]) ]] || [[ -z $answer ]]
	then
                echo -e "* \e[1;31mCanceled\e[0m" && start_service &&exit 1
	else
		rm -f $dir* && echo -e "* \e[1;32mSuccesful\e[0m"
fi
}

clear_log () {

read -p ":: Clear log in $dir_log? (y/N) " answer
if [[ $answer =~ ^([^Yy]) ]] || [[ -z $answer ]]
        then
                echo -e "* \e[1;31mCanceled\e[0m"
        else
                rm -f $dir_log* && echo -e "* \e[1;32mSuccesful\e[0m"
fi
}

unzip () {
file=($(ls -a1 ~/ | grep ^[sS]phinx_data.7z))
if [ -f ~/$file ]
then
	read -p ":: Unzip the $file to $dir? (y/N) " answer
	if [[ $answer =~ ^([^Yy]) ]] || [[ -z $answer ]]
		then
			echo -e "* \e[1;31mCanceled\e[0m" && start_service && exit 1

		else
			7z x -o$dir $file && echo -e "* \e[1;32mSuccesful\e[0m"
	fi
else
	echo -e "* File \e[4msphinx_data.7z\e[0m \e[1;31mNOT FOUND\e[0m in HOME dir"
	read -p "Retry? (y/N) " answer
		if [[ $answer =~ ^([^Yy]) ]] || [[ -z $answer ]]
			then
				echo -e "* \e[1;31mCanceled\e[0m" && start_service &&exit 1
			else
				unzip
		fi
fi
}

permission () {
read -p ":: Set permissions and group? (y/N) " answer
	if [[ $answer =~ ^([^Yy]) ]] || [[ -z $answer ]]
		then
			echo "* \e[1;31mCancel set permission and group\e[0m"

		else
			chown sphinx:sphinx $dir* && echo -e "* \e[1;32mSet permission succesfully\e[0m"
			chmod 744 $dir* && echo -e "* \e[1;32mSet group succesfully\e[0m"
        fi
}

update_system () {
read -p ":: Update system? (y/N) " answer
        if [[ $answer =~ ^([^Yy]) ]] || [[ -z $answer ]]
                then
                        echo -e "* \e[1;31mCancel update system\e[0m"

                else
                        yum update && echo -e "* \e[1;32mUpdate succesful\e[0m"
        fi
}

start_service () {
status=($(systemctl status $service | grep Active | awk '{print $2}'))
if [[ $status =~ ^[Aa]ctive ]]
	then
		echo -e "* Service $service status \e[1;32m$status\e[0m, \e[1;31mERROR\e[0m"
        else
		read -p ":: Start $service? (y/N) " answer
			if [[ $answer =~ ^([^Yy]) ]] || [[ -z $answer ]]
				then
					echo -e "* Cancell start $service, Service $service status \e[1;31m$status\e[0m, \e[32mSuccess\e[0m"
				else
					systemctl start $service && status=($(systemctl status $service | grep Active | awk '{print $2}')) && echo -e "* Service $service status \e[1;32m$status\e[0m, \e[1;32mSuccess\e[0m"
			fi
fi
}

read -p ":: Update sphinx? (y/N) " answer
	if [[ $answer =~ ^([^Yy]) ]] || [[ -z $answer ]]
		then
			echo -e "* \e[1;31mUpdate sphinx canceled\e[0m" && exit 1
		else
			check_service
			clear_dir
			clear_log
			unzip
			permission
			update_system
			start_service
	fi
