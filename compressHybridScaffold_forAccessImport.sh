#!/bin/bash

USAGE="USAGE: ./compressHybridScaffold_forAccessImport.sh --targetFolder <path/to/hybrid/scaffold/output> --outputFolder <path/to/compressFileOutput> --prefix <name_for_output_file> --manual <0/1>"

start=$(date +%s)

while [[ $# > 0 ]]; do
	key="$1"
	
	case $key in
		-t|-tf|--targetFolder)
		TARGETFOLDER="$2"
		shift # past argument
		;;
		-o|-of|--outputFolder)
		OUTPUTFOLDER="$2"
		shift # past argument
		;;
		-p|--prefix)
		PREFIX="$2"
		shift # past argument
		;;
		-M|--manual)
		MANUAL="$2"
		shift # past argument
		;;
		-h|--help)
		HELP="YES"
		;;
		*)
			# unknown option
		;;
	esac
	shift # past argument or value
done

if [ "$HELP" == "YES" ]; then
	echo $USAGE
	echo ""
	exit 0
fi

if [ -d "$TARGETFOLDER" ]; then
	TARGETFOLDER=$(readlink -m -n $TARGETFOLDER)
	echo "Compressing assembly folder: $TARGETFOLDER"
else
	echo "ERROR: targetFolder ($TARGETFOLDER) does not exist!"
	echo $USAGE
	echo ""
	exit -1
fi

if [ -d "$OUTPUTFOLDER" ]; then
	OUTPUTFOLDER=$(readlink -m -n $OUTPUTFOLDER)
	echo "Using output folder: $OUTPUTFOLDER"
else
	mkdir -p $OUTPUTFOLDER
	if [ $? -ne 0 ]; then
		echo "ERROR: Could not create directory $OUTPUTFOLDER"
		echo $USAGE
		echo ""
		exit -1
	fi
	OUTPUTFOLDER=$(readlink -m -n $OUTPUTFOLDER)
	echo "Using output folder: $OUTPUTFOLDER"
fi

if [ -z "$PREFIX" ]; then
	echo "ERROR: --prefix not defined"
	echo $USAGE
	echo ""
	exit -1
else
	echo "Creating output file: $OUTPUTFOLDER/$PREFIX.tar.gz"
fi

if [ "$MANUAL" == 0 ]; then
	echo "Compressing the hybrid scaffold run of an auto cut"
else
	if [ "$MANUAL" == 1 ]; then
		echo "Compressing the hybrid scaffold run of a manual cut"
	else
		echo "ERROR: --manual must be either 0 or 1"
		echo $USAGE
		echo ""
		exit -1
	fi
fi

CURRPATH=$(pwd)
cd $TARGETFOLDER/..

BASENAME=$(basename $TARGETFOLDER)

if [ "$MANUAL" == 1 ]; then
	manual_index=$(ls -ld $BASENAME/hybrid_scaffolds* | awk '{print $NF}' | sed -E 's/.*\/hybrid_scaffolds(_M)?//' | awk 'NF' | sort -n | tail -n 1)
	if [ -d "$BASENAME/hybrid_scaffolds_M${manual_index}" ]; then
		echo "Using the manual run folder: hybrid_scaffolds_M${manual_index}"
	else
		echo "ERROR: manual run folder ($BASENAME/hybrid_scaffolds_M*/) does not exist!"
		echo $USAGE
		echo ""
		exit -1
	fi
fi

echo ""
echo -n "Collecting files..."
find $BASENAME -maxdepth 1 -type f -print0 | xargs -0 tar --exclude='*.tar.gz' --exclude='*.*' -rf $OUTPUTFOLDER/$PREFIX.tar
tar --exclude='*.*' --append --file=$OUTPUTFOLDER/$PREFIX.tar $BASENAME/fa2cmap
tar --append --file=$OUTPUTFOLDER/$PREFIX.tar $BASENAME/cur_results.txt

if [ ! -f $BASENAME/${PREFIX}_status.txt ]; then
	cd $OUTPUTFOLDER
	if [ ! -d "$BASENAME" ]; then
		mkdir $BASENAME
		touch $BASENAME/${PREFIX}_status.txt
		tar --append --file=$OUTPUTFOLDER/$PREFIX.tar $BASENAME/${PREFIX}_status.txt
		rm -rf $BASENAME
	else
		touch $BASENAME/${PREFIX}_status.txt
		tar --append --file=$OUTPUTFOLDER/$PREFIX.tar $BASENAME/${PREFIX}_status.txt
		rm $BASENAME/${PREFIX}_status.txt
	fi
	cd $TARGETFOLDER/..
else
	tar --append --file=$OUTPUTFOLDER/$PREFIX.tar $BASENAME/${PREFIX}_status.txt
fi

if [ "$MANUAL" == 0 ]; then
	tar --append --file=$OUTPUTFOLDER/$PREFIX.tar $BASENAME/hybrid_scaffolds
	if [[ -d "$BASENAME/alignmol_bionano/merge" && -d "$BASENAME/alignmol_hybrid/merge" ]]; then
		echo -n "Found alignment of molecules folders..."
		tar --append --file=$OUTPUTFOLDER/$PREFIX.tar $BASENAME/alignmol_bionano/merge
		tar --append --file=$OUTPUTFOLDER/$PREFIX.tar $BASENAME/alignmol_hybrid/merge
	fi
else
	tar --append --file=$OUTPUTFOLDER/$PREFIX.tar $BASENAME/hybrid_scaffolds_M${manual_index}
	if [[ -d "$BASENAME/alignmol_bionano_M${manual_index}/merge" && -d "$BASENAME/alignmol_hybrid_M${manual_index}/merge" ]]; then
		echo -n "Found alignment of molecules folders..."
		tar --append --file=$OUTPUTFOLDER/$PREFIX.tar $BASENAME/alignmol_bionano_M${manual_index}/merge
		tar --append --file=$OUTPUTFOLDER/$PREFIX.tar $BASENAME/alignmol_hybrid_M${manual_index}/merge
	fi
fi

echo -n "Compressing..."
gzip -f $OUTPUTFOLDER/$PREFIX.tar
echo "Done!"
echo ""

cd $CURRPATH
end=$(date +%s)
runtime=$((end-start))

echo "COMPLETE! in $runtime seconds"
echo ""



