@echo off
:: 设置到全局环境变量
setx WAN2_1_T2V_ARGS "%~1"
:: 获得管理员权限
Net session >nul 2>&1 || mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0","","runas",1)(window.close)&&exit
:: 进入conda环境
CALL conda activate wan2.1
@REM 支持中文
chcp 65001
set PYTHONIOENCODING=utf-8
SET ARGS=%WAN2_1_T2V_ARGS%
:: 删除环境变量
setx WAN2_1_T2V_ARGS ""
echo 当前参数: %ARGS%
@REM 移动到项目根目录,更目录在当前目录下
cd /d %~dp0
@REM 输出当前目录
echo 当前运行目录: %CD%

python D:\public\AI\Wan2.1\generate.py --task t2v-1.3B --size "832*480" --ckpt_dir ./Wan2.1-T2V-1.3B --offload_model True --t5_cpu --sample_shift 8 --sample_guide_scale 6 --prompt "Two anthropomorphic cats in comfy boxing gear and bright gloves fight intensely on a spotlighted stage."
pause