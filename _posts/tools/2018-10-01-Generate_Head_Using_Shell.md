---
layout: default
title: Generate_Head_Using_Shell
categories:
- Tools
tags:
- Tools
---
//Description: Generate File Head Using Shell

//Author: channy

//Create Date: 2018-10-01 10:24:25

# f1

```sh

#!/bin/bash
if [ $# != 2 ]; then
echo "Usage: $0 filename path"
exit 1;
fi

filename=$1
path=$2
file=${filename}".md"
cd ${path}

if [ -f "${file}" ]; then
echo "File ${file} exist in ${path}"
read -p "Delete old file and new one? (Y/N):" del
if [ ${del} == "Y" ]; then
rm ${file}
else
exit 1;
fi
fi

if ! grep "^#!" ${file} &>/dev/null; then
cat >> ${file} << EOF
---
layout: default
totle: ${file}
categories:
- C++
tags:
- C++
---
//Description:

//Create Date: `date +"%F %T"`

//Author: channy

# ${filename}

[back](./)

EOF
fi
vim +8 $1".md"

\EOF

```

[back](./)
