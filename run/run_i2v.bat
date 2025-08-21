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
@REM 移动到项目根目录,更目录在当前目录下
cd /d %~dp0..\
@REM 输出当前目录
echo 当前运行目录: %CD%

SET ARGS=%WAN2_1_T2V_ARGS%
:: 删除环境变量
setx WAN2_1_T2V_ARGS ""
echo ARGS: %ARGS%
python D:\public\AI\Wan2.1\generate.py --task i2v-14B --size 1280*720 --ckpt_dir ./Wan2.1-I2V-14B-720P --image examples/i2v_input.JPG --prompt "Summer beach vacation style, a white cat wearing sunglasses sits on a surfboard. The fluffy-furred feline gazes directly at the camera with a relaxed expression. Blurred beach scenery forms the background featuring crystal-clear waters, distant green hills, and a blue sky dotted with white clouds. The cat assumes a naturally relaxed posture, as if savoring the sea breeze and warm sunlight. A close-up shot highlights the feline's intricate details and the refreshing atmosphere of the seaside."
:: python D:\public\AI\Wan2.1\generate.py --task i2v-14B --size 1280*720 --ckpt_dir ./Wan2.1-I2V-14B-720P --offload_model True --t5_cpu --image examples/i2v_input.JPG --prompt "Summer beach vacation style, a white cat wearing sunglasses sits on a surfboard. The fluffy-furred feline gazes directly at the camera with a relaxed expression. Blurred beach scenery forms the background featuring crystal-clear waters, distant green hills, and a blue sky dotted with white clouds. The cat assumes a naturally relaxed posture, as if savoring the sea breeze and warm sunlight. A close-up shot highlights the feline's intricate details and the refreshing atmosphere of the seaside."
pause
