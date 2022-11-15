#!/usr/bin/bash
# hyperparameter tuning for linear probing

# HYPERPARAMETERS
batch_size=(32)
accum_iter=(1)
blr=(1e-1)

# FIXED PARAMETERS
epochs="75"
warmup_epochs="8"

input_channels="5"
input_electrodes="65"
time_steps="37000"
model="vit_medium_patchX"

patch_height="65"
patch_width="50"

weight_decay="0"

data_path="/home/oturgut/PyTorchEEG/data/preprocessed/data_DINH_bw_10fold_normalized_sw_decomposed_fs200.pt"
labels_path="/home/oturgut/PyTorchEEG/data/preprocessed/labels_2classes_DINH_bw_10fold_sw_fs200.pt"
nb_classes="2"

global_pool="False"
num_workers="32"

pre_batch_size=(128)
pre_blr=(1e-2)

folder="seed"
subfolder=("decomposed/t37000/p50/m0.75/ncc")

output="False"

for pre_bs in "${pre_batch_size[@]}"
do
    for pre_lr in "${pre_blr[@]}"
    do
        for subf in "${subfolder[@]}"
        do

            pre_data=$folder"_b"$pre_bs"_blr"$pre_lr
            finetune="/home/oturgut/PyTorchEEG/mae_he/mae/output/pre/"$folder"/"$subf"/pre_"$pre_data"/checkpoint-249.pth"
        
            for bs in "${batch_size[@]}"
            do
                for lr in "${blr[@]}"
                do
                    output_dir="./output/lin/"$folder"/"$subf"/bw_sw_lin_b"$bs"_blr"$lr"_"$pre_data
                    log_dir="./logs/lin/"$folder"/"$subf"/bw_sw_lin_b"$bs"_blr"$lr"_"$pre_data
                
                    # resume="/home/oturgut/PyTorchEEG/mae_he/mae/output/lin/"$folder"/"$subfolder"/lin_b"$bs"_blr"$lr"_"$pre_data"/checkpoint-18.pth"
                
                    if [ "$output" = "True" ]; then
                        cmd="python3 main_linprobe.py --input_channels $input_channels --input_electrodes $input_electrodes --time_steps $time_steps --patch_height $patch_height --patch_width $patch_width --model $model --batch_size $bs --epochs $epochs --accum_iter $accum_iter --weight_decay $weight_decay --blr $lr --warmup_epoch $warmup_epochs --finetune $finetune --data_path $data_path --labels_path $labels_path --nb_classes $nb_classes --output_dir $output_dir --log_dir $log_dir --num_workers $num_workers"
                    else
                        cmd="python3 main_linprobe.py --input_channels $input_channels --input_electrodes $input_electrodes --time_steps $time_steps --patch_height $patch_height --patch_width $patch_width --model $model --batch_size $bs --epochs $epochs --accum_iter $accum_iter --weight_decay $weight_decay --blr $lr --warmup_epoch $warmup_epochs --finetune $finetune --data_path $data_path --labels_path $labels_path --nb_classes $nb_classes --log_dir $log_dir --num_workers $num_workers"
                    fi
                    echo $cmd && $cmd
                done
            done

        done
    done
done