# Simulate Tor with real traffic
>Support the customized number authorities for [tornettools](https://github.com/shadow/tornettools/tree/main).

### Requirements
Make sure you have already installed [shadow](https://github.com/shadow/shadow), [tgen](https://github.com/shadow/tgen), and [oniontrace](https://github.com/shadow/oniontrace).

### Build
```
pip install -r requirements.txt
pip install --ignore-installed .
```

### Prepare
This process is used to download necessary data from Tor website for replaying the traffic
#### Create a folder for testing
For example,
```
cd test
mkdir testTor && cd testTor
```

#### Grab the real Tor data we need

```bash
wget https://collector.torproject.org/archive/relay-descriptors/consensuses/consensuses-2023-04.tar.xz
wget https://collector.torproject.org/archive/relay-descriptors/server-descriptors/server-descriptors-2023-04.tar.xz
wget https://metrics.torproject.org/userstats-relay-country.csv
wget https://collector.torproject.org/archive/onionperf/onionperf-2023-04.tar.xz
wget -O bandwidth-2023-04.csv "https://metrics.torproject.org/bandwidth.csv?start=2023-04-01&end=2023-04-30"
```

#### Extract

```bash
tar xaf consensuses-2023-04.tar.xz
tar xaf server-descriptors-2023-04.tar.xz
tar xaf onionperf-2023-04.tar.xz
```


#### We also utilize privcount Tor traffic model measurements

```bash
git clone https://github.com/tmodel-ccs2018/tmodel-ccs2018.github.io.git
```

#### We also need tor to get its geoip

```bash
sudo apt-get install openssl libssl-dev libevent-dev build-essential automake zlib1g zlib1g-dev
git clone https://git.torproject.org/tor.git
cd tor
./autogen.sh
./configure --disable-asciidoc --disable-unittests --disable-manpage --disable-html-manual
make -j$(nproc)
cd ..
```

#### Install additional executables used by tornettools

`tornettools` also uses the `faketime`, `dstat`, `free`, and `xz` command-line
tools. On Ubuntu these can be installed with:

```bash
sudo apt-get install faketime dstat procps xz-utils
```

#### In order to generate, we need a tor and tor-gencert binaries (to generate relay keys)

```bash
export PATH=${PATH}:`pwd`/tor/src/core/or:`pwd`/tor/src/app:`pwd`/tor/src/tools
```

### Simulation

Now we can simulate Tor with real traffic data.

#### Step 1: stage first, process relay and user info

```bash
    tornettools stage \
        consensuses-2023-04 \
        server-descriptors-2023-04 \
        userstats-relay-country.csv \
        tmodel-ccs2018.github.io \
        --onionperf_data_path onionperf-2023-04 \
        --bandwidth_data_path bandwidth-2023-04.csv \
        --geoip_path tor/src/config/geoip
```

#### Step 2: now we can used the staged files to generate many times

For example, use `--network_scale 0.01` to generate a private Tor network at '1%' the scale of public Tor, and set `--authorities_number 9` to create 9 dictionary authorities:

```bash
tornettools generate \
relayinfo_staging_2023-04-01--2023-04-30.json \
userinfo_staging_2023-04-01--2023-04-30.json \
networkinfo_staging.gml \
tmodel-ccs2018.github.io \
--network_scale 0.01 \
--authorities_number 9 \
--prefix tornet-0.01
```

#### Step 3: set bandwidth to zero for stimulating crash
Modify configuration of the simulation. Set `hosts.4uthority.bandwidth_down` and `hosts.4uthority.bandwidth_up` of at least 5 authorities to be `0 kilobit` in file ***./tornet-0.01/shadow.config.yaml***


#### Step 4: now you can run a simulation and process the results

Note that simulating a '1%' Tor network for 60 simulation minutes can take as much as 30GiB of RAM.

```bash
tornettools simulate tornet-0.01
tornettools parse tornet-0.01
tornettools plot \
    tornet-0.01 \
    --tor_metrics_path tor_metrics_2023-04-01--2023-04-30.json \
    --prefix pdfs
tornettools archive tornet-0.01
```

Performance metrics are plotted in the graph files in the pdfs directory.


### Some relevant documents

Simulation configuration for shadow: [shadow.config.yaml](https://shadow.github.io/docs/guide/shadow_config_spec.html)

Network configuration for shadow (abstract how nodes connect): [network](https://shadow.github.io/docs/guide/network_graph_spec.html)

Example for Tor network with shadow (also under path ***./test/simulTor***): [Tor example](https://shadow.github.io/docs/guide/getting_started_tor.html)