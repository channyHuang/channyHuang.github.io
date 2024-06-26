---
layout: default
title: Push Yolov8n Pre-train Model To rk3588 (4)
categories:
- Linux
tags:
- Server
- Linux
---
//Description: 记录yolov8n部署到rk3588对自定义算子的处理。对自定义的算子，至rknn的SDK2.0.0版本时只支持onnx模型。主要操作为定义算子运算，然后注册算子即可。

//Create Date: 2024-04-26 16:14:28

//Author: channy

[toc]

# 模型准备
```python
import onnx

path = '../model/yolov8n.onnx'
model = onnx.load(path)

for node in model.graph.node:
    if node.op_type == 'Softmax':
        node.op_type = 'cstSoftmax'

onnx.save(model, 'yolov8n_custom.onnx')
```

# Python
## 定义算子运算
自定义算子类，主要包含`shape_infer`和`compute`两个函数
```python
import numpy as np
from rknn.api.custom_op import get_node_attr

class cstSoftmax:
    op_type = 'cstSoftmax'
    def shape_infer(self, node, in_shapes, in_dtypes):
        out_shapes = in_shapes.copy()
        out_dtypes = in_dtypes.copy()
        return out_shapes, out_dtypes
    def compute(self, node, inputs):
        x = inputs[0]
        axis = get_node_attr(node, 'axis')
        x_max = np.max(x, axis = axis, keepdims = True)
        tmp = np.exp(x - x_max)
        s = np.sum(tmp, axis = axis, keepdims = True)
        outputs = [tmp / s]
        return outputs
```
## 转换成rknn
在`config`和`load`之间注册自定义算子`reg_custom_op`
```python
rknn = RKNN(verbose = True)
    rknn.config(mean_values=[127.5, 127.5, 127.5], std_values=[127.5, 127.5, 127.5], 
                quant_img_RGB2BGR = True, target_platform = 'rk3588')
    ret = rknn.reg_custom_op(cstSoftmax())
    if ret != 0:
        print('Register op failed!')
        exit(ret)
    ret = rknn.load_onnx(model = 'yolov8n_custom.onnx')
    if ret != 0:
        print('Load model failed!')
        exit(ret)
    ret = rknn.build(do_quantization = False)
    if ret != 0:
        print('Build model failed!')
        exit(ret)
    ret = rknn.export_rknn(export_path = './yolov8n_custom.rknn', simplify = False, cpp_gen_cfg = False)
    ret = rknn.load_rknn('yolov8n_custom.rknn')
    ret = rknn.init_runtime(target = None, perf_debug = False, eval_mem = True, async_mode = False)#, core_mask = RKNN.NPU_CORE_0_1_2)
    # inference here ...
    image_inference(args, rknn)
```

# c++
## 定义算子运算
```c++
/**
 * float32 kernel implemetation sample for custom cpu op
 * */
int compute_custom_sigmoid_float32(rknn_custom_op_context* op_ctx, rknn_custom_op_tensor* inputs, uint32_t n_inputs,
                                    rknn_custom_op_tensor* outputs, uint32_t n_outputs)
{
    unsigned char*      in_ptr   = (unsigned char*)inputs[0].mem.virt_addr + inputs[0].mem.offset;
    unsigned char*      out_ptr  = (unsigned char*)outputs[0].mem.virt_addr + outputs[0].mem.offset;
    const float*        in_data  = (const float*)in_ptr;
    float*              out_data = (float*)out_ptr;

    // kernel implemetation for custom sigmoid cpu op
    {
        int inside  = 1;

        for (int i = 0; i < inputs[0].attr.n_dims; i++) {
            inside *= inputs[0].attr.dims[i];
        }

        for (int y = 0; y < inside; y++) {
            const float* src_y    = in_data  + y;
            float*       dst_y    = out_data + y;
            dst_y[0] = 1 / (1 + exp(-src_y[0]));
        }
    }
    return 0;
}
```
## 注册算子
```c++
  // register a custom op
  rknn_custom_op user_op[1];
  memset(user_op, 0, sizeof(rknn_custom_op));
  strncpy(user_op[0].op_type, "cstSigmoid", RKNN_MAX_NAME_LEN - 1);
  user_op[0].version = 1;
  user_op[0].target  = RKNN_TARGET_TYPE_CPU;
  user_op[0].compute = compute_custom_sigmoid_float32;
  ret = rknn_register_custom_ops(ctx, user_op, 1);
  if (ret < 0) {
      printf("rknn_register_custom_op fail! ret = %d\n", ret);
      return -1;
  }
```