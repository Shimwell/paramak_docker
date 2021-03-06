# build with the following command
# sudo docker build -f Dockerfile_with_pymoab -t openmcworkshop/paramak_dependencies_with_pymoab . --no-cache
# run with the following command
# docker run -it openmcworkshop/paramak_dependencies_with_pymoab

FROM ubuntu:18.04

# Updating Ubuntu packages
RUN apt-get update && yes|apt-get upgrade

# Adding wget and bzip2
RUN apt-get install -y wget bzip2

# Anaconda installing
RUN wget https://repo.continuum.io/archive/Anaconda3-2020.02-Linux-x86_64.sh

RUN bash Anaconda3-2020.02-Linux-x86_64.sh -b

RUN rm Anaconda3-2020.02-Linux-x86_64.sh

# Set path to conda
ENV PATH /root/anaconda3/bin:$PATH

RUN conda install -c conda-forge -c cadquery cadquery=2

RUN apt-get update
RUN apt-get install -y libgl1-mesa-dev 
RUN apt-get install -y libglu1-mesa-dev
RUN apt-get install -y freeglut3-dev
RUN apt-get install -y libosmesa6
RUN apt-get install -y libosmesa6-dev
RUN apt-get install -y libgles2-mesa-dev


# the following commands are needed for pymoab installation

RUN apt-get --yes install mpich
RUN apt-get --yes install libmpich-dev
RUN apt-get --yes install libhdf5-serial-dev
RUN apt-get --yes install libhdf5-mpich-dev
RUN apt-get --yes install libblas-dev
RUN apt-get --yes install liblapack-dev

RUN apt-get -y install git
RUN apt-get --yes install hdf5-tools

# MOAB Variables
ENV MOAB_BRANCH='Version5.1.0'
ENV MOAB_REPO='https://bitbucket.org/fathomteam/moab/'
ENV MOAB_INSTALL_DIR=$HOME/MOAB/


# MOAB download
RUN cd $HOME && \
    mkdir MOAB && \
    cd MOAB && \
    git clone -b $MOAB_BRANCH $MOAB_REPO

RUN pip install h5py
RUN pip install cython
RUN pip install cmake
RUN apt-get --yes install cmake

RUN cd $HOME && \
    cd MOAB && \
    mkdir build && cd build && \
    cmake ../moab -DENABLE_HDF5=ON -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=$MOAB_INSTALL_DIR -DENABLE_PYMOAB=ON && \
    # cmake ../moab -DENABLE_HDF5=ON -DENABLE_MPI=off -DENABLE_NETCDF=ON -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=$MOAB_INSTALL_DIR && \
    make -j8 &&  \
    make -j8 install  && \
    cmake ../moab -DBUILD_SHARED_LIBS=ON && \
    make -j8 install && \
    # rm -rf $HOME/MOAB/moab $HOME/MOAB/build && \
    cd pymoab && \
    bash install.sh && \
    python setup.py install

RUN git clone --single-branch --branch main https://github.com/ukaea/paramak.git
RUN cd paramak && python setup.py develop