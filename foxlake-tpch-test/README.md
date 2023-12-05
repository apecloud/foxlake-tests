# How to generate TPC-H data
The instructions showed below are based on the tool [apecloud/tpch-dbgen](https://github.com/apecloud/tpch-dbgen).

We recommend you to use the docker image build by the project `apecloud/tpch-dbgen`.

Firstly, pull the image with tag `apecloud/tpch-dbgen:main`.
```bash
docker pull apecloud/tpch-dbgen:main
```

Secondly run the image with the following command:
```bash
docker run --rm -v $HOME/tpch-dbgen/data:/root/data/ apecloud/tpch-dbgen:main -s 1
```
Change the mount path `$HOME/tpch-dbgen/data` to your own path.

The number '1' in this command indicates the data set will be 1GB. If you want to generate a larger scale of data set, please modify the number as you like.

After the commands complete, you will see the data set under this directory you mounted to the container. In this example, the data set is at: `$HOME/tpch-dbgen/data/SF1/`

For more information, please refer to the project [apecloud/tpch-dbgen](https://github.com/apecloud/tpch-dbgen).