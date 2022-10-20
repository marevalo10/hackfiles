#script to call upload option for all the files split in Linux using Apache PHP upload explained below
#!/bin/bash
url="http://my.ip/myupl.php""
for filename in $(ls all_split.*); do echo "Sending file $filename"; curl -F "file=@$filename"$url; done
