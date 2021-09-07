# math-2
Julia implementations learned through [MIT 18.S191 Fall 2020](https://www.youtube.com/watch?v=vxjRWtWoD_w&list=PLP8iPy9hna6Q2Kr16aWPOKE0dz9OnsnIJ)

![ezgif com-gif-maker (8)](https://user-images.githubusercontent.com/56324869/132389557-46cc3b09-5ca1-4748-aab9-c3163f9b6bdf.gif)


# Install
Written using [Pluto](https://github.com/fonsp/Pluto.jl), reactive notebooks for Julia.

## Install Julia
```
$ cd ~/Downloads
$ wget https://julialang-s3.julialang.org/bin/linux/x64/1.6/julia-1.6.0-linux-x86_64.tar.gz
$ tar -xvzf julia-1.6.0-linux-x86_64.tar.gz
$ sudo cp -r julia-1.6.0 /opt/
$ sudo ln -s /opt/julia-1.6.0/bin/julia /usr/local/bin/julia
$ julia
```

## Install Pluto
```
$ julia
julia> ]
(@v1.6) pkg> add Pluto
julia> import Pluto
julia> Pluto.run()
```


