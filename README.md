# MDI Dockerizer

The [Michigan Data Interface](https://midataint.github.io/) (MDI) 
is a framework for developing, installing and running 
Stage 1 HPC **pipelines** and Stage 2 interactive web applications 
(i.e., **apps**) in a standardized design interface.

This repository carries admin-only resources to create an Amazon Machine Image (AMI) 
for helping developers build encapsulated Docker container images from Amazon Web Services (AWS).
Information on AWS AMIs can be found here:  

- <https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html>

Information on the Docker container platform can be found here:

- <https://www.docker.com/l>

Note: this repository is for building the mdi-dockerizer AMI,
not the Docker containers themselves. Container build actions 
are coded in the pipelines framework:

- <https://github.com/MiDataInt/mdi-pipelines-framework.git>

---
## Different kinds of MDI containers

The MDI offers two general kinds of containers. 
This repository helps build **fully encapsulated Docker containers** 
running individual pipelines, 
where "fully encapsulated" means that all MDI code is installed into 
the container image.
Thus, end users must download the image and run a container similar to:

```sh
docker run --rm -it [docker options] PIPELINE_DOCKER_IMAGE [pipeline options]
```

Advantages of this approach are that 
pipelines can be distributed to run on any Docker-compatible platform, 
no matter how complex.

The following repository describes 
partially encapsulated Singularity containers 
suitable for running via the MDI installed on an HPC server:

- <https://github.com/MiDataInt/mdi-container-builder>

---
## General Information

### Summary of the AMI:

- **source AMI** = Ubuntu 22.04 standard image, X86_64
- **Linux user** = ubuntu, the AWS standard
- **region** = Ohio, us-east-2
- **instance type** = t3.medium (2 vCPU, 4 GB RAM)
- **storage** = 20 GB EBS SSD
- **Docker** = installed and ready to build container images
- **MDI repositories** = mdi frameworks installed in ~/mdi and ready for use

#### Linux operating system

Any Linux system can build Docker images, but we use Ubuntu Linux
by default, with version 22.04 LTS being current as of this writing.

#### AWS region

AWS AMIs are region specific, i.e., they are only available to be used
for launching instances in the same region as the AMI itself. We build all 
supported AMIs in the Ohio, us-east-2, AWS region closest to Ann Arbor, MI.

#### Instance type

An AMI is not tied to a specific instance type. We create the 
dockerizer AMI with sufficient resources, i.e., t3 medium.
When launching a dockerizer instance, it is beneficial to 
select an instance type with more CPUs, which speeds some steps.

#### Storage

Storage volume size can be expanded when a new EC2 instance is launched.
We create the dockerizer image with sufficient storage to build
several larger images. Developers can safely delete older images once 
they are pushed to a container registry.

#### MDI repositories

The installer uses the MiDataInt/mdi repo to install the MDI and all
of its frameworks.

---
## Instructions for creating the mdi-dockerizer AMI

The steps below will clone this mdi-dockerizer repo into a new EC2 
instance and execute the server configuration script to prepare for 
the build actions to be taken by developers in eventual instances.
The script prepares the operating system to run 'mdi build' by
installing Docker, the MDI, and other system tools. 

### Launch an AWS instance

Launch an EC2 instance with the specifications listed above (or, choose
a different base OS or AWS region, if desired).

- <https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Instances:>

### Log in to the new instance using an SSH terminal

Details for how to log in to an AWS instance are amply documented by Amazon.
Among many choices, we typically use Visual Studio Code with a remote connection 
established via SSH.

- <https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstances.html>
- <https://code.visualstudio.com/docs/remote/remote-overview>

### Clone this repository

From within your terminal, i.e., bash command shell, on the new instance 
(note that git is pre-installed with Ubuntu):

```bash
cd ~
git clone https://github.com/MiDataInt/mdi-dockerizer.git
```

### Check and run the server setup script

```bash
cd mdi-dockerizer
bash ./initialize-dockerizer.sh
```

It will take a while for all of the server components 
to be installed.

### Secure the AMI for public distribution

Dockerizer images should be made public for anyone to use by
setting the Permissions in the AWS console after creating the AMI. 
In preparation for this public release, we follow the AWS guidelines
for securing shared AMIs:

- <https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/building-shared-amis.html>

Specifically, immediately before creating the AMI, run the following script, 
which removes ssh keys and restricts root login permissions:

```bash
bash ~/mdi-dockerizer/prepare-public-ami.sh
```

If the sequence above was followed, there will be no other keys or access 
tokens on the disk to be copied into the image.

Once the commands above are executed, the 
instance from which the AMI is created will not be accessible
after it is stopped - just launch a new instance from the saved AMI.

### Save the AMI

From within the [AWS Management Console](https://aws.amazon.com/console/), 
select the running EC2 instance and execute:

Actions --> Images and templates --> Create image

The dockerizer image should be named and described according to the 
following conventions (change the versions as needed). The timestamp can be 
used to infer the version of the relatively unchanging mdi-dockerizer repo.

>**name**  
>mdi-dockerizer_ubuntu-22.04_docker-3.10.0_yyyy-mm-dd
>
>**description**  
>Michigan Data Interface, dockerizer image, Ubuntu 22.04, Docker 3.10.0, yyyy-mm-dd

---
## Instructions for using the dockerizer AMI

### Launch an AWS instance

Launch an EC2 instance with the required resources.

- <https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Instances:>

### Build a container

First, be sure you have edited your tool suite's '_config.yml' 
to include information on your container registry.

Then, edit '~/mdi/config/suites.yml' in your dockerizer instance
to declare the tool suite carrying your pipeline, 
as for any MDI installation, and run:

```bash
cd ~/mdi
nano config/suites.yml
./install.sh # install the tool suite and update the frameworks
./mdi PIPELINE_NAME build --help
./mdi PIPELINE_NAME build --dockerize [OPTIONS]
```

You will be asked to confirm the action to build your container 
and push it to the registry specified in your configuration files.

### Make your container image public

Importantly, when a new image is pushed to your registry, e.g.,
the GitHub Container Registry, it will typically be marked Private.
Be sure the follow the instructions of your container registry
to make the image Public if you intend for others to use it.
