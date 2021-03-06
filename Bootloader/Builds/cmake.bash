#!/usr/bin/env bash
# This is bash lib file for the convenience build scripts
# Don't call this script directly
# Jacob Alexander 2015-2016

# Check if compiler has been overridden by the environment
Compiler=${COMPILER:-${Compiler}}

# Append to BuildPath, depending on which compiler this is
BuildPath=${BuildPath}.${Compiler}

# Make sure all of the relevant variables have been set
# NOTE: PartialMaps and DefaultMap do not have to be set
VariablesList=(BuildPath Chip Compiler)
ExitEarly=false
for var in ${VariablesList[@]}; do
	if [ -z ${!var+x} ]; then
		echo "ERROR: Unset variable => '${var}'"
		ExitEarly=true
	fi
done

# Error was detected, exit immediately
if $ExitEarly; then
	exit 1
fi


# Prepare PartialMaps
PartialMapsExpanded="${PartialMaps[1]}"
count=2 # Start the loop at index 2
while [ "$count" -le "${#PartialMaps[@]}" ]; do
	PartialMapsExpanded="${PartialMapsExpanded};${PartialMaps[count]}"
	count=$(($count+1))
done


# Internal Variables
CMakeListsPath="../.."
PROG_NAME=$(basename $0)


# Process the command line arguments (if any)
while (( "$#" >= "1" )); do
	# Scan each argument
	key="$1"
	case $key in
	-c|--cmakelists-path)
		CMakeListsPath="$2"
		shift
		;;
	-f|--force-rebuild)
		# Remove the old directory first
		rm -rf "${BuildPath}"
		;;
	-o|--output-path)
		BuildPath="$2"
		shift
		;;
	-h|--help)
		echo "Usage: $PROG_NAME [options...]"
		echo ""
		echo "Convenience script to build the source of a given keyboard."
		echo "Edit '$PROG_NAME' to configure the keyboard options such as KLL layouts."
		echo ""
		echo "Arguments:"
		echo " -c, --cmakelists-path PATH    Set the path of CMakeLists.txt"
		echo "                               Default: ${CMakeListsPath}"
		echo " -f, --force-rebuild           Deletes the old build directory and rebuilds from scratch."
		echo " -o, --output-path PATH        Set the path of the build files."
		echo "                               Default: ${BuildPath}"
		echo " -h, --help                    This message."
		exit 1
		;;
	*)
		echo "INVALID ARG: '$1'"
		exit 2
		;;
	esac

	# Shift to the next argument
	shift
done


# Run CMake commands
## TODO Check for windows and do windows specific things ##
mkdir -p "${BuildPath}"
cd "${BuildPath}"
cmake -DCHIP="${Chip}" -DCOMPILER="${Compiler}" "${CMakeListsPath}"
return_code=$?
if [ $return_code != 0 ] ; then
  echo "Error in cmake. Exiting..."
  exit $return_code
fi

make
return_code=$?
if [ $return_code != 0 ] ; then
  echo "Error in make. Exiting..."
  exit $return_code
fi

echo "Firmware has been compiled into: '${BuildPath}'"
cd -

