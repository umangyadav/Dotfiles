ARG MUID=1000
ARG MGID=1000
ARG USERNAME=developer
ARG LLVM_VER=20

FROM rocm/mlir:latest

ARG LLVM_VER

# Install compiler; change default to clang
RUN apt-get update && apt-get install -y build-essential && \
wget --progress=bar:force:noscroll https://apt.llvm.org/llvm.sh && chmod u+x llvm.sh && ./llvm.sh ${LLVM_VER} && \
apt-get install -y libclang-${LLVM_VER}-dev clang-format-${LLVM_VER} clang-tidy-${LLVM_VER} clangd-${LLVM_VER} && \
update-alternatives --install /usr/bin/cc cc /usr/bin/clang-${LLVM_VER} 100 && \
update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-${LLVM_VER} 100 && \
update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${LLVM_VER} 100 && \
update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-${LLVM_VER} 100 && \
update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-${LLVM_VER} 100 && \
update-alternatives --install /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-${LLVM_VER} 100 && \
update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-${LLVM_VER} 100

# Here is all personal preference, with a few notes on software you may find useful
# libgcc1 is needed for  .net in vs code
RUN apt-get update && \
apt-get install -y vim tmux git less man man-db mlocate graphviz ccache && \
apt-get install -y silversearcher-ag keychain htop rcm && \
apt-get install -y libbz2-dev liblzma-dev libssl-dev libreadline-dev libgcc1

# rocm-debug-agent is useful when debugging
RUN apt-get -y install rocm-debug-agent && updatedb


ARG MUID
ARG MGID
ARG USERNAME

RUN addgroup --gid ${MGID} ${USERNAME}
RUN useradd -d /home/${USERNAME} -g ${MGID} --no-create-home -u ${MUID} --shell /usr/bin/bash ${USERNAME}
RUN adduser ${USERNAME} sudo
RUN adduser ${USERNAME} video
RUN adduser ${USERNAME} render

# The /var is only needed on lockhart
RUN mkdir /home/${USERNAME} /var/${USERNAME}
RUN chown ${USERNAME}:${USERNAME} /home/${USERNAME} /var/${USERNAME}

# Make sudo work without a password
RUN sed -i~ -e 's/%sudo\tALL=(ALL:ALL) ALL/%sudo\tALL=(ALL:ALL) NOPASSWD:ALL/g' /etc/sudoers
RUN visudo -c

USER ${USERNAME}
WORKDIR /home/${USERNAME}
ENV HOME=/home/${USERNAME}
# Keep container alive
CMD tmux new-session -d && tail -f /dev/null

