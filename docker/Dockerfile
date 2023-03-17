FROM ubuntu:22.10

SHELL ["/bin/bash","--login","-c"]

# Dockeruser
ARG username=dockerman
ARG uid=1000
ARG gid=100
ENV USER=$username UID=$uid GID=$gid HOME=/home/$USER
RUN adduser --disable-password\
--gecos "Non-root user"\
--uid $UID\
--gid $GID\
--home $HOME\
$USER

COPY environment.yml requirements.txt /tmp/
RUN chown $UID:$GID /tmp/environment.yml /tmp/requirements.txt

COPY postBuild /usr/local/bin/postBuild.sh
RUN chown $UID:$GID /usr/local/bin/postBuild.sh && \
    chmod u+x /usr/local/bin/postBuild.sh

COPY docker/entrypoint.sh /usr/local/bin
RUN chown $UID:$GID /usr/local/bin/entrypoint.sh && \
    chmod u+x /usr/local/bin/entrypoint.sh

# Switch to non-root user
USER $USER

# install miniconda
ENV URL_PREFIX=https://repo.anaconda.com/miniconda \
    INSTALLER_URL=$URL_PREFIX/miniconda3-latest-Linux-x86_64.sh \
    CONDA_DIR=~/miniconda3
RUN wget --quiet $INSTALLER_URL -O ~/miniconda.sh && \
    chmod u+x ~/miniconda.sh && \
    ~/miniconda.sh -b -p $CONDA_DIR && \
    rm ~/miniconda.sh

# add conda to path
ENV PATH=$CONDA_DIR/bin:$PATH

# add conda to the profile
RUN echo".$CONDA_DIR/etc/profile.d/conda.sh">>~/.profile

# activate conda base by default
RUN conda init bash

# make app dir
ENV PROJECT_DIR ~/app
RUN mkdir $PROJECT_DIR
WORKDIR $PROJECT_DIR

ENV ENV_PREFIX $PROJECT_DIR/env
RUN conda update -n base -c defaults conda && \
    conda env create -p $ENV_PREFIX -f /tmp/environment.yml && \
    conda clean --all --yes

# install lab extensions
RUN conda activate $ENV_PREFIX && \
    /usr/local/bin/postBuild.sh && \
    conda deactive

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

# Launch jupyterlab server
CMD ["jupyter","lab","--no-browser","0.0.0.0"]

# CMD ["python", "./your-daemon-or-script.py"]