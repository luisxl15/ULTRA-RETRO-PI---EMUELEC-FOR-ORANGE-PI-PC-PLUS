#!/bin/bash
# Roda o build do ULTRA RETRO PI no WSL e mede o disco. Para sozinho se o C: do
# Windows (onde mora o disco virtual do WSL) cair abaixo de MIN_FREE_GB.
# Status a cada 30 s em ~/build.status; log completo em ~/build.log.

SRC=~/Neo-EmuELEC-H3
LOG=~/build.log
STATUS=~/build.status
RC=~/build.rc
MIN_FREE_GB=${MIN_FREE_GB:-5}
EVERY=10

cd $SRC || exit 1
rm -f $RC
: > $LOG

START=$(date +%s)
BASE_MB=$(df -BM --output=used / | tail -1 | tr -dc 0-9)
PEAK_MB=0
STOPPED=

# sessão própria para poder matar a árvore inteira de uma vez
setsid bash -c "yes | PROJECT=H3 ARCH=arm DISTRO=EmuELEC UBOOT_SYSTEM=opipcplus make image; echo \$? > $RC" > $LOG 2>&1 < /dev/null &
BPID=$!

cpu_sample() { awk '/^cpu /{print $2+$3+$4+$7+$8, $2+$3+$4+$5+$6+$7+$8}' /proc/stat; }
read B0 T0 < <(cpu_sample)

hms() { printf '%dh%02dm%02ds' $(( $1/3600 )) $(( $1%3600/60 )) $(( $1%60 )); }

write_status() {
  NOW=$(date +%s)
  FREE_C=$(df -BG --output=avail /mnt/c | tail -1 | tr -dc 0-9)
  # o disco do Linux inteiro (sistema ~2 GB + fontes + build): é isso que cresce no C:
  USED_MB=$(df -BM --output=used / | tail -1 | tr -dc 0-9)
  [ $USED_MB -gt $PEAK_MB ] && PEAK_MB=$USED_MB
  read B1 T1 < <(cpu_sample)
  CPU=$(( (T1 - T0) > 0 ? 100 * (B1 - B0) / (T1 - T0) : 0 ))
  B0=$B1; T0=$T1
  # o build paralelo escreve "[012/463] [DONE] build pacote" ao fim de cada tarefa
  PROG=$(tail -n 20000 $LOG | sed 's/\x1b\[[0-9;]*m//g' | grep -E '^\[[0-9]+/[0-9]+\] \[' | tail -1)
  DONE_N=$(echo "$PROG" | sed -nE 's/^\[0*([0-9]+)\/.*/\1/p')
  TOTAL_N=$(echo "$PROG" | sed -nE 's/^\[[0-9]+\/0*([0-9]+)\].*/\1/p')
  PCT=
  [ -n "$TOTAL_N" ] && PCT=" ($(( 100 * DONE_N / TOTAL_N ))%)"
  RUNNING=$(ps -u $(id -u) -o args= | sed -nE 's/^\/bin\/bash scripts\/(build|install|unpack|get) (.*)/\2/p' | sort -u | tr '\n' ' ')
  LOG_AGE=$(( NOW - $(stat -c %Y $LOG) ))
  {
    echo "ULTRA RETRO PI - build no WSL ($1)"
    echo "tempo total ........ $(hms $(( NOW - START )))"
    echo "tarefas prontas .... ${DONE_N:-0}/${TOTAL_N:-?}${PCT}"
    echo "ultima pronta ...... ${PROG:-(preparando o plano / baixando)}"
    echo "em andamento ....... ${RUNNING:--}"
    echo "CPU (12 threads) ... ${CPU}%   (perto de 0% por muito tempo = travado ou baixando)"
    echo "log escrito ha ..... $(hms $LOG_AGE)"
    echo "disco do Linux usa .$(( USED_MB / 1024 )).$(( USED_MB % 1024 * 10 / 1024 )) GB  (pico $(( PEAK_MB / 1024 )).$(( PEAK_MB % 1024 * 10 / 1024 )) GB)"
    echo "livre no C: ........ ${FREE_C} GB   (para em ${MIN_FREE_GB} GB)"
    if [ -n "$STOPPED" ]; then echo "*** $STOPPED"; fi
  } > $STATUS.tmp
  mv $STATUS.tmp $STATUS
}

# o GNU parallel põe cada tarefa num grupo de processos próprio: mata pela árvore
kill_tree() {
  local p
  for p in $(ps -o pid= --ppid $1); do kill_tree $p $2; done
  kill -$2 $1 2>/dev/null
}

while kill -0 $BPID 2>/dev/null; do
  write_status "rodando"
  if [ -n "$FREE_C" ] && [ "$FREE_C" -lt "$MIN_FREE_GB" ]; then
    STOPPED="PARADO: o C: chegou a ${FREE_C} GB livres. Libere espaco e rode de novo; o build continua de onde parou."
    kill_tree $BPID TERM
    sleep 10
    kill_tree $BPID KILL
    break
  fi
  sleep $EVERY
done
wait $BPID 2>/dev/null

if [ -n "$STOPPED" ]; then
  write_status "parado por espaco"
elif [ "$(cat $RC 2>/dev/null)" = "0" ]; then
  write_status "TERMINOU OK"
  ls -la $SRC/target/ >> $STATUS
else
  write_status "FALHOU (rc=$(cat $RC 2>/dev/null))"
  echo "--- fim do log:" >> $STATUS
  sed 's/\x1b\[[0-9;]*m//g' $LOG | tail -25 >> $STATUS
fi
cat $STATUS
