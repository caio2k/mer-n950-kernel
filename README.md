
[![CircleCI](https://circleci.com/gh/caio2k/mer-n950-kernel/tree/master.svg?style=svg)](https://circleci.com/gh/caio2k/mer-n950-kernel/tree/master)
# mer-n950-kernel
mer-n950-kernel docker to launch builds automatically from local or github repository.

## Usage

### Parameters
Launch the docker container with the following arguments in that order:
* `KERNEL_CONFIG`, by default rm581_defconfig
* `GITHUB_REPO_OWNER`, will be ignored if /input is not empty
* `GITHUB_REPO_NAME`, will be ignored if /input is not empty

### Docker volumes
If you want to test a local repository, you have to pass it to docker as a volume. Do it adding:

`-v /home/user/your_local_folder_where_the_kernel_source_is:/input`

Probably you will want to collect the output. Please do it by usinga an `output` volume (beware that contents can be deleted):

`-v /home/user/my_new_deliverables:/output`

If you have permissions issues, please try running as root. As a future improvement the `docker_entrypoint.sh` script should accept `docker`'s `--user` parameter.

### TL;DR
Launch this docker command to test it
`docker run -ti -v ~/input:/input -v ~/output:/output caio2k/mer-n950-kernel:latest n9_mer_defconfig nemomobile kernel-adaptation-n950-n9`
