FROM vllm/vllm-openai:latest

RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin/:$PATH"
WORKDIR /workspace

ADD uv.lock uv.lock
ADD pyproject.toml pyproject.toml

RUN uv sync
ENTRYPOINT ["/bin/bash"]
