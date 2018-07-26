#jupyter notebook password
IP=`ip addr show eth0 | grep inet | sed -e 's/brd.*//g' -e 's/    inet //g' -e 's/\/.*//g'`
PORT=8080
echo "jupyter endpoint: ${IP}:${PORT}"
jupyter notebook --allow-root --ip="${IP}" --port=${PORT} --notebook-dir=/root/workspace/jupyter &
