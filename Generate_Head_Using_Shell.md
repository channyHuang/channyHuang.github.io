---
layout: default
---

//Author: channy

//Create Date: 2018-10-01 10:24:25

//Description: 

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

if ! grep "^#!" ${file} &>/dev/null; then

cat >> ${file} << EOF

\EOF

```

[back](./)