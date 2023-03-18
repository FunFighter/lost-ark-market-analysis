FROM ubuntu:22.10

SHELL ["/bin/bash","--login","-c"]

RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Dockeruser
ARG username=dockerman
ARG uid=1000
ARG gid=100
ENV USER=$username
ENV UID $uid
ENV GID $gid
ENV HOME /home/$USER

RUN adduser --disabled-password \
    --gecos "Non-root user" \
    --uid $UID \
    --gid $GID \
    --home $HOME \
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
ENV MINICONDA_VERSION latest
ENV CONDA_DIR $HOME/miniconda3
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-$MINICONDA_VERSION-Linux-x86_64.sh -O ~/miniconda.sh && \
    chmod +x ~/miniconda.sh && \
    ~/miniconda.sh -b -p $CONDA_DIR && \
    rm ~/miniconda.sh

# add conda to path
ENV PATH=$CONDA_DIR/bin:$PATH

# add conda to the profile
RUN echo ". $CONDA_DIR/etc/profile.d/conda.sh" >> ~/.profile

# activate conda base by default
RUN conda init bash

# make app dir
ENV PROJECT_DIR $HOME/app
RUN mkdir $PROJECT_DIR
WORKDIR $PROJECT_DIR

# refactor this after I get some sleep
RUN mkdir $HOME/app/notebooks
USER root
COPY notebooks/* /home/dockerman/app/notebooks
RUN chown -R $UID:$GID /home/dockerman/app/notebooks && \
    chmod -R u+x /home/dockerman/app/notebooks
# Switch to non-root user
USER $USER

# build the conda environment
ENV ENV_PREFIX $PROJECT_DIR/env
RUN conda update --name base --channel defaults conda && \
    conda install --name base --channel conda-forge mamba && \
    mamba env create --prefix $ENV_PREFIX --file /tmp/environment.yml --force && \
    conda clean --all --yes

# install lab extensions
RUN conda activate $ENV_PREFIX && \
    /usr/local/bin/postBuild.sh && \
    conda deactivate

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

# Launch jupyterlab server
CMD ["jupyter","lab","--no-browser","--ip","0.0.0.0"]