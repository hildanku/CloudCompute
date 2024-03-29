name="============== HILDAN K UTOMO ==============="
gap="============================================="
memsizebymb="Ukuran memori pada satuan MB"
diskusagebygb="Penggunaan Storage dalam satuan GB"
diskusagewithfiltration="Penggunaan Storage pada kolom Filesystem dan use%"

echo $name # menampilkan value ===hildankutomo===

count=0 # declarate count value is 0
while [ $count -lt 3 ]; do # program will stop after condition is fully
    echo $memsizebymb 
    free -m # get ram usage by m
    sleep 3
    echo $gap

    echo $diskusagebygb
    df -BG
    sleep 3
    echo $gap

    echo $diskusagewithfiltration
    df -h --output=source,pcent | grep -v tmpfs # get disk usage without tmpfs
    sleep 1m # sleep 1m

    count=$((count + 1))
done
