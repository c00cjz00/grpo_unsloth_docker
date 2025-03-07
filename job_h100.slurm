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
# 1. 提交作業: sbatch slurm_job/job_h100.slurm
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
