FROM runpod/pytorch:2.2.1-py3.10-cuda12.1.1-devel-ubuntu22.04
WORKDIR /content
ENV PATH="/home/camenduru/.local/bin:${PATH}"

RUN adduser --disabled-password --gecos '' camenduru && \
    adduser camenduru sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    chown -R camenduru:camenduru /content && \
    chmod -R 777 /content && \
    chown -R camenduru:camenduru /home && \
    chmod -R 777 /home && \
    apt update -y && add-apt-repository -y ppa:git-core/ppa && apt update -y && apt install -y aria2 git git-lfs unzip ffmpeg

USER camenduru

RUN pip install -q torch==2.4.0+cu121 torchvision==0.19.0+cu121 torchaudio==2.4.0+cu121 torchtext==0.18.0 torchdata==0.8.0 --extra-index-url https://download.pytorch.org/whl/cu121 \
    transformers==4.44.2 accelerate==0.33.0 bitsandbytes==0.43.3 sentencepiece==0.2.0 protobuf==5.28.0 kornia==0.7.3 timm==1.0.9 runpod && \
    aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/camenduru/BiRefNet/raw/main/config.json -d /content/BiRefNet -o config.json && \
    aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/camenduru/BiRefNet/resolve/main/model.safetensors -d /content/BiRefNet -o model.safetensors && \
    aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/camenduru/BiRefNet/raw/main/BiRefNet_config.py -d /content/BiRefNet -o BiRefNet_config.py && \
    aria2c --console-log-level=error -c -x 16 -s 16 -k 1M https://huggingface.co/camenduru/BiRefNet/raw/main/birefnet.py -d /content/BiRefNet -o birefnet.py

COPY ./worker_runpod.py /content/worker_runpod.py
WORKDIR /content
CMD python worker_runpod.py
