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
	docker-compose up -d && echo "docker app started" && echo "Ctrl + Click: http://localhost:9000" && failed=0
	if [ $failed -eq 1 ]
	then
		echo "docker app failed to start"
	fi
}

# ./commands.sh stop
function stopProject(){
	failed=1
	docker-compose down && echo docker app stopped && failed=0
	if [ $failed -eq 1 ]
	then
		echo "docker app failed to stop"
	fi
}

function envDevFill(){
    # .env Constants
    env_path="G-Est_backend/src/.env"
    env_example_path="G-Est_backend/src/.env.example"
    APP_KEY="base64:nEBQ1DB+qSBkkWYasazlciiHNDRNt3GGHE1AHm3I1nc=" # static key for development
    DB_HOST="mysql" # database docker container name
    DB_DATABASE="homestead" # database name
    DB_USERNAME="homestead" # connection user name
    DB_PASSWORD="secret" # connection user password

    rm -f $env_path
    while IFS="=" read -r envKey envValue
    do
        case $envKey in
            APP_KEY)
                echo "$envKey=$APP_KEY" >> $env_path
                ;;
            DB_HOST)
                echo "$envKey=$DB_HOST" >> $env_path
                ;;
            DB_DATABASE)
                echo "$envKey=$DB_DATABASE" >> $env_path
                ;;
            DB_USERNAME)
                echo "$envKey=$DB_USERNAME" >> $env_path
                ;;
            DB_PASSWORD)
                echo "$envKey=$DB_PASSWORD" >> $env_path
                ;;
            *)
                if [ -n "$envKey" ]
                then
                    echo "$envKey=$envValue" >> $env_path
                else
                    echo "" >> $env_path
                fi
                ;;
        esac
    done < $env_example_path
	echo ".env file updated for development"
}

# ./commands.sh run setup
function setupProject(){
	./G-Est_backend/commands.sh run setup && \
	./G-Est_frontend/commands.sh run setup
	echo "docker app setup"
}

# Main
case $1 in
	# start
	start)
		envDevFill
		startProject
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
				envDevFill
				setupProject
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

