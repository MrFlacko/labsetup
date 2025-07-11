sudo apt install nfs-kernel-server

echo "/mnt/big  172.16.0.0/24(rw,no_subtree_check,async)" | sudo tee -a /etc/exports
/mnt/big  172.16.0.0/24(rw,no_subtree_check,async)

sudo exportfs -ra # reloading
