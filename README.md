# Test suite of this project
This test suite contains following cases:
- SQL tests. These cases aim to test the SQL handling of the project. It contains DDL, DML, DQL, etc.
- CDC tests. These cases test the feature 'Zero-ETL' of the project.
- Performance tests. These cases are based on TPC-H.

# How to run the test suite
You can either run the tests by the Go program on the source project or by the test tool docker image.

## Prepare the data for testing
The data files used by the test cases lay in directory `tests/cicd`. Please copy them all to your bucket in cloud storage like S3 or local storage like MinIO. Do not try to modify the directory structure of the data files. Because the test cases are based on the directory structure.

Moreover, if you want to test correctness of the TPC-H queries. Please generate the TPC-H data files by yourself. The instructions of generating TPC-H data files is showed [here](foxlake-tpch-sf1-test/README.md). After generating the data files, you can run the test cases in tests/foxlake-tpch-sf1-test/tpch/ directory. It's worth noting that the test results in the cases are based on TPC-H SF1.


## Running Golang program directly
If you wish to debug this test tool, clone the tool project and run on `logictest/mysql/main/main.go`
```bash
...
Install Golang yourself
...

git clone git@github.com:apecloud/sqllogictest.git
cd go/
go run logictest/mysql/main/main.go \
  -dsn username:password@(localhost:7060)/foxlake \
  -kv STORAGE_PROVIDER=s3c \
  -kv BUCKET=foxlake \
  -kv ENDPOINT=127.0.0.1:19000 \
  -kv REGION=cn-northwest-1 \
  -kv STORAGE_PATH=e2e-testing/for-test/ \
  -secret ACCESS_KEY_ID=ABCDEFGHIJK \
  -secret SECRET_ACCESS_KEY=abcdefghijklmnopqrstuvwxyz \
  verify /Path/to/FoxLake/tests/foxlake-sql-test/DQL/show.test
```

To get the usage information of this tool, run the `main.go` without any parameter.
```
go run logictest/mysql/main/main.go
Usage: ./main [options] verify|generate|filter|analyze <test files...>
options:
  -dsn string
        The DSN for MySQL. (default "root:password@tcp(127.0.0.1:3306)/testdb")
  -env-file string
        Optional. Path to the env file. File content should be kv pairs like key=value.
  -init-db
        Optional. Initialize the database by dropping all tables and views. If not set, the harness will not drop tables or views.
  -kv value
        Optional. Environment variable key-value pair (e.g. -kv key=value). Thoes key names with format {{.KEY_NAME}} in test files will be set as environment variables.
  -one-value-per-line
        Optional. Whether to use the old fashioned result format. i.e. One value per line format. Default: false
  -parallelism int
        Optional. The number of tests to run in parallel. This parameter should be greater than 0. (default 1)
  -secret value
        Optional. Secret key-value pair. Like '-kv', those key names with format {{.SECRET_KEY_NAME}} in test files will be set as secret variables. But secrets will not be shown in the console output. (e.g. -secret ACCESS_KEY_ID=abc).
```

## Running on docker image
Firstly, you should pull the image from Docker hub. This docker image is based on this project [apecloud/sqllogictest](https://github.com/apecloud/sqllogictest).
```bash
docker pull apecloud/sqllogictest:main
```
Then, you can run this image by docker command with parameters like running the Go program.
```bash
docker run --rm \
  -v /Path/to/FoxLake/tests/:/home/admin/tests apecloud/sqllogictest:main \
  '-dsn' 'username:password@(host.docker.internal:7060)/foxlake' \
  '-kv' STORAGE_PROVIDER=s3c \
  '-kv' BUCKET=foxlake \
  '-kv' ENDPOINT=127.0.0.1:19000 \
  '-kv' STORAGE_PATH=e2e-testing/for-test/ \
  '-kv' REGION=cn-northwest-1 \
  '-secret' ACCESS_KEY_ID=ABCDEFGHIJK \
  '-secret' SECRET_ACCESS_KEY=abcdefghijklmnopqrstuvwxyz \
  verify tests/foxlake-sql-test/DQL/show.test
```
Also, you can run the image without any parameter following to get the usage information.
```bash
docker run --rm apecloud/sqllogictest:main
Usage: ./main [options] verify|generate|filter|analyze <test files...>
options:
  -dsn string
        The DSN for MySQL. (default "root:password@tcp(127.0.0.1:3306)/testdb")
  -env-file string
        Optional. Path to the env file. File content should be kv pairs like key=value.
  -init-db
        Optional. Initialize the database by dropping all tables and views. If not set, the harness will not drop tables or views.
  -kv value
        Optional. Environment variable key-value pair (e.g. -kv key=value). Thoes key names with format {{.KEY_NAME}} in test files will be set as environment variables.
  -one-value-per-line
        Optional. Whether to use the old fashioned result format. i.e. One value per line format. Default: false
  -parallelism int
        Optional. The number of tests to run in parallel. This parameter should be greater than 0. (default 1)
  -secret value
        Optional. Secret key-value pair. Like '-kv', those key names with format {{.SECRET_KEY_NAME}} in test files will be set as secret variables. But secrets will not be shown in the console output. (e.g. -secret ACCESS_KEY_ID=abc).
```
Please note that you should mount the tests directory to the container. The tests directory is the directory of this project. And the container will run the tests under this directory. The mount directory should be the absolute path, and the mount directory in the container should be `/home/admin/tests`. The `/home/admin/tests` is an empty directory in the container.


## Running multiple test cases sequentially or in parallel
This tool can accept a list of test files or directories. If you specify a directory, then any file with suffix `.test` and `.test-parallelly` under this directory and the sub-directoies will be collected. e.g. If you write this command:
```bash
docker run --rm \
  -v /Path/to/FoxLake/tests/:/home/admin/tests \
  apecloud/sqllogictest:main \
  '-dsn' 'username:password@(host.docker.internal:7060)/foxlake' \
  '-parallelism' 4 \
  '-kv' STORAGE_PROVIDER=s3c \
  '-kv' BUCKET=foxlake \
  '-kv' ENDPOINT=127.0.0.1:19000 \
  '-kv' STORAGE_PATH=e2e-testing/for-test/ \
  '-kv' REGION=cn-northwest-1 \
  '-secret' ACCESS_KEY_ID=ABCDEFGHIJK \
  '-secret' SECRET_ACCESS_KEY=abcdefghijklmnopqrstuvwxyz \
  verify tests/foxlake-sql-test/ tests/foxlake-cdc-test/
```
Then all the test files with suffix `.test` and `.test-parallelly` under the directories `tests/foxlake-sql-test/` and `tests/foxlake-cdc-test/`, and the sub-directoies of them will be run. Those test files with suffix `.test` will be run sequentially by a single goroutine, and those test files with suffix `.test-parallelly` will be run in parallel by multiple goroutines. The number of all goroutines is specified by the parameter `-parallelism`. If you don't specify the `-parallelism` parameter, the default value is 1, which means all files will be run sequentially.


## Parameters of this tool
The description of options can be found above. And please note that the options must be specified before the `verify|generate|filter|analyze`.
The meaning of `verify|generate|filter|analyze`:
- verify: Runs the test files given, outputting a pass / fail line to STDOUT for each test record. All arguments after
  this are interpreted as test files or directories, which contain tests to be run. For directory arguments,
  directories are descended recursively, and all files with the .test extension will be added to the list of tests.

- generate: Runs tests as verify does, but also produces a new version of each test file, named $testfile.generated,
  with the results of this test run.

- filter: Runs the tests and produces a new version of each test file, just like generate, but any tests that
  fail are filtered out and not included in the generated files. This mode is useful when validating a new batch of
  fuzzed statements against a test oracle to filter out statements that don't execute correctly.

- analyze: Analyzes all test statements in the specified test files and prints out a usage count for various statement