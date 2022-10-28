#!/usr/bin/bash
# fine tuning

# HYPERPARAMETERS
batch_size="16"
accum_iter="1"
blr="1e-2"

# FIXED PARAMETERS
epochs="50"
warmup_epochs="5"

input_channels="5"
input_electrodes="65"
time_steps="37000"
model="vit_base_patchX"
drop_path="0.1"

patch_height=$input_electrodes
patch_width="200"

weight_decay="0.05"
layer_decay="0.75"

smoothing="0.1" # label smoothing; changes the optimizer used

data_path="/home/oturgut/PyTorchEEG/data/preprocessed/data_TARGET_10fold_decomposed_ideal_fs200.pt"
labels_path="/home/oturgut/PyTorchEEG/data/preprocessed/labels_2classes_TARGET_10fold_fs200.pt"
nb_classes="2"

global_pool="False"
num_workers="32"

pre_batch_size=(128)
pre_blr=(1e-5)

folder="noExternal"
subfolder="test"

eval="True"

for pre_bs in "${pre_batch_size[@]}"
do
    pre_data=$folder"_b"$pre_bs"_blr"$pre_blr

    output_dir="./output/fin/"$folder"/"$subfolder"/fin_b"$batch_size"_blr"$blr"_"$pre_data
    log_dir="./logs/fin/"$folder"/"$subfolder"/fin_b"$batch_size"_blr"$blr"_"$pre_data
    
    if [ "$eval" = "False" ]; then
        finetune="/home/oturgut/PyTorchEEG/mae_he/mae/output/pre/"$folder"/"$subfolder"/pre_"$pre_data"/checkpoint-249.pth"
        cmd="python3 main_finetune.py --input_channels $input_channels --input_electrodes $input_electrodes --time_steps $time_steps --patch_height $patch_height --patch_width $patch_width --model $model --batch_size $batch_size --epochs $epochs --accum_iter $accum_iter --drop_path $drop_path --weight_decay $weight_decay --layer_decay $layer_decay --blr $blr --warmup_epoch $warmup_epochs --smoothing $smoothing --finetune $finetune --data_path $data_path --labels_path $labels_path --nb_classes $nb_classes --output_dir $output_dir --log_dir $log_dir --num_workers $num_workers"
    else
        resume="/home/oturgut/PyTorchEEG/mae_he/mae/output/fin/"$folder"/"$subfolder"/fin_b"$batch_size"_blr"$blr"_"$pre_data"/checkpoint-28.pth"
        cmd="python3 main_finetune.py --eval --resume $resume --input_channels $input_channels --input_electrodes $input_electrodes --time_steps $time_steps --patch_height $patch_height --patch_width $patch_width --model $model --batch_size $batch_size --epochs $epochs --accum_iter $accum_iter --drop_path $drop_path --weight_decay $weight_decay --layer_decay $layer_decay --blr $blr --warmup_epoch $warmup_epochs --smoothing $smoothing --data_path $data_path --labels_path $labels_path --nb_classes $nb_classes --log_dir $log_dir --num_workers $num_workers"
    fi
    
    echo $cmd && $cmd
done