This file contains all modified source codes of the tor project

- networkstatus.c (*tor/src/feature/nodelist*): we hardcode the file *cache-consensus* with a real-world consensus file *my-cached-consensus*

when using our tornettools, you need to 
- replace the tor project's source codes with all source codes in this folder (i.e., *networkstatus.c*)
- recompile the tor project (./autogen.sh && ./configure && make && make install)
- put *my-cached-consensus* to the scaled tornet, e.g., *tornet-1*, *tornet-0.02*
- execute ```tornettools simulate tornet-1```