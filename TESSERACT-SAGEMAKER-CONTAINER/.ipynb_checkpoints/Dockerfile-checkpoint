FROM ubuntu:18.04

#
# Defining some variables used at build time to install Python3
ARG PYTHON=python3
ARG PYTHON_PIP=python3-pip
ARG PIP=pip3
ARG PYTHON_VERSION=3.6.6

#Non Interactive front end to avoid docker build stucks
ENV DEBIAN_FRONTEND noninteractive
ENV DEBIAN_FRONTEND teletype
#Install Basic Packages 
#Install tesseract
RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true |  debconf-set-selections

RUN apt-get update && apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        wget \
        git \
        nginx \
        openssh-client \
        openssh-server \
        zlib1g-dev \
        unzip \
        tesseract-ocr \
        tesseract-ocr-ita \
        ttf-mscorefonts-installer \
        fonts-dejavu \
        pdfsandwich && \
    rm -rf /var/lib/apt/lists/* 

#Install Python
RUN wget https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz && \
        tar -xvf Python-$PYTHON_VERSION.tgz && cd Python-$PYTHON_VERSION && \
        ./configure && make && make install && \
        apt-get update && apt-get install -y --no-install-recommends libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev libgdbm-dev libc6-dev libbz2-dev && \
        make -j 16 && make install && rm -rf ../Python-$PYTHON_VERSION* && \
        ln -s /usr/local/bin/pip3 /usr/bin/pip

# Upgrading pip and creating symbolic link for python3
RUN ${PIP} --no-cache-dir install --upgrade pip
RUN ln -s $(which ${PYTHON}) /usr/local/bin/python

# Installing numpy, pandas, scikit-learn, scipy
RUN ${PIP} install --no-cache --upgrade \
        numpy==1.14.5 \
        pandas==0.24.1 \
        scikit-learn==0.20.3 \
        requests==2.21.0 \
        scipy==1.2.1

# Here we install the extra python packages to run the inference code
RUN pip install flask gevent gunicorn && \
        rm -rf /root/.cache

#Update font cache
RUN fc-cache -vf

# Setting some environment variables.
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/local/lib" \
    PYTHONIOENCODING=UTF-8 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8


    
#Install AWS CLI
RUN  curl "https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

#Install tesseract and pdfsandwich related script and configurations
COPY code/policy.xml /etc/ImageMagick-6/policy.xml
COPY code/* /opt/ml/code/
COPY tesseract-model /opt/ml/input_model/
COPY langdata/ /opt/ml/langdata/

RUN chmod 755 /opt/ml/code/*

WORKDIR /opt/ml/code/
ENV PATH=${PATH}:/opt/ml/code/

# Use standar start-up scripts instead of installing Sagemaker integration scripts
#RUN ${PIP} install --no-cache --upgrade \
#    sagemaker-containers

#ENTRYPOINT ["/usr/local/bin/python", "/opt/ml/code/main.py"]
#ENV SAGEMAKER_PROGRAM main.py