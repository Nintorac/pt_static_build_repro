FROM ubuntu:20.04

RUN apt-get update && apt-get install build-essential -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install cmake -y
RUN apt-get install pkg-config -y

RUN DEBIAN_FRONTEND=noninteractive apt-get install build-essential python-dev git npm gnome-tweak-tool openjdk-8-jdk -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends gnome-panel -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install libwebkit2gtk-4.0 libgtk-3-dev -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install libwebkit2gtk-4.0-dev libwebkit2gtk-4.0-doc -y

RUN apt-get install python3-pip -y
RUN pip3 install PyYAML
RUN apt-get install -y ninja-build
WORKDIR /opt

RUN apt-get install libgoogle-glog-dev -y
RUN pip3 install install numpy pyyaml mkl mkl-include setuptools cmake cffi typing
RUN apt-get install libomp-dev -y

RUN apt-get install libasound2-dev

WORKDIR /opt
CMD /bin/bash