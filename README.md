# Reproduce static build error for libtorch

first clone this repo

```
git clone https://github.com/Nintorac/pt_static_build_repro.git --recursive
```

## create builder container image


```
docker build . -t repro_builder
```

## Verify pytorch build works normally

Use the container to build pytorch
```
docker run \
-v $(pwd)/pytorch:/opt/pytorch \
-w /opt/pytorch \
-e USE_MKLDNN=OFF \
-e USE_CUDA=OFF \
-e BUILD_TEST=OFF  \
-e PYTHON_EXECUTABLE="\$(which python3)" \
--name normal_build_test \
repro_builder python3 setup.py install
```

Move the container with a built pytorch to a new image
```
docker commit normal_build_test repro_builder_normal_build
```
Run a pytorch command in the new image
```
docker run -it -rm -w / repro_builder_normal_build python3 -c "import torch; print(torch.randn(10))"
```
Gives the output
```
tensor([ 0.9952,  0.7947,  1.9159,  0.9219,  0.6140,  0.1310, -0.5899, -1.3000,
         2.1250,  0.6468])
```

Seems good.


Now clear the pytorch folder because the build files are in there due to docker volume link and could mess with the next step

```
cd pytorch
sudo git clean -fd  ## sudo because build files in pytorch folder are owned by container
cd ..
```


## Build static with cmake

First configure
```
mkdir build
docker run --rm \
-v $(pwd)/CMakeLists.txt:/opt/CMakeLists.txt \
-v $(pwd)/pytorch:/opt/pytorch \
-v $(pwd)/JUCE:/opt/JUCE \
-v $(pwd)/Source:/opt/Source \
-v $(pwd)/build:/opt/build \
repro_builder cmake -B build/ -GNinja \
-DBUILD_SHARED_LIBS=OFF \
-DUSE_MKLDNN=OFF \
-DUSE_CUDA=OFF \
-DBUILD_TEST=OFF  \
-DPYTHON_EXECUTABLE="$(which python3)" \
-DBUILD_PYTHON=OFF
```

then build
```
docker run --rm \
-v $(pwd)/CMakeLists.txt:/opt/CMakeLists.txt \
-v $(pwd)/JUCE:/opt/JUCE \
-v $(pwd)/pytorch:/opt/pytorch \
-v $(pwd)/Source:/opt/Source \
-v $(pwd)/build:/opt/build \
repro_builder cmake --build build
```

this command fails with output
```
FAILED: pytorch/caffe2/contrib/aten/aten_op.h 
cd /opt/build/pytorch/caffe2 && /usr/bin/python3 /opt/pytorch/caffe2/contrib/aten/gen_op.py --aten_root=/opt/pytorch/caffe2/../aten --template_dir=/opt/pytorch/caffe2/contrib/aten --yaml_dir=/opt/build/pytorch/caffe2/../aten/src/ATen --install_dir=/opt/build/pytorch/caffe2/contrib/aten
Traceback (most recent call last):
  File "/opt/pytorch/caffe2/contrib/aten/gen_op.py", line 219, in <module>
    decls = yaml.load(read(os.path.join(args.yaml_dir, 'Declarations.yaml')), Loader=Loader)
  File "/opt/pytorch/caffe2/contrib/aten/gen_op.py", line 60, in read
    with open(filename, "r") as f:
FileNotFoundError: [Errno 2] No such file or directory: '/opt/build/pytorch/caffe2/../aten/src/ATen/Declarations.yaml'
```