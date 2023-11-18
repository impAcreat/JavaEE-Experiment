
for i in 3600 3620 3640 3660 3680
do
	echo "=====${i}====="
	command="bash scripts/exp01.sh MGQ ${i} 100 Read true"
	echo ${command}
	eval ${command}
done
