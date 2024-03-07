source ~/.bashrc

# Start time
start_time=$(date +%s)

# path
EXECUTION_PATH="/home/jianting/rust/github.com/shadow/src/test/tor9/tools"
WORKSPACE="/home/jianting/rust/github.com/shadow/src/test/tor9/tools/tornet-1"
OUTPUT_ROOT="$WORKSPACE/tmplog"
TEMPLATE_CONFIG_FILE="$WORKSPACE/template_shadow.config.yaml"
CONFIG_FILE="$WORKSPACE/shadow.config.yaml"
OUTPUT_DATA_FILE="shadow.data"

TOR_PATH="/home/jianting/rust/github.com/shadow/src/test/tor9/tools/tor"
DIRVOTE_PATE="/home/jianting/rust/github.com/shadow/src/test/tor9/tools/tor/src/feature/dirauth"
TEMPLATE_DIRVOTE_FILE="$DIRVOTE_PATE/template_dirvote.c"
DIRVOTE_FILE="$DIRVOTE_PATE/dirvote.c"

# variables
RELAY_NODES=10
BANDWIDTH_LIST="10 50 100 200 500"
BANDWIDTH_CHARA="input"
RELAY_NUM_LIST="10 20"
RELAY_NUM_CHARA="jt_relay"
PASSWORD=""

while getopts ":o:n:m:b:t:p:" opt
do 
    case $opt in
    o) # output path
        echo "output path is $OPTARG"
        OUTPUT_ROOT=$OPTARG
        ;;
    n) # relay node
        echo "added $OPTARG relay nodes"
        RELAY_NODES=$OPTARG
        ;;
    m) # relay node list
        echo "added $OPTARG relay nodes"
        RELAY_NUM_LIST=$OPTARG
        ;;
    b) # the list of input bandwidth
        echo "testing bandwidth is $OPTARG"
        BANDWIDTH_LIST=$OPTARG
        ;;
    t) # the config template
        echo "config template $OPTARG"
        TEMPLATE_CONFIG_FILE=$OPTARG
        ;;
    p) # password
        echo "password $OPTARG"
        PASSWORD=$OPTARG
        ;;
    ?)  
        echo "unknown: $OPTARG"
        ;;
    esac
done

echo "Start simulation"

for relay_node in $RELAY_NUM_LIST; do
    OUTPUT_PATH="$OUTPUT_ROOT/$relay_node-relay"
    mkdir -p $OUTPUT_PATH

    rm -rf $CONFIG_FILE
    rm -rf $WORKSPACE/$OUTPUT_DATA_FILE

    echo "Compile with $relay_node relay nodes"
    cd $DIRVOTE_PATE
    rm -rf $DIRVOTE_FILE
    sed "s/$RELAY_NUM_CHARA/$relay_node/g" "$TEMPLATE_DIRVOTE_FILE" > "$DIRVOTE_FILE"
    cd $TOR_PATH
    echo $PASSWORD | sudo -S make install

    echo "Start testing $relay_node relay nodes"

    cd $EXECUTION_PATH
    for bwth in $BANDWIDTH_LIST; do
        echo "Start simulation: bandwidth is $bwth, relay nodes is $relay_node"
        rm -rf $CONFIG_FILE
        # replace the bandwidth with the input bandwidth
        sed "s/$BANDWIDTH_CHARA/$bwth/g" "$TEMPLATE_CONFIG_FILE" > "$CONFIG_FILE"
        # # return to execution path
        # cd $EXECUTION_PATH
        # running simulation
        tornettools simulate $WORKSPACE
        # rename the folder
        rm -rf "$OUTPUT_PATH/$bwth.kb.$OUTPUT_DATA_FILE"
        mkdir -p $OUTPUT_PATH/$bwth.kb.$OUTPUT_DATA_FILE
        mv "$WORKSPACE/$OUTPUT_DATA_FILE" "$OUTPUT_PATH/$bwth.kb.$OUTPUT_DATA_FILE"
    done
    echo "$relay_node done"
done
echo "all done"

# Calculate execution time in hours
execution_time_seconds=$((end_time - start_time))
execution_time_hours=$(echo "scale=2; $execution_time_seconds / 3600" | bc)

echo "Execution time: $execution_time_hours hours"
