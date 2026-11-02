#!/bin/bash
# painel do build: status + fim do log, a cada 5 s (Ctrl+C fecha só o painel, não o build)
while true; do
  OUT=$(
    cat ~/build.status 2>/dev/null || echo "o build ainda nao escreveu o status..."
    echo
    echo "------------------------------ log ao vivo ------------------------------"
    tail -n 400 ~/build.log 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' \
      | grep -vE '^\s*$|K \.\.\.|^(Resolving|Connecting|HTTP request|Length:|Saving to|--[0-9]{4}-)' \
      | tail -n 18 | cut -c1-150
    echo
    echo "(atualiza a cada 5 s - Ctrl+C fecha so este painel, o build continua)"
  )
  clear
  echo "$OUT"
  sleep 5
done
