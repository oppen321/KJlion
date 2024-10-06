#!/bin/bash

sh_download() {
country=$(curl -s ipinfo.io/country)
if [ "$country" = "CN" ]; then
    cd ~
    curl -sS -O https://gh.kejilion.pro/https://raw.githubusercontent.com/kejilion/sh/main/kejilion.sh && chmod +x kejilion.sh
    sed -i 's/country="default"/country="CN"/g' ./kejilion.sh > /dev/null 2>&1
    ./kejilion.sh
else
    cd ~
    curl -sS -O https://raw.githubusercontent.com/kejilion/sh/main/kejilion.sh && chmod +x kejilion.sh && ./kejilion.sh
fi

}

sh_download
