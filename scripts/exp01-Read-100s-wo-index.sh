
for i in 3000 3025 3050 3075 3100 3125 3150 3175 3200 3225 3250
do
	echo "=====${i}====="
	command="bash scripts/exp01.sh MGQ ${i} 100 Read false"
	echo ${command}
	eval ${command}
done
