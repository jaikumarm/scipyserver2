FROM ubuntu:16.04

MAINTAINER Jay <jay@jayakumar.org>

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update --fix-missing && apt-get upgrade -y && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion

RUN apt-get install gcc-4.9 g++-4.9 -y && \
    ln -s  /usr/bin/gcc-4.9 /usr/bin/gcc -f && \
    ln -s  /usr/bin/g++-4.9 /usr/bin/g++ -f && \
    apt-get clean

RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/archive/Anaconda2-4.3.0-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh

RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean

ENV PATH /opt/conda/bin:$PATH

RUN conda install --quiet --yes -c jaikumarm \
	'theano=0.9.0.dev4' \
	'keras=1.2.0' \
	'ta-lib=0.4.9' \
	'flatdict=1.2.0' \
	&& conda clean -tipsy

RUN conda install --quiet --yes psycopg2 pymongo future paramiko gunicorn\
	&& conda clean -tipsy

RUN pip install --upgrade pip && \
    pip install hyperopt IbPy2 pytz backtrader
    
ENV KERAS_BACKEND="theano"

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
