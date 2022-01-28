FROM ubuntu:groovy

RUN echo "rebuild n.2"
RUN apt-get update
RUN apt-get install -y wget git qemu-system qemu-utils python3 python3-pip \
        gcc libelf-dev libssl-dev bc flex bison vim bzip2  cpio

# Download kernel
RUN mkdir -p /sources
WORKDIR /sources
RUN git clone --depth=1 https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
RUN wget https://busybox.net/downloads/busybox-1.32.1.tar.bz2
RUN tar xvjf busybox-1.32.1.tar.bz2

# initial build, so as to speed up development
COPY ./scripts/build-k.sh /sources
RUN /sources/build-k.sh

WORKDIR /scripts

# Setting up neovim-based IDE

RUN apt-get install -y silversearcher-ag libncurses-dev tmux clang-format neovim curl nodejs npm
COPY .config/.tmux.conf /root
COPY .config/.vimrc /root
RUN sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
RUN mkdir -p ~/.config/nvim
RUN ln -s ~/.vimrc ~/.config/nvim/init.vim
RUN nvim --headless +PlugInstall +qall
RUN apt-get install -y clangd
RUN npm install coc-clangd && nvim --headless +"CocInstall -sync coc-clangd" +qall