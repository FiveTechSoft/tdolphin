clear

export ARCHITECTURE=linux
export PRG_COMPILER=HARBOUR
export PRG_COMP_PATH=~/git/harbour
export PRG_COMP_BIN_PATH=$PRG_COMP_PATH/bin/linux/gcc
export PRG_COMP_LIB_PATH=$PRG_COMP_PATH/lib/linux/gcc
export PRG_COMP_INC_PATH=$PRG_COMP_PATH/include
export C_COMPILER=gcc
export DOLPHIN_INC=../include

function sintax {
	echo    SYNTAX: bldcon Program [yes/[no]] {-- No especifiques la extensi¢n PRG yes/no servidor incrustado
	echo                                      {-- Dont specify .PRG extension PRG yes/no server embedded
}

if [ $# = 0 ]; then
	sintax
	exit
fi

if [ ! -e $1.prg ]; then
	echo The specified PRG $1 does not exist
	exit
fi

if [ "$2" != "yes" ]; then
	if [ "$2" != "no" ]; then
		if [ $# = 1 ]; then
			export EMBEDDED=no
		else
			sintax
		fi
	else
		export EMBEDDED=$2
	fi
else
	export EMBEDDED=$2
fi

export BLD_TYPE=gtwin
export SAMPLE=$1
export SEPARATOR=/

make sample
./$1
export SAMPLE=
export EMBEDDED=
exit
