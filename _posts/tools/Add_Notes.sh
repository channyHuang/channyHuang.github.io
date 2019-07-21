#!/bin/bash

if [ $# != 1 ]; then
echo "Usage: $0 event"
exit 1;
fi

event=$1
file="Notes_And_Bugs_In_Work.md"

if [ -f "${file}" ]; then
echo "File $[file} exist"
fi

if ! grep "^#!" ${file} &>/dev/null; then
cat >> ${file} << EOF

> `date` + $1
EOF
fi

echo "Done. Add notes successfully"

