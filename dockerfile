FROM tensorflow/tensorflow:latest-gpu-jupyter

RUN mkdir /src && mkdir /app
RUN cd /src && \
    git clone https://github.com/WilliamHsuNz/MLRIG && \
    cd MLRIG && \
    pip install -r requirements.txt
WORKDIR /src


EXPOSE 8787

WORKDIR "/app"
CMD ["/bin/bash"]