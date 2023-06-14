#!/bin/bash


#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

#Variables globales
declare -a historial_partida_saldo=()
declare -a historial_partida_resultados=()
declare -i numRonda=1
declare -a my_sequence=(1 2 3 4)

#Funciones
function ctrl_c(){
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
  tput cnorm; exit 1
}
trap ctrl_c INT

function helpPanel(){
  echo -e "\n${grayColour}Vienvenido al panel de ayuda de este programa: ${endColour}\n"
  echo -e "\t ${blueColour}m)${endColour} ${grayColour}Insertar dinero con el que se desea apostar${endColour}"
  echo -e "\t ${blueColour}t)${endColour} ${grayColour}Indicar técnica para llevar a cabo en el juego.Opciones: ${endColour}"
  echo -e "\t\t${blueColour}1) martingala${endColour}"
  echo -e "\t\t${blueColour}2) inverselabrouchere${endColour}"
  echo -e "\t ${blueColour}h)${endColour} ${grayColour}Mostrar este panel de ayuda${endColour}"
}

function betSet(){
  echo -e "\n${grayColour}[+] Saldo actual: ${endColour} ${greenColour}$money${endColour}"
  if [ "$technique" == "inverselabrouchere" ] || [ $technique -eq 2 ]; then
    inverselabrouchere
  else
    echo -e -n "\n\t${grayColour}[-] Inserte la cantidad que desea apostar: -> ${endColour}" && read initial_bet
  fi
  if [ $money -gt $initial_bet ] && [ $initial_bet -gt 0 ]; then
    echo -e -n "\n\t${grayColour}[-] Desea apostar por colores${endColour}${blueColour}(c)${endColour}${grayColour} o números${endColour}${blueColour}(n)${endColour}${grayColour}? -> ${endColour}" && read bet_mode1
  if [ "$bet_mode1" == "c" ]; then
    echo -e -n "\n\t${grayColour}[-] Apostar al rojo${endColour}${redColour}(r)${endColour}${grayColour} o negro${endColour}${grayColour}(n) ? -> ${endColour}" && read bet_mode2
    if [ "$bet_mode2" == "r" ]; then
      echo -e "\n${blueColour}[+] La apuesta se ha registrado a color${endColour} ${purpleColour}ROJO${endColour}\n"
    elif [ "$bet_mode2" == "n" ]; then
      echo -e "\n${blueColour}[+] La apuesta se ha registrado a color${endColour} ${purpleColour}NEGRO${endColour}\n"
    else
      echo -e "\n${redColour}[!] El color introducido no existe. Por favor vuelva a intentarlo.${endColour}"
      sleep 2 
      betSet
    fi 
  elif [ "$bet_mode1" == "n" ]; then
    echo -e -n "\n\t${grayColour}[-] Apostar a impar${endColour}${blueColour}(i)${endColour}${grayColour} o par${endColour}${blueColour}(p)${endColour}${grayColour}? -> " && read bet_mode2
    if [ "$bet_mode2" == "i" ]; then
      echo -e "\n${blueColour}[+] La apuesta se ha registrado a numero${endColour} ${purpleColour}IMPAR${endColour}\n"
    elif [ "$bet_mode2" == "p" ]; then
      echo -e "\n${blueColour}[+] La apuesta se ha registrado a numero${endColour} ${purpleColour}PAR${endColour}\n"
    else
      echo -e "\n${redColour}[!] El tipo de número introducido no existe. Por favor vuelva a intentarlo.${endColour}"
      sleep 2 
      betSet
    fi
  else
      echo -e "\n${redColour}[!] El modo de juego introducido no existe. Por favor vuelva a intentarlo.${endColour}"
      sleep 2 
      betSet
  fi
  else
      echo -e "\n${redColour}[!] La cantidad de dinero apostada es mayor que el saldo o no es válida. Por favor vuelva a intentarlo.${endColour}"
      sleep 2 
      betSet
  fi
 }

function panelPartida(){
  tput civis
  echo -e "\nLa ruleta está girando...\n"
  sleep 2.5
  m1=$1 
  m2=$2
 # while true; do 
    random_number="$(($RANDOM % 37))"
    echo -e "\n${grayColour}[+] La bola se ha parado en el número: ${endColour}${redColour}$random_number${endColour}\n"
    sleep 1
    if [ $random_number -eq 0 ]; then
        echo -e "\n${redColour}[!] Ha perdido la apuesta, ha salido el número${endColour} ${purpleColour}$random_number${endColour}\n"
        actualizarSaldo "loose" $initial_bet
        seguirJugando "loose"
    elif [ "$m1" == "c" ]; then
      if [ "$m2" == "n" ]; then
        if [ $(( $random_number % 2)) -eq 0 ]; then
          regard=$(( $initial_bet * 2 ))
          echo -e "\n${greenColour}[!] Ha ganado la apuesta: ${endColour}${purpleColour}+ $regard${endColour}\n"
          actualizarSaldo "win" $regard
          seguirJugando "win"
        else
          echo -e "\n${redColour}[!] Ha perdido la apuesta: ${endColour}${purpleColour}- $initial_bet${endColour}\n"
          actualizarSaldo "loose" $initial_bet
          seguirJugando "loose"
        fi 
      else
         if [ $(( $random_number % 2)) -ne 0 ]; then
          regard=$(( $initial_bet * 2 ))
          echo -e "\n${greenColour}[!] Ha ganado la apuesta: ${endColour}${purpleColour}+ $regard${endColour}\n"
          actualizarSaldo "win" $regard
          seguirJugando "win"
        else
          echo -e "\n${redColour}[!] Ha perdido la apuesta: ${endColour}${purpleColour}- $initial_bet${endColour}\n"
          actualizarSaldo "loose" $initial_bet
          seguirJugando "loose"
        fi 
      fi 
    elif [ "$m1" == "n" ]; then
      if [ "$m2" == "p" ]; then
        if [ $(( $random_number % 2)) -eq 0 ]; then
          regard=$(( $initial_bet * 2 ))
          echo -e "\n${greenColour}[!] Ha ganado la apuesta: ${endColour}${purpleColour}+ $regard${endColour}\n"
          actualizarSaldo "win" $regard
          seguirJugando "win"
        else
          echo -e "\n${redColour}[!] Ha perdido la apuesta: ${endColour}${purpleColour}- $initial_bet${endColour}\n"
          actualizarSaldo "loose" $initial_bet
          seguirJugando "loose"
        fi
      else
         if [ $(( $random_number % 2)) -ne 0 ]; then
          regard=$(( $initial_bet * 2 ))
          echo -e "\n${greenColour}[!] Ha ganado la apuesta: ${endColour}${purpleColour}+ $regard${endColour}\n"
          actualizarSaldo "win" $regard
          seguirJugando "win"
        else
          echo -e "\n${redColour}[!] Ha perdido la apuesta: ${endColour}${purpleColour}- $initial_bet${endColour}\n"
          actualizarSaldo "loose" $initial_bet
          seguirJugando "loose"
        fi
      fi
    else
      echo -e "\n${redColour}[!] Se ha producido un error, pulse Ctrl +c${endColour}\n"
    fi 
#  done
  tput cnorm
}

function martingala(){
  initial_bet=$(( $initial_bet * 2 ))
  if [ $money -gt $initial_bet ]; then
    echo -e "\n${blueColour}[+] Método martingala aplicado de nuevo. Apuesta actual -> ${endColour}${yellowColour}$initial_bet${endColour}\n"
    echo -e "\n${blueColour}[+] Saldo actual: ${endColour}${yellowColour}$money${endColour}\n"
  else
    echo -e "\n${redColour}[!] Saldo agotado !!!${endColour}\n"
  fi
  sleep 2
}

function inverselabrouchere(){
  echo -e "$( ${my_sequence[@]} )"
  if [ "$1" == "win" ]; then
    my_sequence+=( $initial_bet )
    initial_bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
  elif [ "$1" == "loose" ]; then
    if [ "${#my_sequence[@]}" -gt 3 ]; then
      unset my_sequence[0]
      unset my_sequence[-1] 2>/dev/null
      initial_bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
    elif [ "${#my_sequence[@]}" -eq 3 ]; then
      unset my_sequence[0]
      unset my_sequence[-1] 2>/dev/null
      initial_bet=$((${my_sequence[0]}))
    elif [ "${#my_sequence[@]}" -eq 1 ]; then
      unset my_sequence[0] 2>/dev/null
      my_sequence=( 1 2 3 4 )
      initial_bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
      if [ $money -lt $initial_bet ]; then
        echo -e "\n${redColour}[!] Saldo insuficiente para seguir aplicando inverselabrouchere !!!${endColour}\n"
        sleep 3
        exitPane
      fi
    else
      my_sequence=( 1 2 3 4 )
      initial_bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
      if [ $money -lt $initial_bet ]; then
        echo -e "\n${redColour}[!] Saldo insuficiente para seguir aplicando inverselabrouchere !!!${endColour}\n"
        sleep 3
        exitPane
      fi
    fi
  else
    initial_bet=$((${my_sequence[0]} + ${my_sequence[-1]}))  
  fi
  if [ $money -gt $initial_bet ]; then
    echo -e "\n${blueColour}[+] Método inverselabrouchere aplicado de nuevo. Apuesta actual -> ${endColour}${yellowColour}$initial_bet${endColour}\n"
    echo -e "\n${blueColour}[+] Saldo actual: ${endColour}${yellowColour}$money${endColour}\n"
  else
    echo -e "\n${redColour}[!] Saldo agotado !!!${endColour}\n"
  fi
  sleep 2 
}

function seguirJugando(){
  let numRonda+=1
  echo -e "\n${grayColour}Desea seguir jugando?\n"
  echo -e "\t ${blueColour}s)${endColour} ${grayColour}SI${endColour}" 
  echo -e "\t ${blueColour}n)${endColour} ${grayColour}NO${endColour}" 
  echo -e "\t ${blueColour}hi)${endColour} ${grayColour}Mostrar histórico de la partida${endColour}"
  echo -e -n "\t${grayColour}[-] Parámetro elegido: ${endColour}" && read param
  if [ "$param" == "s" ]; then
    if [ "$technique" == "martingala" ] || [ $technique -eq 1 ]; then
      if [ "$1" == "win"]; then
        betSet
      else
        martingala
        panelPartida $bet_mode1 $bet_mode2
      fi 
    else
      inverselabrouchere $1
      panelPartida $bet_mode1 $bet_mode2
    fi
  elif [ "$param" == "n" ]; then
    exitPane
  elif [ "$param" == "hi" ]; then
    historico
  else
    echo -e "\n${redColour}[!] El comando introducido no existe, vuelva a intentarlo${endColour}\n"
    seguirJugando
  fi
}

function historico(){
  for arg1 in "${historial_partida_saldo[@]}"; do 
    for arg2 in "${historial_partida_resultados[@]}"; do
      s_i=$arg1
      r_p=$arg2
      echo -e "\n${grayColour}[+] Número de ronda: ${endColour}$numRonda${blueColour}$num_ronda${endColour}\n"
      echo -e "\t${grayColour}[-] Saldo inicial: ${endColour}${yellowColour}$s_i${endColour}\n"
      if [ "$r_p" -gt 0 ]; then
        echo -e "\t${grayColour}[-] Resultado de la ronda: ${endColour}${yellowColour}$r_p${endColour}\n"
        resultado=$(( $s_i + $r_p ))
        echo -e "\t${grayColour}[!] Saldo final: ${endColour}${yellowColour}$resultado${endColour}\n"
      else
        echo -e "\t${grayColour}[-] Resultado de la ronda: ${endColour}${yellowColour}$r_p${endColour}\n"
        resultado=$(( $s_i + $r_p ))
        echo -e "\t${grayColour}[!] Saldo final: ${endColour}${yellowColour}$resultado${endColour}\n"
      fi 
    done
  done
  echo -e -n "\n${grayColour}[-] Presiona hi de nuevo para salir del histórico: " && read hi 
  while [ "$hi" != "hi" ]; do
    echo -e -n "\n${redColour}[!] El parámetro introducido no es valido, vuelva a insertar hi para salir: ${endColour}" && read hi 
  done
  seguirJugando
}

function exitPane(){
  echo -e "\n\t${purpleColour}----PARTIDA FINALIZADA----${endColour}\n"
  echo -e "\n${grayColour} [+] Saldo final -> ${endColour}${yellowColour}$money${endColour}\n"
  echo -e "\n${grayColour} [+] Número de rondas -> ${endColour}${yellowColour}$numRonda${endColour}\n"
}

function actualizarSaldo(){
  historial_partida_saldo+=( $money )
  if [ "$1" == "win" ]; then
    historial_partida_resultados+=( $2 )
    money=$(( $money + $2 ))
  else
    historial_partida_resultados+=( -$2 )
    money=$(( $money - $2 ))
  fi
}

while getopts "m:t:h" arg; do
  case $arg in 
    m) money=$OPTARG;;
    t) technique=$OPTARG;;
    h) ;;
  esac
done

if [ $money ] && [ $technique ]; then
  if [ "$technique" == "martingala" ] || [ $technique -eq 1 ]; then
    betSet
    panelPartida $bet_mode1 $bet_mode2
  elif [ "$technique" == "inverselabrouchere" ] || [ $technique -eq 2 ]; then
    betSet
    panelPartida $bet_mode1 $bet_mode2
  else
    helpPanel
  fi
else
  helpPanel
fi
