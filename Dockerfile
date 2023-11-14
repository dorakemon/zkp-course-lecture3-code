FROM node:18

RUN apt-get update && apt-get install -y zsh git curl build-essential

# install rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# install circom
ENV PATH="/root/.cargo/bin:${PATH}"
WORKDIR /usr/src
RUN git clone https://github.com/iden3/circom.git
WORKDIR /usr/src/circom
RUN cargo build --release
RUN cargo install --path circom


WORKDIR /usr/src/app
COPY . .

RUN npm install -g snarkjs
