RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo 'Running test FETCH module'
iverilog tb/fetch_tb.v -o tb/_fetch_tb.o && vvp tb/_fetch_tb.o
echo -e "${GREEN}DONE!${NC}"
