# Use this file as a command.
# 
# start
#	- starts the containers
#
# stop
#	- stops the containers
#
# run <command>
#	- runs <command> on the designated containers
#	options:
#		- new - builds new project
#		- setup - sets up project
#

# confirm <command> <question> <message if canceled>
function confirm(){
	read -p "$2" confirm
	if [ "$confirm" = 'y' ] || [ "$confirm" = 'Y' ]
	then
		$1
	else
		echo "$3"
	fi
}

# ./commands.sh start
function startProject(){
	failed=1
	# docker-compose up -d && echo "docker app started" && echo "Ctrl + Click: http://localhost:9000" && failed=0
	cd G-Est_backend && ./commands.sh start && \
	cd .. && \
	cd G-Est_frontend && ./commands.sh start && \
	cd .. && \
	echo "" && \
	echo "########################################" && \
	echo "# ~> phpmyadmin: http://localhost:8081 #" && \
	echo "# ~> laravel:    http://localhost:8080 #" && \
	echo "# ~> quasar:     http://localhost:80   #" && \
	echo "########################################" && \
	failed=0
	if [ $failed -eq 1 ]
	then
		echo "docker app failed to start"
	fi
}

# ./commands.sh stop
function stopProject(){
	failed=1
	cd G-Est_frontend && ./commands.sh stop && \
	cd .. && \
	cd G-Est_backend && ./commands.sh stop && \
	cd .. && \
	failed=0
	if [ $failed -eq 1 ]
	then
		echo "docker app failed to stop"
	fi
}

# ./commands.sh run setup
function setupProject(){
	(git clone -b dev https://github.com/henrique11varela/G-Est_backend.git || true) && \
	(git clone -b dev https://github.com/henrique11varela/G-Est_frontend.git || true) && \
	cd G-Est_backend && ./commands.sh run setup && \
	cd .. && \
	cd G-Est_frontend && ./commands.sh run setup && \
	cd .. && \
	echo "docker app setup"
}

function migrateProject(){
	failed=1
	cd G-Est_backend && ./commands.sh run migrate && \
	cd .. && \
	failed=0
	if [ $failed -eq 1 ]
	then
		echo "docker app failed to migrate"
	fi
}

# Main
case $1 in
	# start
	start)
		startProject
		;;
	start-local)
		cd G-Est_backend && bash commands.sh start-local && \
		cd .. && \
		cd G-Est_frontend && bash commands.sh start-local && \
		cd .. && \
		echo "" && \
		echo "########################################" && \
		echo "# ~> phpmyadmin: http://localhost/phpmyadmin #" && \
		echo "# ~> laravel:    http://localhost:8000 #" && \
		echo "# ~> quasar:     http://localhost:9000   #" && \
		echo "########################################"
		;;
	# stop
	stop)
		stopProject
		;;
	# run
	run)
		case $2 in
			# run setup
			setup)
				setupProject
				;;
			setup-local)
				(git clone -b dev https://github.com/henrique11varela/G-Est_backend.git || true) && \
				(git clone -b dev https://github.com/henrique11varela/G-Est_frontend.git || true) && \
				cd G-Est_backend && bash commands.sh run setup-local && \
				cd .. && \
				cd G-Est_frontend && bash commands.sh run setup-local && \
				cd .. && \
				echo "app setup"
				;;
			# run migrate
			migrate)
				migrateProject
				;;
			# run migrate
			migrate-local)
				cd G-Est_backend && \
				bash commands.sh migrate-local && \
				cd .. 
				;;
			# run ____
			*)
				if [ -z $2 ]
				then
					echo "No arguments where provided after \"$1\"."
				else
					echo "unknown command"
				fi
				;;
		esac
		;;
	# ____
	*)
		if [ -z $1 ]
		then
			echo "No arguments where provided."
		else
			echo "unknown command"
		fi
		;;
esac

