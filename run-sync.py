# -*- coding: utf-8 -*-
import os
import re
import sys
import time
import traceback
from datetime import datetime


import os

from generate import _parse_args, generate
from wan.configs import SIZE_CONFIGS, WAN_CONFIGS
from wan.utils.utils import cache_image, cache_video

log_file_path = os.path.abspath(os.path.realpath(os.path.join(os.path.dirname(__file__), "./log.log")))


def printMy(*objects, sep=' ', end='\n', file=sys.stdout, flush=False):
    nowDateTime = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
    objects = [nowDateTime, *objects]
    print(*objects, sep=sep, end=end, file=file, flush=flush)
    try:
        print(*objects, sep=sep, end=end, file=open(log_file_path, 'a'), flush=flush)
    except BaseException as e:
        print(traceback.format_exc())
        pass


# 输出当前目录,使用管理员运行当前目录会变成: C:\Windows\System32
printMy("当前目录:", os.getcwd())

args = _parse_args()

printMy(args)

if args.max_run_time:
    # 转换为秒数
    args.max_run_time = args.max_run_time.split(',')
    args.max_run_time = sum([int(x) * 60 ** i for i, x in enumerate(args.max_run_time[::-1])])
    printMy("max_run_time:", args.max_run_time)
# 开始运行时间
start_time = time.time()

def main():
    if not args.prompt_arr and args.prompt:
        args.prompt_arr = [args.prompt]
    cfg = WAN_CONFIGS[args.task]
    if args.ulysses_size > 1:
        assert cfg.num_heads % args.ulysses_size == 0, f"`{cfg.num_heads=}` cannot be divided evenly by `{args.ulysses_size=}`."
    
    printMy(f"Generation job args: {args}")
    printMy(f"Generation model config: {cfg}")
    wan = generate(args, return_obj=True)
    if args.prompt_arr:
        while True:
            # 使用进程池处理多个文件，采用动态提交任务的方式
            # 收集所有待处理的文件
            prompt_arr = [*args.prompt_arr]
            for prompt in prompt_arr:
                printMy("prompt:", prompt)
                if args.max_run_time and time.time() - start_time > args.max_run_time:
                    printMy("已到最大运行时间,结束处理!")
                    if args.shutdown:
                        os.system("shutdown -a")
                        os.system("shutdown -s -t 120")
                    return
                printMy(
                    f"Generating {'image' if 't2i' in args.task else 'video'} ...")
                try:
                    video = wan.generate(
                        prompt,
                        size=SIZE_CONFIGS[args.size],
                        frame_num=args.frame_num,
                        shift=args.sample_shift,
                        sample_solver=args.sample_solver,
                        sampling_steps=args.sample_steps,
                        guide_scale=args.sample_guide_scale,
                        seed=args.base_seed,
                        offload_model=args.offload_model)

                    # if args.save_file is None:
                    formatted_time = datetime.now().strftime("%Y%m%d_%H%M%S")
                    formatted_prompt = prompt.replace(" ", "_").replace("/",
                                                                             "_")[:50]
                    suffix = '.png' if "t2i" in args.task else '.mp4'
                    args.save_file = f"{args.task}_{args.size.replace('*','x') if sys.platform=='win32' else args.size}_{args.ulysses_size}_{args.ring_size}_{formatted_prompt}_{formatted_time}" + suffix

                    if "t2i" in args.task:
                        printMy(f"Saving generated image to {args.save_file}")
                        cache_image(
                            tensor=video.squeeze(1)[None],
                            save_file=args.save_file,
                            nrow=1,
                            normalize=True,
                            value_range=(-1, 1))
                    else:
                        printMy(f"Saving generated video to {args.save_file}")
                        cache_video(
                            tensor=video[None],
                            save_file=args.save_file,
                            fps=cfg.sample_fps,
                            nrow=1,
                            normalize=True,
                            value_range=(-1, 1))
                except BaseException as e:
                    printMy("error:", e)
                    printMy(traceback.format_exc())

            if not args.max_run_time:
                printMy("结束处理!")
                if args.shutdown:
                    os.system("shutdown -a")
                    os.system("shutdown -s -t 120")
                return
    else:
        printMy("not exists prompt_arr,skip")
    # 处理完成关机
    # if args.shutdown:
    #     os.system("shutdown -a")
    #     os.system("shutdown -s -t 120")


if __name__ == "__main__":
    main()
