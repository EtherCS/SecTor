This file contains all modified source codes of the tor project

- networkstatus.c (*tor/src/feature/nodelist*): we hardcode the file *cache-consensus* with a real-world consensus file *my-cached-consensus*
- dirvote.c (*tor/src/feature/dirauth*): we added garbage information to the vote file to simulate the real-world vote file (lines 415-425)

when using our tornettools, you need to 
- replace the tor project's source codes with all source codes in this folder (i.e., *networkstatus.c*, *dirvote.c*)
- recompile the tor project (./autogen.sh && ./configure && make && make install)
- put *my-cached-consensus* to the scaled tornet, e.g., *tornet-1*, *tornet-0.02*
- replace *tor.relay.authority.torrc* to the scaled tornet, *tornet-1/conf*
- make sure `tornet-*/conf` and `tornet-*/shadow.data/template` consistent (e.g., hosts have the same certificates)
- execute ```tornettools simulate tornet-1```