# buildah-multiarch-uperf
Buildah, podman and qemu to build and run container for a different processor architecture

### Building container images using buildah, podman and qemu for a different target architecture
This project describes a good mid-level approach with buildah, podman and qemu to build and run a container for s390x architecture on a x86 Linux machine. It containerizes a sample open source application - uperf, that can be used to test the network bandwidth by running server and client on 2 VMs, pods, containers etc.



1. Install buildah, podman and qemu
On Debian / Ubuntu:
```sudo apt install podman buildah qemu-user-static```

or on Fedora / RHEL:
```sudo dnf install podman buildah qemu-user-static```

or on Mac would need to install podman-machine and qemu, which isn't an easy step. Or run Ubuntu/RHEL container in Docker Desktop and follow the same Linux steps.

2. Configure podman for dockerhub.io
Create a config file  ```/etc/containers/registries.conf```
and paste the following lines:
```conf
[registries.search]
registries = ['docker.io']
```
3. Initialize the multiarch qemu-user-static build container
```sudo podman run --rm --privileged multiarch/qemu-user-static --reset -p yes```
4. Build container in target s390x from the local Dockerfile
```buildah bud --arch s390x -t uperf-s390x:latest .```
5. Run the container and verify it's architecture is s390x

```bash
container=$(buildah from uperf-s390x:latest)
echo $container
buildah run $container bash
cat /etc/os-release
uname -a
```
The result should be similar to this and include s390x architecture
```
# cat /etc/os-release 
NAME="Red Hat Enterprise Linux"
VERSION="8.6 (Ootpa)"
ID="rhel"
ID_LIKE="fedora"
VERSION_ID="8.6"
PLATFORM_ID="platform:el8"
PRETTY_NAME="Red Hat Enterprise Linux 8.6 (Ootpa)"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:redhat:enterprise_linux:8::baseos"
HOME_URL="https://www.redhat.com/"
DOCUMENTATION_URL="https://access.redhat.com/documentation/red_hat_enterprise_linux/8/"
BUG_REPORT_URL="https://bugzilla.redhat.com/"

REDHAT_BUGZILLA_PRODUCT="Red Hat Enterprise Linux 8"
REDHAT_BUGZILLA_PRODUCT_VERSION=8.6
REDHAT_SUPPORT_PRODUCT="Red Hat Enterprise Linux"
REDHAT_SUPPORT_PRODUCT_VERSION="8.6"
# uname -a
Linux b34aa4d5f87e 5.15.0-25-generic #25-Ubuntu SMP Wed Mar 30 15:54:59 UTC 2022 s390x s390x s390x GNU/Linux
```
6. Test the uperf command in the container of target architecture
```
# ./uperf/src/uperf
Uperf Version 1.0.7
Usage:   ./uperf/src/uperf [-m profile] [-hvV] [-ngtTfkpaeE:X:i:P:RS:]
	 ./uperf/src/uperf [-s] [-hvV]

	-m <profile>	 Run uperf with this profile
	-s		 Slave
	-S <protocol>	 Protocol type for the control Socket [def: tcp]
	-n		 No statistics
	-T		 Print Thread statistics
	-t		 Print Transaction averages
	-f		 Print Flowop averages
	-g		 Print Group statistics
	-k		 Collect kstat statistics
	-p		 Collect CPU utilization for flowops [-f assumed]
	-e		 Collect default CPU counters for flowops [-f assumed]
	-E <ev1,ev2>	 Collect CPU counters for flowops [-f assumed]
	-a		 Collect all statistics
	-X <file>	 Collect response times
	-i <interval>	 Collect throughput every <interval>
	-P <port>	 Set the master port (defaults to 20000)
	-R		 Emit raw (not transformed), time-stamped (ms) statistics
	-v		 Verbose
	-V		 Version
	-h		 Print usage

More information at http://www.uperf.org
```
