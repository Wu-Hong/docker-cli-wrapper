mkdir -p /root/.jupyter;
echo '{"NotebookApp": {"password": "sha1:5a1f9a5ad50e:da4bd4f4a1c538a8036cb6fb5693010858b3d195"}}' > /root/.jupyter/jupyter_notebook_config.json;
IP=`ip addr show eth0 | grep inet | sed -e 's/brd.*//g' -e 's/    inet //g' -e 's/\/.*//g'`;
PORT=8080;
echo "jupyter endpoint: ${IP}:${PORT}";
jupyter notebook --allow-root --ip="${IP}" --port=${PORT} --notebook-dir=/home/jupyter
