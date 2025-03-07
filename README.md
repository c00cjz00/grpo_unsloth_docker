# 🚀 Local GRPO Training in HPC

## 安裝 在 T2 (V100) or 晶創主機 (H100)
- 登入 T2 or  晶創主機
```bash
# 下載映像檔
mkdir -p /work/$(whoami)/github/hpc_unsloth_grpo
cd /work/$(whoami)/github/hpc_unsloth_grpo
ml singularity
export SINGULARITY_CACHEDIR=/tmp/singularity_cache
mkdir -p $SINGULARITY_CACHEDIR
singularity pull docker://vllm/vllm-openai:v0.7.2

# 製作相關目錄
mkdir -p /work/$(whoami)/github/hpc_unsloth_grpo/home/.local/bin
mkdir -p /work/$(whoami)/github/hpc_unsloth_grpo/home/github
mkdir -p /work/$(whoami)/github/hpc_unsloth_grpo/home/uv
mkdir -p /work/$(whoami)/github/hpc_unsloth_grpo/workspace

# 下載 uv package
singularity shell --nv --no-home -B /work -B /work/$(whoami)/github/hpc_unsloth_grpo/workspace:/workspace -B /work/$(whoami)/github/hpc_unsloth_grpo/home:$HOME  ./vllm-openai_v0.7.2.sif
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH=$PATH:$HOME/.local/bin

# 下載套件 grpo_unsloth_docker
cd ~/github/
git clone https://github.com/c00cjz00/grpo_unsloth_docker.git
```

## 執行 (測試)
```bash
ml singularity
singularity shell --nv --no-home -B /work -B /work/$(whoami)/github/hpc_unsloth_grpo/workspace:/workspace -B /work/$(whoami)/github/hpc_unsloth_grpo/home:$HOME  ./vllm-openai_v0.7.2.sif
export PATH=$PATH:$HOME/.local/bin
cd ~/github/grpo_unsloth_docker
uv run python main.py 'saving=null' 'training.max_steps=10'
```

## 執行 (運算, slurm v100)
- 編寫派送檔案  /work/$(whoami)/github/hpc_unsloth_grpo/home/github/grpo_unsloth_docker/job_v100.slurm
- 編修 ```#SBATCH --account=GOV114013```   與 ```#SBATCH --mail-user=summerhill001@gmail.com```
- 編修要跑的步數 ```training.max_steps=10```
- 變更訓練模型相關參數請自行修改 config/config.yaml
  
```bash
#!/bin/bash
#SBATCH --job-name=grpo             # 設定作業名稱為 "grpo"
#SBATCH --partition=gp4d            # 指定使用 "gp4d" 分區
#SBATCH --account=GOV113021         # 使用 "GOV113021" 計算資源帳戶
#SBATCH --ntasks-per-node=1         # 每個節點只執行 1 個任務
#SBATCH --cpus-per-task=4           # 每個任務分配 4 個 CPU 核心
#SBATCH --gpus-per-node=1           # 每個節點分配 1 個 GPU
#SBATCH --time=4-00:00:00           # 設定最大執行時間為 4 天
#SBATCH --output=logs/job-%j.out    # 標準輸出日誌文件，%j 代表作業 ID
#SBATCH --error=logs/job-%j.err     # 錯誤輸出日誌文件，%j 代表作業 ID
#SBATCH --mail-type=ALL             # 作業狀態變化時，發送所有通知
#SBATCH --mail-user=summerhill001@gmail.com  # 通知信箱

# 使用方式：
# 1. 提交作業: sbatch slurm_job/job_v100.slurm
# 2. 監控作業日誌: 
#    tail -f logs/job-<job_id>.err  # 查看錯誤輸出
#    tail -f logs/job-<job_id>.out  # 查看標準輸出


# 建立虛擬專屬目錄
myBasedir="/work/$(whoami)/github/hpc_unsloth_grpo"
myHome="home"
mkdir -p ${myBasedir}/${myHome}
mkdir -p ${myBasedir}/workspace

# 載入 Singularity 模組
ml singularity

# 載入 Singularity imaage
# 啟動訓練
singularity exec \
	--nv \
	--no-home \
	-B /work \
	-B ${myBasedir}/workspace:/workspace \
	-B ${myBasedir}/${myHome}:$HOME \
	${myBasedir}/vllm-openai_v0.7.2.sif \
	bash -c "cd \$HOME/github/grpo_unsloth_docker; export PATH=\$PATH:\$HOME/.local/bin; uv run python main.py 'saving=null' 'training.max_steps=10'"
```

- 派送 job_v100.slurm

```bash
cd /work/$(whoami)/github/hpc_unsloth_grpo/home/github/grpo_unsloth_docker
mkdir logs/
sbatch job_v100.slurm
```

## 執行 (運算, slurm h100)
- 編寫派送檔案  /work/$(whoami)/github/hpc_unsloth_grpo/home/github/grpo_unsloth_docker/job_h100.slurm
- 編修 ```#SBATCH --account=GOV114013```   與 ```#SBATCH --mail-user=summerhill001@gmail.com```
- 編修要跑的步數 ```training.max_steps=10```
- 變更訓練模型相關參數請自行修改 config/config.yaml

```bash
#!/bin/bash
#SBATCH --job-name=grpo            # 作業名稱
#SBATCH --partition=normal         # 分區名稱
#SBATCH --account=GOV114013        # 資源計算帳號
#SBATCH --nodes=1        	   # 每節點 1 個任務
#SBATCH --ntasks-per-node=1        # 每節點 1 個任務
#SBATCH --cpus-per-task=12         # 每個任務分配 12 個 CPU 核心（假設節點有足夠的核心）
#SBATCH --gpus-per-node=1          # 每節點 1 個 GPU
#SBATCH --time=2-00:00:00          # 最大執行時間 (2 天)
#SBATCH --output=logs/job-%j.out   # (-o) 設定標準輸出文件的位置，%j 代表作業 ID
#SBATCH --error=logs/job-%j.err    # (-e) 設定錯誤輸出文件的位置，%j 代表作業 ID
#SBATCH --mail-type=ALL            # 當作業狀態變化時，發送所有通知
#SBATCH --mail-user=summerhill001@gmail.com  # 通知用的電子郵件地址


# 使用方式：
# 1. 提交作業: sbatch slurm_job/job_v100.slurm
# 2. 監控作業日誌: 
#    tail -f logs/job-<job_id>.err  # 查看錯誤輸出
#    tail -f logs/job-<job_id>.out  # 查看標準輸出


# 建立虛擬專屬目錄
myBasedir="/work/$(whoami)/github/hpc_unsloth_grpo"
myHome="home"
mkdir -p ${myBasedir}/${myHome}
mkdir -p ${myBasedir}/workspace

# 載入 Singularity 模組
ml singularity

# 載入 Singularity imaage
# 啟動訓練
singularity exec \
	--nv \
	--no-home \
	-B /work \
	-B ${myBasedir}/workspace:/workspace \
	-B ${myBasedir}/${myHome}:$HOME \
	${myBasedir}/vllm-openai_v0.7.2.sif \
	bash -c "cd \$HOME/github/grpo_unsloth_docker; export PATH=\$PATH:\$HOME/.local/bin; uv run python main.py 'saving=null' 'training.max_steps=10'"
```

- 派送 job_h100.slurm

```bash
cd /work/$(whoami)/github/hpc_unsloth_grpo/home/github/grpo_unsloth_docker
sbatch job_h100.slurm
```

## 儲存model 與 Inference範例驗測
- strawberry_example
- 觀看輸出結果, ```job-700427.out``` 改為你的$JOBID
```bash
tail logs/job-700427.out
```

Q: How many r's are in strawberry?"

A:  只跑十步看起來是不行的
```bash
<reasoning>
To find out how many r's are in the word "strawberry," we need to count each occurrence of the letter r in the word. We can do this by examining each letter of the word individually:

strawberry
- The first r is in the 1st position
- The second r is in the 5th position
- The third r is in the 7th position

Counting these occurrences, we find that there are 3 r's in the word "strawberry."
</reasoning>
<answer>
There are 3 r's in the word "strawberry."
</answer>
```



