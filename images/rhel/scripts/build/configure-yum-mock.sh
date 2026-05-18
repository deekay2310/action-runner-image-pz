#!/bin/bash -e
################################################################################
##  File:  configure-yum-mock.sh
##  Desc:  A temporary workaround to handle transient issues with DNF/YUM.
##         Cleaned up during cleanup.sh.
################################################################################
prefix=/usr/local/bin

for real_tool in /usr/bin/yum /usr/bin/dnf; do
    tool=$(basename $real_tool)
    cat >$prefix/"$tool" <<EOT
#!/bin/sh

max_retries=30
i=1
while [ \$i -le \$max_retries ];do
  err=\$(mktemp)
  $real_tool "\$@" 2>\$err
  rc=\$?

  if [ \$rc -eq 0 ]; then
    rm -f \$err
    exit 0
  fi

  cat \$err >&2

  retry=false

  if grep -q 'Could not get lock' \$err;then
    retry=true
  elif grep -q 'Temporary failure in name resolution' \$err;then
    retry=true
  elif grep -q 'Package is being held by another process' \$err;then
    retry=true
  elif grep -q 'Failed to download metadata' \$err && ! grep -q 'Status code: 404' \$err;then
    retry=true
  fi

  rm -f \$err
  if [ \$retry = false ]; then
    exit \$rc
  fi

  sleep 5
  echo "...retry \$i/\$max_retries"
  i=\$((i + 1))
done

echo "ERROR: Exhausted \$max_retries retries, giving up."
exit \$rc
EOT
    chmod +x $prefix/"$tool"
done
