# About

This is a refactored local version of the Unsloth Colab notebook, based on the excellent work by Daniel Han and the Unsloth team.

Now you can run GRPO policy locally and feel AHA MOMENT on your own machine.

Source:
- Original Colab notebook post by Daniel Han: [LinkedIn Post](https://www.linkedin.com/posts/danielhanchen_google-colab-activity-7293333957046063104-M3lq)
- Reasoning model guidance from [Unsloth's blog post](https://unsloth.ai/blog/r1-reasoning)
- reward [Will's Gist](https://gist.github.com/willccbb/4676755236bb08cab5f4e54a0475d6fb)

# Prerequisites

- GPU (NVIDIA)
- make (optional - see Advanced Instructions if not using make)

# Quick Start

```
bash
make up
```

# Configuration

Modify `config.yaml` to customize settings and parameters. Then just
```
make train
```

# Clean up

```
make down
```

# Limitations

- Currently supports single GPU operations only
- For multi-GPU or H100 access, please visit [runpod.io](https://runpod.io)

# Advanced Instructions

If you prefer not to use `make`, you can run the Docker commands directly:

```bash
# Build the image
docker build -t grpo_unsloth .

# Create container
docker create -it \
    --gpus=all \
    --name grpo_unsloth_container \
    -v $(pwd)/models:/models \
    -v $(pwd):/workspace \
    -e HF_HOME=/models/cache \
    grpo_unsloth

# Start container
docker start grpo_unsloth_container

# Run a quick test (dry run)
docker exec -it grpo_unsloth_container bash -c "uv run python main.py 'saving=null' 'training.max_steps=10'"

# Run full training
docker exec -it grpo_unsloth_container bash -c "uv run python main.py 'saving=null'"

# Stop container
docker stop grpo_unsloth_container

# Remove container
docker rm grpo_unsloth_container
```
