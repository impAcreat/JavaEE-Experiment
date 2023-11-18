
for i in 1000 1100 1200 1300 1400 1500 1600 1700 1800 1900 2000
do
	echo "====${i}===="
	command="bash scripts/exp01.sh MGQ ${i} 10 Read true"
	echo ${command}
	eval ${command}
done
