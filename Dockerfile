ARG CUDA_VERSION=12.3.2
# note ARG needs to appear after FROM unless explicitly used inthe FROM call
FROM nvidia/cuda:${CUDA_VERSION}-base-ubuntu22.04
ARG MMSEQS2_VERSION=17.b804f

#Setup Miniforge using official miniforge dockerfile
ARG MINIFORGE_NAME=Miniforge3
ARG MINIFORGE_VERSION=24.9.2-0
ARG TARGETPLATFORM

ENV CONDA_DIR=/opt/conda
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH=${CONDA_DIR}/bin:${PATH}

# 1. Install just enough for conda to work
# 2. Keep $HOME clean (no .wget-hsts file), since HSTS isn't useful in this context
# 3. Install miniforge from GitHub releases
# 4. Apply some cleanup tips from https://jcrist.github.io/conda-docker-tips.html
#    Particularly, we remove pyc and a files. The default install has no js, we can skip that
# 5. Activate base by default when running as any *non-root* user as well
#    Good security practice requires running most workloads as non-root
#    This makes sure any non-root users created also have base activated
#    for their interactive shells.
# 6. Activate base by default when running as root as well
#    The root user is already created, so won't pick up changes to /etc/skel
RUN apt-get update > /dev/null && \
    apt-get install --no-install-recommends --yes \
        wget bzip2 ca-certificates \
        git \
        tini \
        > /dev/null && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    wget --no-hsts --quiet https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VERSION}/${MINIFORGE_NAME}-${MINIFORGE_VERSION}-Linux-$(uname -m).sh -O /tmp/miniforge.sh && \
    /bin/bash /tmp/miniforge.sh -b -p ${CONDA_DIR} && \
    rm /tmp/miniforge.sh && \
    conda clean --tarballs --index-cache --packages --yes && \
    find ${CONDA_DIR} -follow -type f -name '*.a' -delete && \
    find ${CONDA_DIR} -follow -type f -name '*.pyc' -delete && \
    conda clean --force-pkgs-dirs --all --yes  && \
    echo ". ${CONDA_DIR}/etc/profile.d/conda.sh && conda activate base" >> /etc/skel/.bashrc && \
    echo ". ${CONDA_DIR}/etc/profile.d/conda.sh && conda activate base" >> ~/.bashrc && \
    if [ ${MINIFORGE_NAME} = "Mambaforge"* ]; then \
        echo '. ${CONDA_DIR}/etc/.mambaforge_deprecation.sh' >> /etc/skel/.bashrc && \
        echo '. ${CONDA_DIR}/etc/.mambaforge_deprecation.sh' >> ~/.bashrc; \
    fi && \
    # now setup colabfold based off instructions from the colabfold official docker and localcolabfold install script
    apt-get update && apt-get install -y wget cuda-nvcc-$(echo $CUDA_VERSION | cut -d'.' -f1,2 | tr '.' '-') --no-install-recommends --no-install-suggests && rm -rf /var/lib/apt/lists/* && \
    conda create -y -n colabfold -c conda-forge -c bioconda \
        git python=3.11 openmm==8.0.0 pdbfixer \
        kalign2=2.04 hhsuite=3.3.0 mmseqs2=$MMSEQS2_VERSION && \
    conda clean -afy && \
    ${CONDA_DIR}/envs/colabfold/bin/pip install -q --no-warn-conflicts "colabfold[alphafold-minus-jax] @ git+https://github.com/sokrypton/ColabFold" && \
    ${CONDA_DIR}/envs/colabfold/bin/pip install "colabfold[alphafold]" && \
    ${CONDA_DIR}/envs/colabfold/bin/pip install --upgrade 'jax[cuda12_pip]'==0.4.29 -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html && \
    ${CONDA_DIR}/envs/colabfold/bin/pip install tensorflow && \
    conda clean --tarballs --index-cache --packages --yes && \
    conda clean --force-pkgs-dirs --all --yes  

ENV PATH=${CONDA_DIR}/envs/colabfold/bin:$PATH
ENV MPLBACKEND=Agg

VOLUME cache
ENV MPLCONFIGDIR=/cache
ENV XDG_CACHE_HOME=/cache