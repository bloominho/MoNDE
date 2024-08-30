import time
import numpy as np
import pandas as pd
import torch
import torch.nn.functional as F
from torch.utils.data import Dataset, DataLoader, RandomSampler, SequentialSampler
from transformers import AutoTokenizer
from modeling_switch_transformers import SwitchTransformersForConditionalGeneration

from torch import cuda

trained_model = SwitchTransformersForConditionalGeneration.from_pretrained("ybelkada/switch-base-8-xsum", torch_dtype=torch.float16)
tokenizer = AutoTokenizer.from_pretrained("ybelkada/switch-base-8-xsum", clean_up_tokenization_spaces=True)

text = "summarize: Peter and Elizabeth took a taxi to attend the night party in the city. While in the party, Elizabeth collapsed and was rushed to the hospital. Since she was diagnosed with a brain injury, the doctor told Peter to stay besides her until she gets well. Therefore, Peter stayed with her at the hospital for 3 days without leaving."

input_ids = tokenizer(text, return_tensors="pt").input_ids


print("\n...Uploading Weights (Host -> FPGA)")
upload_start = time.perf_counter()
trained_model.upload_weights()
upload_finish = time.perf_counter()
print('...Uploading Weights Done: %ds' % (upload_finish - upload_start))

print("\n...Inference Start")
start_time = time.perf_counter()
output_ids = trained_model.generate(input_ids, max_new_tokens=20)
end_time = time.perf_counter()
print('...Inference Done: %fs' % (end_time - start_time))

print("\nResult: "+str(tokenizer.decode(output_ids[0], decoder_input_ids=[0], skip_special_tokens=False))+"\n")